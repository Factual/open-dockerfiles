# S3-Backed-FTP Server

An ftp/sftp server using s3fs to mount an external s3 bucket as ftp/sftp storage.

More info [here](http://cloudacademy.com/blog/s3-ftp-server/).

## Usage

To run:

1. Replace `env.list.example` file with a real `env.list` file with correct variables filled in.
    - Add users to `USERS` environment variable. These should be listed in the form `username:hashedpassword`, each separated by a space.
     - Passwords for those users should be hashed. There are several ways to hash a user password. A common way is to execute a command like the following: `openssl passwd -crypt {your_password}`. Substitute `{your_password}` with the one you want to hash.
     - You may also use non-hashed passwords if storing passwords in plaintext is fine. To do this, change line ` echo $u | chpasswd -e ` => ` echo $u | chpasswd ` in the `users.sh` file (line #24).
    - Specify the S3 buckets were the files (`FTP_BUCKET`) and configs (`CONFIG_BUCKET`) will be stored.
    - If you are running this container inside an AWS EC2 Instance with an assigned IAM_ROLE, then specify its name in the `IAM_ROLE` environment variable.
    - If you do not have an IAM_ROLE attached to your EC2 Instance or wherever you are running this, then you have to specify the AWS credentials that will be used to access S3. These are the `AWS_ACCESS_KEY_ID` and the `AWS_SECRET_KEY_ID` keys.

2. If you have changed other files aside the `env.list` file, then you have to build the docker container using:

    - `docker build --rm -t <docker/tag> path/to/dockerfile/folder`

3. Then after building the container (if necessary), run using:

    - `docker run --rm -p 21:21 -p 222:22 -p 1024-1048:1024-1048 --name <name> --cap-add SYS_ADMIN --device /dev/fuse --env-file env.list  <docker/tag>`
    - If you would like the docker to restart after reboot then use:
        * `docker run --restart=always -p 21:21 -p 222:22 -p 1024-1048:1024-1048 --name <name> --cap-add SYS_ADMIN --device /dev/fuse --env-file env.list <docker/tag>`
    - If `env.list` file is named differently change accordingly.
    - If you don't want to use the cap-add and device options you could also just use the privileged option instead:
        * `docker run --rm -p 21:21 -p 222:22 -p 1024-1024:1024-1048 --privileged --env-file env.list <docker/tag>`
    
## Environment Variables

1. ` USERS ` = List of users to add to the ftp/sftp server. Listed in the form username:hashedpassword, each separated by a space.
2. ` FTP_BUCKET ` = S3 bucket where ftp/sftp users data will be stored.
3. ` CONFIG_BUCKET ` = S3 bucket where the config data (env.list file) will be stored.
4. ` IAM_ROLE ` = name of role account linked to EC2 instance the container is running in.

### Optional Environment Variables
These two environment variables only need to be set if there is no linked IAM role to the EC2 instance.

1. ` AWS_ACCESS_KEY_ID ` = IAM user account access key.
2. ` AWS_SECRET_ACCESS_KEY ` = IAM user account secret access key.

**Enjoy!**
