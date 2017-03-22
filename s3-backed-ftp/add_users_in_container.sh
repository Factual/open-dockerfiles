#!/usr/bin/env bash
# This script will update the env.list file (file containing USERS environrment variable) and add the new users if there are any.
set -euo pipefail
IFS=$'\n\t'

FTP_DIRECTORY="/home/aws/s3bucket/ftp-users"
CONFIG_FILE="env.list" # May need to modify config file name to reflect future changes in env file location/name

SLEEP_DURATION=${SLEEP_DURATION:-60}
DIRECTORY_PERMISSIONS=${DIRECTORY_PERMISSIONS:-750}
FILE_PERMISSIONS=${FILE_PERMISSIONS:-644}

readonly LOG_FILE="/var/log/$(basename "$0").log"
info()    { echo "[INFO]    $*" | tee -a "$LOG_FILE" >&2 ; }
warning() { echo "[WARNING] $*" | tee -a "$LOG_FILE" >&2 ; }
fatal()   { echo "[FATAL]   $*" | tee -a "$LOG_FILE" >&2 ; exit 1 ; }

fix_permissions() {
  # Fix for issue when pulling files that were uploaded directly to S3 (through aws web console)
  # Permissions when uploaded directly through S3 Web client were set as:
  # 000 root:root
  # This would not allow ftp users to read the files

  warning "Fixing permissions for $1"

  # Search for files and directories not owned correctly
  find "$FTP_DIRECTORY/$1/files/" -mindepth 1 \( \! -user "$1" \! -group "$1" \) -print0 | xargs -0 -r chown "$1:$1"

  # Search for files with incorrect permissions
  find "$FTP_DIRECTORY/$1/files/" -mindepth 1 -type f \! -perm "$FILE_PERMISSIONS" -print0 | xargs -0 -r chmod "$FILE_PERMISSIONS"

  # Search for directories with incorrect permissions
  find "$FTP_DIRECTORY/$1/files/" -mindepth 1 -type d \! -perm "$DIRECTORY_PERMISSIONS" -print0 | xargs -0 -r chmod "$DIRECTORY_PERMISSIONS"
  find "$FTP_DIRECTORY/$1/files/" -maxdepth 1 -type d \! -perm "$DIRECTORY_PERMISSIONS" -print0 | xargs -0 -r chmod "$DIRECTORY_PERMISSIONS"

  # Search for .ssh folders and authorized_keys files with incorrect permissions/ownership
  find "$FTP_DIRECTORY/$1/.ssh" -mindepth 1 -type d \! -perm 700 -print0 | xargs -0 -r chmod 700
  find "$FTP_DIRECTORY/$1/.ssh" -mindepth 1 -type d \! -user "$1" -print0 | xargs -0 -r chown "$1"

  find "$FTP_DIRECTORY/$1/.ssh/authorized_keys" -mindepth 1 -type f \! -perm 600 -print0 | xargs -0 -r chmod 600
  find "$FTP_DIRECTORY/$1/.ssh/authorized_keys" -mindepth 1 -type f \! -user "$1" -print0 | xargs -0 -r chown "$1"
}

create_user() {
  info "Creating user $1"

  adduser -d "$FTP_DIRECTORY/$username" -s /sbin/nologin "$username"
  addgroup "$username" ftpaccess
  # useradd -d "$FTP_DIRECTORY/$1" -s /usr/sbin/nologin "$1"
  # usermod -G ftpaccess "$1"

  mkdir -p "$FTP_DIRECTORY/$1"
  chown root:ftpaccess "$FTP_DIRECTORY/$1"
  chmod 750 "$FTP_DIRECTORY/$1"

  mkdir -p "$FTP_DIRECTORY/$1/files"
  chown "$1:ftpaccess" "$FTP_DIRECTORY/$1/files"
  chmod 750 "$FTP_DIRECTORY/$1/files"

  # Create .ssh folder and authorized_keys file, for ssh-key sftp access
  mkdir -p "$FTP_DIRECTORY/$1/.ssh"

  chmod 700 "$FTP_DIRECTORY/$1/.ssh"
  chown "$1" "$FTP_DIRECTORY/$username/.ssh"
  touch "$FTP_DIRECTORY/$1/.ssh/authorized_keys"
  chmod 600 "$FTP_DIRECTORY/$1/.ssh/authorized_keys"
  chown "$1" "$FTP_DIRECTORY/$username/.ssh/authorized_keys"
}

add_users() {
  aws s3 cp "s3://$CONFIG_BUCKET/$CONFIG_FILE" "$HOME/$CONFIG_FILE"
  USERS=$(grep USERS "$HOME/CONFIG_FILE" | cut -d '=' -f2)

  for u in $USERS; do
    read -r username _ <<< "${u//:/ }"

    # If account exists set password again
    # In cases where password changes in env file
    if getent passwd "$username" >/dev/null 2>&1; then
      echo "$u" | chpasswd -e
      fix_permissions "$username"
    fi

    # If user account doesn't exist create it
    if ! getent passwd "$username" >/dev/null 2>&1; then
      create_user "$username"
    fi
  done
}

main() {
  while true; do
    add_users
    sleep "$SLEEP_DURATION"
  done
  # inotifywait --monitor "$FTP_DIRECTORY" --recursive --event attrib --event create --format "%w/%f" |
  #   while read -r file; do
  #     info "$file changed"
  #   done

}

main

