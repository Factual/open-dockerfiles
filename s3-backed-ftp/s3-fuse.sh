#!/bin/bash

if [ -z $BUCKET ]; then
  echo "You need to set BUCKET environment variable"
  exit 1
fi

# Code to grab access key and secret access key from EC2 instances meta-data
# This only works if the EC2 instance has been configured with attached IAM role

# if ! curl -s http://169.254.169.254/latest/meta-data/iam/security-credentials/ | grep -q 404; then
#   instance_profile=$(curl http://169.254.169.254/latest/meta-data/iam/security-credentials/)
# 
#   AWS_ACCESS_KEY_ID=$(curl http://169.254.169.254/latest/meta-data/iam/security-credentials/${instance_profile} | grep AccessKeyId | cut -d':' -f2 | sed 's/[^0-9A-Z]*//g')
#   AWS_SECRET_ACCESS_KEY=$(curl http://169.254.169.254/latest/meta-data/iam/security-credentials/${instance_profile} | grep SecretAccessKey | cut -d':' -f2 | sed 's/[^0-9A-Za-z/+=]*//g')
# else
#   "IAM Role account not linked to current EC2 instance, looking for credentials in environment variables instead..."
# fi
# 
# # If they are still not set here, there was an error retreiving the keys from the instances meta-data
# # Or the instance was not configured with the appropriate IAM role account 
# # Check to make sure they are set in environment variables
# if [ -z $AWS_ACCESS_KEY_ID ]; then
#   echo "You need to set AWS_ACCESS_KEY_ID environment variable"
#   exit 1
# fi
# 
# if [ -z $AWS_SECRET_ACCESS_KEY ]; then
#   echo "You need to set AWS_SECRET_ACCESS_KEY environment variable"
#   exit 1
# fi

#set the aws access credentials from environment variables
# echo $AWS_ACCESS_KEY_ID:$AWS_SECRET_ACCESS_KEY > ~/.passwd-s3fs
# chmod 600 ~/.passwd-s3fs

# start s3 fuse
# Code above is not needed if the IAM role is attaced to EC2 instance 
# s3fs provides the iam_role option to grab those credentials automatically
/usr/local/bin/s3fs $BUCKET /home/aws/s3bucket -o allow_other -o mp_umask="0022" -o iam_role="" #-d -d -f -o f2 -o curldbg
