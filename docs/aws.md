# AWS notes

## Get account ID

```sh

```

## Get cost and usage for AWS

GovCloud does not have Cost Explorer so this will only work with commercial accounts.

Get cost and usage for the past month:

```sh
aws ce get-cost-and-usage --time-period Start="$(date -u -v-1m)",End="$(date -u)"
```
