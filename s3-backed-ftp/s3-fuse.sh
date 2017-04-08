#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

readonly LOG_FILE="/var/log/$(basename "$0" ".sh").log"
info()    { echo "[INFO]    $*" | tee -a "$LOG_FILE" >&2 ; }
warning() { echo "[WARNING] $*" | tee -a "$LOG_FILE" >&2 ; }
fatal()   { echo "[FATAL]   $*" | tee -a "$LOG_FILE" >&2 ; exit 1 ; }

FTP_BUCKET=${FTP_BUCKET:-}
IAM_ROLE=${IAM_ROLE:-}
AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID:-}
AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY:-}
MOUNT_POINT=${MOUNT_POINT:-"/home/aws/s3bucket"}

# Make sure these variables are not zero-length
# 'set -u' above makes sure they are set to begin with
if [ -z "$FTP_BUCKET" ]; then
  fatal "You need to set FTP_BUCKET environment variable. Aborting!"
fi

if [ -z "$IAM_ROLE" ]; then
  warning "You did not set an IAM_ROLE environment variable. Checking if AWS access keys where provided ..."
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

if [ ! -d "$MOUNT_POINT" ]; then
  mkdir -p "$MOUNT_POINT"
fi

# umask=0022 so $MOUNT_POINT and everything under $MOUNT_POINT has permissions
#   Files:        644
#   Directories:  755
# /usr/local/bin/s3fs "$FTP_BUCKET" "$MOUNT_POINT" -o "iam_role=$IAM_ROLE,allow_other,nodev,nonempty,mp_umask=0022,umask=0022,stat_cache_expire=600" #-d -d -f -o f2 -o curldbg
