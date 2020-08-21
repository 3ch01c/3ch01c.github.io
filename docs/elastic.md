# elastic

## Quick Start

Apply Elastic definitions to Kubernetes.

```sh
kubectl apply -f https://download.elastic.co/downloads/eck/1.1.2/all-in-one.yaml
```

Check Elastic operator logs.

```sh
kubectl -n elastic-system logs -f statefulset.apps/elastic-operator
```

Deploy an Elasticsearch cluster. (NOTE: You'll need to [deploy a Kubernetes node with at least
2 GiB memory](minikube.md#start).)

```sh
cat <<EOF | kubectl apply -f -
apiVersion: elasticsearch.k8s.elastic.co/v1
kind: Elasticsearch
metadata:
  name: quickstart
spec:
  version: 7.8.0
  nodeSets:
  - name: default
    count: 1
    config:
      node.master: true
      node.data: true
      node.ingest: true
      node.store.allow_mmap: false
EOF
# elasticsearch.elasticsearch.k8s.elastic.co/quickstart created
```

Get Elasticsearch resources.

```sh
kubectl get elasticsearch
```

Delete Elasticsearch resources.

```sh
kubectl delete elasticsearch quickstart
# elasticsearch.elasticsearch.k8s.elastic.co "quickstart" deleted
```
