# rclone

Get sizes of S3 buckets.

```sh
for BUCKET in $(rclone lsd {{my-aws-profile}}: | awk '{ print $5 }'); do echo "{\"$BUCKET\": $(rclone size --json {{my-aws-profile}}:$BUCKET)}" >> s3-sizes.json; done
```
