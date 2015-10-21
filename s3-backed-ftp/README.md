# S3-Backed-FTP Server

An ftp/sftp server using s3fs to mount an external s3 bucket as ftp/sftp storage.

## Usage

To run:

1. First replace env.list.example file with a real env.list file with correct variables filled in.
	- Add users to USERS env variable in the format ` user:hashedpassword user2:hashedpassword2 ` with a space separating each user:pass combination
  	- May also use non-hashed passwords if storing passwords in plaintext is fine.
  	- Just change line ` echo $u | chpasswd -e ` -> ` echo $u | chpasswd `
  	- New users env variable will look like ` user:password1 user2:password2 `
	- AWS keys are now fetched from the EC2 instance currently running the docker container
  	- If the EC2 instance has an attached IAM role just add the roles name to s3-fuse.sh file
  		- Add role name to option ` -o iam_role="rolenamehere" `
  	- If there is no role account attached to EC2 instance (or not running in EC2) pass AWS access key and AWS secret access key as environment variables and uncomment lines 33 and 34 from s3-fuse.sh script
2. Update vsftpd.conf file to add pasv_address of your ftp server
	- Can also change the ports you want to allow passive ftp connections on by changing ` pasv_min_port ` and ` pasv_max_port `  
3. Build the docker container using:

	- ``` docker build --rm -t <docker/tag> path/to/dockerfile/folder ```

4. Then after building the container, run using:

 	- ``` docker run --rm -p 21:21 -p 22:22 -p 1024-1048 --name <name> --cap-add SYS_ADMIN --device /dev/fuse --env-file env.list -P <docker/tag> ```
	- If env.list file is named differently change accordingly. 

