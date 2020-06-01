# How to set up S3FS

[S3FS](https://github.com/s3fs-fuse/s3fs-fuse) is a FUSE driver to connect to [S3](https://aws.amazon.com/s3/).

## Installing S3FS

On Debian systems, you can install it using `apt`.

```sh
sudo apt update
sudo apt install -y s3fs
```

On Amazon Linux, you can install it from
[EPEL](https://fedoraproject.org/wiki/EPEL) using `yum`.

```sh
sudo yum install epel-release
sudo yum install s3fs-fuse
```

Or if that doesn't work, here's another way.

```sh
sudo amazon-linux-extras install epel
sudo yum install s3fs-fuse
```

You can also build it from source.

```sh
sudo yum install automake fuse fuse-devel gcc-c++ git libcurl-devel libxml2-devel make openssl-devel -y
git clone https://github.com/s3fs-fuse/s3fs-fuse.git
cd s3fs-fuse
./autogen.sh
./configure
make
sudo make install
```

Next, you'll need a path on the file system to mount the bucket.

```sh
BUCKET_NAME='mybucket'
sudo mkdir -p /mnt/s3/$BUCKET_NAME
```

## S3 Access Control

The suggested way to

### IAM

Make a new IAM role with a policy to give it access to the bucket. Here's what that policy might look like:

```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "VisualEditor0",
            "Effect": "Allow",
            "Action": [
                "s3:PutObject",
                "s3:GetObject",
                "s3:ListBucket",
                "s3:DeleteObject"
            ],
            "Resource": [
                "arn:us-west-1:s3:::*/*",
                "arn:us-west-1:s3:::mybucket
            ]
        }
    ]
}
```

## Mounting the bucket

One way to do this is to make a new entry in `/etc/fstab`. Replace `mybucket` with bucket name. `uid` and `gid` might be different depending on OS. Replace `mybucket_role` with the IAM role giving access to the bucket. The EC2 instance will also need that role attached to it.

```sh
MYBUCKET="mybucket"
MOUNT_POINT="/mnt/mybucket"
AWS_S3_ENDPOINT="us-gov-west-1"
AWS_S3_URL="https://s3-$AWS_S3_ENDPOINT.amazonaws.com"
IAM_ROLE="mybucket_role"
sudo mkdir -p $MOUNT_POINT
s3fs#$MYBUCKET $MOUNT_POINT fuse uid=$(id -u),gid=$(id -g),_netdev,allow_other,endpoint=$AWS_S3_ENDPOINT,use_cache=/tmp,url=$AWS_S3_URL,iam_role=$IAM_ROLE 0 0
```

Mount it.

```sh
sudo mount -av
```
