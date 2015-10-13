#!/bin/bash

if [ -z $AWS_ACCESS_KEY_ID ]; then
  echo "You need to set AWS_ACCESS_KEY_ID environment variable"
  exit 1
fi

if [ -z $AWS_SECRET_ACCESS_KEY ]; then
  echo "You need to set AWS_SECRET_ACCESS_KEY environment variable"
  exit 1
fi

if [ -z $BUCKET ]; then
  echo "You need to set BUCKET environment variable"
  exit 1
fi


#set the aws access credentials from environment variables
echo $AWS_ACCESS_KEY_ID:$AWS_SECRET_ACCESS_KEY > ~/.passwd-s3fs
chmod 600 ~/.passwd-s3fs

#start s3 fuse

/usr/local/bin/s3fs $BUCKET /home/aws/s3bucket -o allow_other -o mp_umask="0022" #-d -d -f -o f2 -o curldbg
