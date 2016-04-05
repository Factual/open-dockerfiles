#!/bin/bash

# Check first if the required FTP_BUCKET variable was provided, if not, abort.
if [ -z $FTP_BUCKET ]; then
  echo "You need to set BUCKET environment variable. Aborting!"
  exit 1
fi

# Then check if there is an IAM_ROLE provided, if not, check if the AWS credentials were provided.
if [ -z $IAM_ROLE ]; then
  echo "You did not set an IAM_ROLE environment variable. Checking if AWS access keys where provided ..."
fi

# Abort if the AWS_ACCESS_KEY_ID was not provided if an IAM_ROLE was not provided neither.
if [ -z $IAM_ROLE ] &&  [ -z $AWS_ACCESS_KEY_ID ]; then
  echo "You need to set AWS_ACCESS_KEY_ID environment variable. Aborting!"
  exit 1
fi

# Abort if the AWS_SECRET_ACCESS_KEY was not provided if an IAM_ROLE was not provided neither.
if [ -z $IAM_ROLE ] && [ -z $AWS_SECRET_ACCESS_KEY ]; then
  echo "You need to set AWS_SECRET_ACCESS_KEY environment variable. Aborting!"
  exit 1
fi

# If there is no IAM_ROLE but the AWS credentials were provided, then set them as the s3fs credentials.
if [ -z $IAM_ROLE ] && [ ! -z $AWS_ACCESS_KEY_ID ] && [ ! -z $AWS_SECRET_ACCESS_KEY ]; then
  #set the aws access credentials from environment variables
  echo $AWS_ACCESS_KEY_ID:$AWS_SECRET_ACCESS_KEY > ~/.passwd-s3fs
  chmod 600 ~/.passwd-s3fs
fi

if [ ! -z $PASV_ADDRESS ]; then
  sed -i "s/^pasv_address=/pasv_address=$PASV_ADDRESS/" /etc/vsftpd.conf
elif curl -s http://instance-data.ec2.internal > /dev/null ; then
  IP=$(curl -s http://instance-data.ec2.internal/latest/meta-data/public-ipv4)
  sed -i "s/^pasv_address=/pasv_address=$IP/" /etc/vsftpd.conf
else
  echo "You need to set PASV_ADDRESS environment variable, or run in an EC2 instance. Aborting!"
  exit 1
fi

# Update the vsftpd.conf file to include the IP address if running on an EC2 instance
# if curl -s http://instance-data.ec2.internal > /dev/null ; then
#   IP=$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4)
#   sed -i "s/^pasv_address=/pasv_address=$IP/" /etc/vsftpd.conf
# else
#   echo "Skipping"
# fi

# start s3 fuse
# Code above is not needed if the IAM role is attaced to EC2 instance
# s3fs provides the iam_role option to grab those credentials automatically
/usr/local/bin/s3fs $FTP_BUCKET /home/aws/s3bucket -o allow_other -o mp_umask="0022" -o iam_role="$IAM_ROLE" #-d -d -f -o f2 -o curldbg
/usr/local/users.sh
