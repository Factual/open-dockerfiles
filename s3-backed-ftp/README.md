# S3-Backed-FTP Server

An ftp/sftp server using s3fs to mount an external s3 bucket as ftp/sftp storage.

More info [here](http://cloudacademy.com/blog/s3-ftp-server/).

## Usage

To run:

1. Create an `env.list` file
    - Add users with the form `username:hashedpassword` separated by a space. Can create the hashedpassword from the following command:
    ```bash
    openssl passwd -1
    Password:
    Verifying - Password:
    ```
   - `FTP_BUCKET` is the bucket you want to mount
   - `CONFIG_BUCKET` is the bucket where your `env.list` file will live in S3
   - Give an `IAM_ROLE`, if running on EC2 with an attached role, or AWS keys

2. Build the image
    ```bash
    make build
    ```

3. Run the container
    > Make sure you have `fuse` installed since the `run` command depends on the device `/dev/fuse`

    ```
    make run
    ```

## Environment Variables


1. ` USERS ` = List of users to add to the ftp/sftp server. Listed in the form username:hashedpassword, each separated by a space.
2. ` FTP_BUCKET ` = S3 bucket where ftp/sftp users data will be stored.
3. ` CONFIG_BUCKET ` = S3 bucket where the config data (env.list file) will be stored.
4. ` IAM_ROLE ` = name of role account linked to EC2 instance the container is running in.

## TODO

- [ ] Use fail2ban on the EC2 instance running this container
  - This requires more mounting the logs on the host

### **Enjoy!**
