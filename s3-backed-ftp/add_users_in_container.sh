#!/usr/bin/env bash
# This script will update the env.list file (file containing USERS environrment variable) and add the new users if there are any.
set -euo pipefail

FTP_DIRECTORY="/home/aws/s3bucket/ftp-users"
CONFIG_FILE="env.list" # May need to modify config file name to reflect future changes in env file location/name
FTP_GROUP=${FTP_GROUP:-"ftpaccess"}

SLEEP_DURATION=${SLEEP_DURATION:-60}
DIR_PERMISSIONS=${DIR_PERMISSIONS:-755}
FILE_PERMISSIONS=${FILE_PERMISSIONS:-640}

readonly LOG_FILE="/var/log/$(basename "$0").log"
info()    { echo "[INFO]    $*" | tee -a "$LOG_FILE" >&2 ; }
warning() { echo "[WARNING] $*" | tee -a "$LOG_FILE" >&2 ; }
fatal()   { echo "[FATAL]   $*" | tee -a "$LOG_FILE" >&2 ; exit 1 ; }

fix_permissions() {
  # Fix for issue when pulling files that were uploaded directly to S3 (through aws web console)
  # Permissions when uploaded directly through S3 Web client were set as:
  # 000 root:root
  # This would not allow ftp users to read the files

  find "$FTP_DIRECTORY/$1/files/" -type f \( -perm 000 -o ! -perm "$FILE_PERMISSIONS" \) -exec chmod "$FILE_PERMISSIONS" {} \+ \
    || warning "Failed to chmod one of $1's files"
  find "$FTP_DIRECTORY/$1/files/" -type d \( -perm 000 -o ! -perm "$DIR_PERMISSIONS" \) -exec chmod "$DIR_PERMISSIONS" {} \+ \
    || warning "Failed to chown one of $1's directories"

  # Don't chown the $1/files directory because it has different owner than the others
  find "$FTP_DIRECTORY/$1/files/" -mindepth 1 \! -user "$1" -exec chown "$1:$1" {} \+ \
    || warning "Failed to chown one of $1's files"
}

create_user() {
  info "Creating user $1"

  adduser -D -h "$FTP_DIRECTORY/$username" -s "/sbin/nologin" "$username" || fatal "Failed to create $username"
  adduser "$username" "$FTP_GROUP" || fatal "Failed to add $username to $FTP_GROUP group"

  mkdir -p "$FTP_DIRECTORY/$1"
  chown root:ftpaccess "$FTP_DIRECTORY/$1"
  chmod "$DIR_PERMISSIONS" "$FTP_DIRECTORY/$1"

  mkdir -p "$FTP_DIRECTORY/$1/files"
  chown "$1:ftpaccess" "$FTP_DIRECTORY/$1/files"
  chmod "$DIR_PERMISSIONS" "$FTP_DIRECTORY/$1/files"

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
  USERS=$(grep USERS "$HOME/$CONFIG_FILE" | cut -d '=' -f2)

  for u in $USERS; do
    read -r username _ <<< "${u//:/ }"

    # If account exists set password again
    # In cases where password changes in env file
    if getent passwd "$username" >/dev/null 2>&1; then
      echo "$u" | chpasswd -e
      fix_permissions "$username"
    else
      # If user account doesn't exist create it
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

