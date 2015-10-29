# S3-Backed-FTP Server

An ftp/sftp server using s3fs to mount an external s3 bucket as ftp/sftp storage.

## Usage

To run:

1. First replace env.list.example file with a real env.list file with correct variables filled in.
	- Add users to USERS environment variable
  	- May also use non-hashed passwords if storing passwords in plaintext is fine.
  		- Change line ` echo $u | chpasswd -e ` => ` echo $u | chpasswd ` to use plaintext
	- AWS keys are now fetched from the EC2 instance currently running the docker container  
	
2. Build the docker container using:

	- ``` docker build --rm -t <docker/tag> path/to/dockerfile/folder ```

3. Then after building the container, run using:

 	- ``` docker run --rm -p 21:21 -p 222:22 -p 1024-1048:1024-1048 --name <name> --cap-add SYS_ADMIN --device /dev/fuse --env-file env.list  <docker/tag> ```
	- If you would like the docker to restart after reboot then use:
    	* ``` docker run --restart=always -p 21:21 -p 222:22 -p 1024-1048:1024-1048 --name <name> --cap-add SYS_ADMIN --device /dev/fuse --env-file env.list <docker/tag> ```
  	- If env.list file is named differently change accordingly. 
  	- If you don't want to use the cap-add and device options you could also just use the privileged option instead:
    	* ``` docker run --rm -p 21:21 -p 222:22 -p 1024-1024:1024-1048 --privileged --env-file env.list <docker/tag> ```
	
## Environment Variables

1. ` USERS ` = List of users to add to the ftp/sftp server. Listed in the form username:hashedpassword, each separated by a space
2. ` FTP_BUCKET ` = S3 bucket where ftp/sftp users data will be stored
3. ` CONFIG_BUCKET ` = S3 bucket where the config data (env.list file) will be stored 
4. ` IAM_ROLE ` = name of role account linked to EC2 instance the container is running in


## Optional Environment Variables
These two environment variables only need to be set if there is no linked IAM role to the EC2 instance.

1. ` AWS_ACCESS_KEY_ID ` = IAM user account access key
2. ` AWS_SECRET_ACCESS_KEY ` = IAM user account secret access key

Set theses environment variables and uncomment lines [28-36](./s3-fuse.sh#L28-36), [39](./s3-fuse.sh#L34), and [40](./s3-fuse.sh#L35) from s3-fuse.sh script
