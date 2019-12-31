# AWS notes

## How to get cost and usage for AWS

For the past month:

``` sh
aws ce get-cost-and-usage --time-period Start="$(date -u -d '1 month ago' +%Y/%m%/d)",End="$(date -u -I)"
```