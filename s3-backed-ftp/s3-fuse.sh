#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

readonly LOG_FILE="/var/log/$(basename "$0" ".sh").log"
info()    { echo "[INFO]    $*" | tee -a "$LOG_FILE" >&2 ; }
fatal()   { echo "[FATAL]   $*" | tee -a "$LOG_FILE" >&2 ; exit 1 ; }

# Make sure these variables are not zero-length
# 'set -u' above makes sure they are set to begin with
if [ -z "$FTP_BUCKET" ]; then
  fatal "You need to set FTP_BUCKET environment variable. Aborting!"
fi

if [ -z "$IAM_ROLE" ]; then
  fatal "You did not set an IAM_ROLE environment variable. Checking if AWS access keys where provided ..."
fi

if [ -z "$IAM_ROLE" ] &&  [ -z "$AWS_ACCESS_KEY_ID" ]; then
  fatal "You need to set AWS_ACCESS_KEY_ID environment variable. Aborting!"
fi

if [ -z "$IAM_ROLE" ] && [ -z "$AWS_SECRET_ACCESS_KEY" ]; then
  fatal "You need to set AWS_SECRET_ACCESS_KEY environment variable. Aborting!"
fi

if [ -z "$IAM_ROLE" ] && [ -n "$AWS_ACCESS_KEY_ID" ] && [ -n "$AWS_SECRET_ACCESS_KEY" ]; then
  #set the aws access credentials from environment variables
  echo "$AWS_ACCESS_KEY_ID:$AWS_SECRET_ACCESS_KEY" > ~/.passwd-s3fs
  chmod 600 ~/.passwd-s3fs
fi

PASV_ADDRESS=${PASV_ADDRESS:-""}

if [ -n "$PASV_ADDRESS" ]; then
  info "Using PASV_ADDRESS environment varialbe"
  sed -i "s/^pasv_address=/pasv_address=$PASV_ADDRESS/" /etc/vsftpd.conf
  info "Set PASV_ADDRESS to : $IP"
elif curl -s http://instance-data > /dev/null ; then
  info "Trying to get passive address from EC2 metadata"
  IP=$(curl -s http://instance-data/latest/meta-data/public-ipv4)
  sed -i "s/^pasv_address=/pasv_address=$IP/" /etc/vsftpd.conf
  info "Set PASV_ADDRESS to: $IP"
else
  fatal "You need to set PASV_ADDRESS environment variable, or run in an EC2 instance. Aborting!"
fi

# start s3 fuse
/usr/local/bin/s3fs "$FTP_BUCKET" /home/aws/s3bucket -o allow_other -o mp_umask="0022" -o iam_role="$IAM_ROLE" -o stat_cache_expire=600 #-d -d -f -o f2 -o curldbg
