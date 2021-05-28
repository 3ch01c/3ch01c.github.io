# AWS notes

## Configure a profile

Set the `AWS_PROFILE` environment variable or use the `--profile` flag.

```sh
# aws --profile=example configure
export AWS_PROFILE=example
aws configure
AWS Access Key ID [****************ABCD]: 
AWS Secret Access Key [****************efgh]: 
Default region name [us-west-2]: 
Default output format [json]: 
```

## Get account ID

```sh

```

## Get cost and usage for AWS

GovCloud does not have Cost Explorer so this will only work with commercial accounts.

Get cost and usage for the past month:

```sh
aws ce get-cost-and-usage --time-period Start="$(date -u -v-1m)",End="$(date -u)"
```

## S3

### Basic Usage

List buckets.

```sh
aws s3 ls
# aws s3api list-buckets
```

List contents of a bucket. To list the contents of a directory, you must append the trailing slash.

```sh
aws s3 ls my_bukkit
# aws s3 ls my_bukkit/shells/
```
