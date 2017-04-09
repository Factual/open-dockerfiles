#!/usr/bin/env bash
set -euo pipefail

FTP_DIRECTORY="/home/aws/s3bucket/ftp-users"
FTP_GROUP=${FTP_GROUP:-"ftpaccess"}
PASV_ADDRESS=${PASV_ADDRESS:-}

# Log to the running users home directory
readonly LOG_FILE="/var/log/$(basename "$0" ".sh").log"
info()    { echo "[INFO]    $*" | tee -a "$LOG_FILE" >&2 ; }
warning() { echo "[WARNING] $*" | tee -a "$LOG_FILE" >&2 ; }
fatal()   { echo "[FATAL]   $*" | tee -a "$LOG_FILE" >&2 ; exit 1 ; }

# Create a directory where all ftp/sftp users home directories will go
initial_setup() {
  # Create a group for ftp users
  getent group "$FTP_GROUP" || addgroup "$FTP_GROUP"

  chown supervisor:supervisor /home/supervisor/supervisord.conf
  chmod 750 /home/supervisor/*.sh

  # Generate unique ssh keys for this container, if needed
  if [ ! -f /etc/ssh/ssh_host_ed25519_key ]; then
      ssh-keygen -t ed25519 -f /etc/ssh/ssh_host_ed25519_key -N ''
  fi
  if [ ! -f /etc/ssh/ssh_host_rsa_key ]; then
      ssh-keygen -t rsa -b 4096 -f /etc/ssh/ssh_host_rsa_key -N ''
  fi

  setup_passive_address

  mkdir -p $FTP_DIRECTORY
  chown root:root $FTP_DIRECTORY
  chmod 755 $FTP_DIRECTORY

  mkdir -p /tmp/s3fscache || fatal "Failed to create s3fs cache directory"
}

setup_passive_address() {
  if [ -n "$PASV_ADDRESS" ]; then
    info "Using PASV_ADDRESS environment variable"
    sed -i "s/^pasv_address=.*/pasv_address=$PASV_ADDRESS/" /etc/vsftpd.conf
    info "Set PASV_ADDRESS to : $PASV_ADDRESS"
  elif curl -s http://instance-data > /dev/null ; then
    info "Trying to get passive address from EC2 metadata"
    IP=$(curl -s http://instance-data/latest/meta-data/public-ipv4)
    sed -i "s/^pasv_address=.*/pasv_address=$IP/" /etc/vsftpd.conf
    info "Set PASV_ADDRESS to: $IP"
  else
    fatal "You need to set PASV_ADDRESS environment variable, or run in an EC2 instance. Aborting!"
  fi
}

fix_existing_permissions() {
  # Directory exists but permissions for it have to be setup anyway.
  chown "root:$FTP_GROUP" "$FTP_DIRECTORY/$1"
  chmod 755 "$FTP_DIRECTORY/$1"
  chown "$1:$FTP_GROUP" "$FTP_DIRECTORY/$1/files"
  chmod 755 "$FTP_DIRECTORY/$1/files"
}

create_ssh_folder() {
  # Create .ssh folder and authorized_keys file, for ssh-key sftp access
  mkdir -p "$FTP_DIRECTORY/$1/.ssh"

  chmod 700 "$FTP_DIRECTORY/$1/.ssh"
  chown "$1" "$FTP_DIRECTORY/$username/.ssh"
  touch "$FTP_DIRECTORY/$1/.ssh/authorized_keys"
  chmod 600 "$FTP_DIRECTORY/$1/.ssh/authorized_keys"
  chown "$1" "$FTP_DIRECTORY/$username/.ssh/authorized_keys"
}

create_new_user_directories() {
  info "Creating '$1' directories..."

  # Root must own all directories leading up to and including users home directory
  mkdir -p "$FTP_DIRECTORY/$1"
  chown "root:$FTP_GROUP" "$FTP_DIRECTORY/$1"
  chmod 755 "$FTP_DIRECTORY/$1"

  # Need files sub-directory for SFTP chroot
  mkdir -p "$FTP_DIRECTORY/$1/files"
  chown "$1:$FTP_GROUP" "$FTP_DIRECTORY/$1/files"
  chmod 755 "$FTP_DIRECTORY/$1/files"

  create_ssh_folder "$1"

  info "Finished creating '$1' directories..."
}

add_users() {
  # Expecing an environment variable called USERS to look like "bob:hashedbobspassword steve:hashedstevespassword"
  for u in $USERS; do
    # Read the username and password into two variables
    # By replacing the ':' with a space
    read -r username passwd <<< "${u//:/ }"

    if [ -z "$username" ] || [ -z "$passwd" ]; then
      warning "Invalid username:password combination '$u': please fix to create '$username'"
      continue
    elif ! getent passwd "$username" > /dev/null 2>&1; then
      adduser -D -h "$FTP_DIRECTORY/$username" -s "/sbin/nologin" "$username" || fatal "Failed to create $username"
      adduser "$username" "$FTP_GROUP" || fatal "Failed to add $username to $FTP_GROUP group"

      # set the users password
      echo "$u" | chpasswd -e
    elif [ -d "$FTP_DIRECTORY/$username" ] && [ -d "$FTP_DIRECTORY/$username/files" ]; then
      info "Skipping creation of '$username' user: already exists"
      info "Making sure existing permissions are correct..."

      # Directory exists but permissions for it have to be setup anyway.
      fix_existing_permissions "$username"

      # Create .ssh folder and authorized_keys file, for ssh-key sftp access
      create_ssh_folder "$username"
    else
      create_new_user_directories "$username"
    fi

  done
}

initial_setup
add_users

exec "$@"
