#!/bin/bash
# This script will update the env.list file (file containing USERS environrment variable) and add the new users if there are any.
# Will check for new users at a given time interval (change sleep duration on line 33)

FTP_DIRECTORY="/home/aws/s3bucket/ftp-users"
CONFIG_FILE="env.list" # May need to modify config file name to reflect future changes in env file location/name
SLEEP_DURATION=60

add_users() {
  aws s3 cp s3://$CONFIG_BUCKET/$CONFIG_FILE ~/$CONFIG_FILE
  USERS=$(cat ~/"$CONFIG_FILE" | grep USERS | cut -d '=' -f2)

  for u in $USERS; do
    read username passwd <<< $(echo $u | sed 's/:/ /g')

    # If account exists set password again 
    # In cases where password changes in env file
    if getent passwd "$username" >/dev/null 2>&1; then
      echo $u | chpasswd -e
    fi

    # If user account doesn't exist create it 
    # As well as their home directory 
    if ! getent passwd "$username" >/dev/null 2>&1; then
       useradd -d "$FTP_DIRECTORY/$username" -s /usr/sbin/nologin $username
       usermod -G ftpaccess $username

       mkdir -p "$FTP_DIRECTORY/$username"
       chown root:ftpaccess "$FTP_DIRECTORY/$username"
       chmod 750 "$FTP_DIRECTORY/$username"

       mkdir -p "$FTP_DIRECTORY/$username/files"
       chown $username:ftpaccess "$FTP_DIRECTORY/$username/files"
       chmod 750 "$FTP_DIRECTORY/$username/files"
     fi
   done
}

 while true; do
   add_users
   sleep $SLEEP_DURATION
 done
