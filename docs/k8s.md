# Kubernetes (K8s)

- [Installation](#installation)
  - [Pre-requisites](#pre-requisites)
    - [Container Runtime](#container-runtime)
      - [Docker](#docker)
    - [K8s tools](#k8s-tools)
      - [Vanilla K8s](#vanilla-k8s)
      - [Other K8s Flavors](#other-k8s-flavors)
  - [Set up a cluster with `kubeadm`](#set-up-a-cluster-with-kubeadm)
- [Helm](#helm)
- [Nvidia](#nvidia)
  - [GPU Monitoring](#gpu-monitoring)
- [High Availability](#high-availability)

## Installation

### Pre-requisites

#### Container Runtime

You'll need some container runtime such as Docker, containerd, etc.

##### Docker

Install Docker.

```sh
# On Ubuntu
RELEASE=$(lsb_release -cs)
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $RELEASE stable"
sudo apt update
sudo apt install -y "docker-ce=5:19.03.12~3-0~ubuntu-$RELEASE"
```

#### K8s tools

##### Vanilla K8s

Every node needs `kubelet`. The master node(s) also need `kubeadm` and `kubectl`.

```sh
# On Ubuntu
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add
sudo apt-add-repository "deb https://apt.kubernetes.io/ kubernetes-xenial main"
sudo apt update
sudo apt install -y "kubelet=1.17.8-00" "kubeadm=1.17.8-00" "kubectl=1.17.8-00"
```

It's recommended to pin package versions.

```sh
sudo apt-mark hold docker-ce kubelet kubeadm kubectl
```

##### Other K8s Flavors

Minikube, microk8s, and kind are some other options which focus on
ease-of-install rather than fully featured production deployments.

### Set up a cluster with `kubeadm`

Initialize the cluster.

```sh
POD_NETWORK_CIDR=192.168.0.0/16
sudo kubeadm init --pod-network-cidr $POD_NETWORK_CIDR
```

Add local config.

```sh
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
```

Deploy Calico (or some other networking overlay).

```sh
kubectl apply -f https://docs.projectcalico.org/manifests/calico.yaml
```

Wait for system pods to be running.

```sh
watch kubectl get pods -n kube-system
```

If the calico node doesn't start up, check the logs.

```sh
kubectl get logs -f calico-node-75n2n -n kube-system
```

You might need to disable loose RPF.

```sh
sudo sysctl -w net.ipv4.conf.all.rp_filter=0
```

If you're running a single-node cluster, untaint master node so it's available for scheduling.

```sh
kubectl taint nodes --all node-role.kubernetes.io/master-
```

Check nodes are available.

```sh
kubectl get nodes -o wide
```

## Helm

[Official installation documentation](https://helm.sh/docs/intro/install/)

Download and run the install script.

```sh
curl -fsSL https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | bash -
```

## Nvidia

Add the `[NVIDIA/gpu-operator](https://github.com/NVIDIA/gpu-operator)` repository.

```sh
helm repo add nvidia https://nvidia.github.io/gpu-operator
helm repo update
```

Install `nvidia/gpu-operator`.

```sh
helm install gpu-operator nvidia/gpu-operator
```

Check all the pods are running.

```sh
kubectl get pods -A
```

### GPU Monitoring

[Original documentation](https://github.com/NVIDIA/gpu-operator#gpu-monitoring)

Add `stable` repo.

```sh
helm repo add stable https://kubernetes-charts.storage.googleapis.com
```

<!--
Set up a storage class.

```sh
cat <<EOF | kubectl apply -f -
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: local-storage
provisioner: kubernetes.io/no-provisioner
volumeBindingMode: WaitForFirstConsumer
EOF
```

Create persistent volumes. (Thanks [Prabhu Raja Singh](https://www.devopsart.com/2020/06/step-by-step-to-install-prometheus-in.html)!)

```sh
kubectl apply -f - <<EOF
kind: PersistentVolume
apiVersion: v1
metadata:
  name: prometheus-alertmanager
spec:
  storageClassName:
  capacity:
    storage: 2Gi
  accessModes:
    - ReadWriteOnce
  hostPath:
    path: "/mnt/prometheus-alertmanager"
---
kind: PersistentVolume
apiVersion: v1
metadata:
  name: prometheus-server
spec:
  storageClassName:
  capacity:
    storage: 8Gi
  accessModes:
    - ReadWriteOnce
  hostPath:
    path: "/mnt/prometheus-server"
EOF
```

-->

Create dcgm-exporter config.

```sh
tee dcgmScrapeConfig.yaml <<EOF
- job_name: gpu-metrics
  scrape_interval: 1s
  metrics_path: /metrics
  scheme: http

  kubernetes_sd_configs:
  - role: endpoints
    namespaces:
      names:
      - gpu-operator-resources

  relabel_configs:
  - source_labels: [__meta_kubernetes_pod_node_name]
    action: replace
    target_label: kubernetes_node
EOF
```

Deploy [prometheus-operator](https://github.com/helm/charts/tree/master/stable/prometheus-operator)kub.

```sh
helm install --set additionalScrapeConfigs=./dcgmScrapeConfig.yaml --generate-name stable/prometheus-operator
```

<!--
Deploy Prometheus.

```sh
helm install --set-file extraScrapeConfigs=./dcgmScrapeConfig.yaml  --set alertmanager.persistentVolume.enabled=false --set server.persistentVolume.enabled=false --generate-name stable/prometheus
```

-->

Set up port forwarding for Prometheus.

```sh
kubectl port-forward $(kubectl get pods -lapp=prometheus -ojsonpath='{range .items[*]}{.metadata.name}{"\n"}{end}') 9090 &
```

Deploy Grafana.

```sh
helm install --generate-name stable/grafana
```

Get Grafana admin credentials.

```sh
kubectl get secret -lapp.kubernetes.io/name=grafana -o jsonpath='{.items[0].data.admin-password}' | base64 --decode ; echo
```

Set up port forwarding for Grafana.

```sh
kubectl port-forward $(kubectl get pods -lapp.kubernetes.io/name=grafana -o jsonpath='{.items[0].metadata.name}') 3000 &
```

Open Grafana UI.

```sh
ssh -L 3000:localhost:3000 -i $KEY $USER@$HOST
open http://localhost:3000
```

## High Availability

On each node in the cluster, create service configuration files for `keepalived` and `haproxy`.

```sh
STATE="MASTER" # only one host should be "MASTER". all others should be "BACKUP"
INTERFACE="eno1" # or eth0 or whatever the interface on the host is called
ROUTER_ID="51" # should be the same for all keepalived cluster hosts
PRIORITY=101 # should be higher on master
AUTH_PASS=42 # should be same for all keepalived cluster hosts
APISERVER_VIP= # virtual ip negotated between keepalived cluster hosts
sudo tee /etc/keepalived/keepalived.conf << EOF
! /etc/keepalived/keepalived.conf
! Configuration File for keepalived
global_defs {
    router_id LVS_DEVEL
}
vrrp_script check_apiserver {
  script "/etc/keepalived/check_apiserver.sh"
  interval 3
  weight -2
  fall 10
  rise 2
}

vrrp_instance VI_1 {
    state ${STATE}
    interface ${INTERFACE}
    virtual_router_id ${ROUTER_ID}
    priority ${PRIORITY}
    authentication {
        auth_type PASS
        auth_pass ${AUTH_PASS}
    }
    virtual_ipaddress {
        ${APISERVER_VIP}
    }
    track_script {
        check_apiserver
    }
}
EOF
```

Create the manifest files.

```sh
sudo tee /etc/kubernetes/manifests/keepalived.yaml << EOF
apiVersion: v1
kind: Pod
metadata:
  creationTimestamp: null
  name: keepalived
  namespace: kube-system
spec:
  containers:
  - image: osixia/keepalived:1.3.5-1
    name: keepalived
    resources: {}
    securityContext:
      capabilities:
        add:
        - NET_ADMIN
        - NET_BROADCAST
        - NET_RAW
    volumeMounts:
    - mountPath: /usr/local/etc/keepalived/keepalived.conf
      name: config
    - mountPath: /etc/keepalived/check_apiserver.sh
      name: check
  hostNetwork: true
  volumes:
  - hostPath:
      path: /etc/keepalived/keepalived.conf
    name: config
  - hostPath:
      path: /etc/keepalived/check_apiserver.sh
    name: check
status: {}
EOF

sudo tee /etc/kubernetes/manifests/haproxy.yaml <<EOF
apiVersion: v1
kind: Pod
metadata:
  name: haproxy
  namespace: kube-system
spec:
  containers:
  - image: haproxy:2.1.4
    name: haproxy
    livenessProbe:
      failureThreshold: 8
      httpGet:
        host: localhost
        path: /healthz
        port: ${APISERVER_DEST_PORT}
        scheme: HTTPS
    volumeMounts:
    - mountPath: /usr/local/etc/haproxy/haproxy.cfg
      name: haproxyconf
      readOnly: true
  hostNetwork: true
  volumes:
  - hostPath:
      path: /etc/haproxy/haproxy.cfg
      type: FileOrCreate
    name: haproxyconf
status: {}
EOF
```
