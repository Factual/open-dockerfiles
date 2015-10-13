# S3-Backed-FTP Server

An ftp/sftp server using s3fs to mount an external s3 bucket as ftp/sftp storage.

# Usage

To run:
1. First replace env.list.example file with a real env.list file with correct variables filled in.
  * Add users to USERS env variable in the format ` user:password user2:password2 ` with a space separating each user:pass combination
  * AWS keys and AWS bucket name should **not** be surrounded by quotes
2. Build the docker container using:
` docker build --rm -t <docker/tag> path/to/dockerfile/folder `
3. Then after building the container, run using:
` docker run --rm -p 21:21 -p 22:22 --name s3ftp --cap-add SYS_ADMIN --device /dev/fuse --env-file env.list -P <docker/tag> ` 
  * When building if you use another tag (not s3ftp) replace with correct name
  * If env.list file is named differently change accordingly. 

