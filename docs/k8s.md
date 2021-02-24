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

Install [Docker](https://docs.docker.com/engine/install/ubuntu/).

```sh
# On Ubuntu
sudo apt-get update
sudo apt-get install \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg-agent \
    software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo apt-key fingerprint 0EBFCD88
# If using 64-bit Arm, change arch=arm64. armhf no longer supported in Ubuntu 20.04.
sudo add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"
sudo apt-get update
sudo apt-get install docker-ce docker-ce-cli containerd.io
```

It's recommended to pin package versions.

```sh
sudo apt-mark hold docker-ce docker-ce-cli containerd.io
```

Test Docker works.

```sh
sudo docker run hello-world
```

#### K8s tools

##### Vanilla K8s

Allow iptables to see bridged traffic.

```sh
cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
br_netfilter
EOF
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF
sudo sysctl --system
```

Every node needs `kubelet`. Master nodes also need [`kubeadm`](#https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/) and `kubectl`.

```sh
# On Ubuntu
sudo apt-get update && sudo apt-get install -y apt-transport-https curl
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
cat <<EOF | sudo tee /etc/apt/sources.list.d/kubernetes.list
deb https://apt.kubernetes.io/ kubernetes-xenial main
EOF
sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl
```

It's recommended to pin package versions.

```sh
sudo apt-mark hold kubelet kubeadm kubectl
```

##### Other K8s Flavors

Minikube, microk8s, and kind are some other options which focus on
ease-of-install rather than fully featured production deployments.

### Set up a cluster with `kubeadm`

Initialize the [control-plane node](https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/create-cluster-kubeadm/). The control-plane node is the machine where the control plane components run, including etcd (the cluster database) and the API Server (which the kubectl command line tool communicates with).

* Make sure the `--pod-network-cidr` doesn't conflict with your LAN network (e.g., if you're already using 192.168.0.0/16 for your host LAN, use 10.0.0.0/16 or something else that's available). You might need to use a specific pod network CIDR depending on your [pod network add-on](https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/create-cluster-kubeadm/#pod-network).
* The `--apiserver-advertise-address` is only required if your cluster communicates with this node's API server on a different interface than the default gateway.
* The `--control-plane-endpoint` is only required if you're going to set up a high-availability cluster and should point to the address of a control plane load balancer.

```sh
sudo kubeadm init --pod-network-cidr 192.168.0.0/16 --apiserver-advertise-address=172.31.27.0 --control-plane-endpoint k8s-example-1234567890.us-west-1.elb.amazonaws.com
```

After initialization completes, copy the cluster configuration to your local account so you can communicate with the cluster, and save the `kubeadm join` command from the output which you'll need to join worker nodes to your cluster. (If you don't save the join command, you can generate a new token with `kubeadm token create --print-join-command`.)

```sh
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
```

Now, you can use `kubectl`.

```sh
kubectl get pods -n kube-system
```

You might notice some pods in `Pending` status because you need to deploy a pod network add-on like [Calico](https://docs.projectcalico.org/getting-started/kubernetes/quickstart).

```sh
kubectl create -f https://docs.projectcalico.org/manifests/tigera-operator.yaml
kubectl create -f https://docs.projectcalico.org/manifests/custom-resources.yaml
```

Wait for system pods to be in 'Running' state.

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

### Prerequisites

If using Ubuntu 18.04 or later, disable the `nouveau` driver.

```sh
sudo cat << EOF > /etc/modprobe.d/blacklist-nouveau.conf
blacklist nouveau
options nouveau modeset=0
EOF
sudo update-initramfs -u
```

### Installation

Add the [NVIDIA/gpu-operator](https://github.com/NVIDIA/gpu-operator) repository.

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

If you get a `CrashLoopBackOff` with the `nvidia-driver-daemonset` pod, check the logs.

```
kubectl logs -f nvidia-driver-daemonset-k5mh2 -n gpu-operator-resources
```

If there's an error `Could not unload NVIDIA driver kernel modules, driver is in use`, try unloading the Nvidia module on the host.

```sh
sudo systemctl isolate multi-user.target
sudo modprobe -r nvidia-drm
```

If that doesn't work, try uninstalling the driver.

```sh
sudo apt remove nvidia-driver-450
sudo apt autoremove
```

### GPU Monitoring

[Original documentation](https://github.com/NVIDIA/gpu-operator#gpu-monitoring)

Add `stable` repo.

```sh
helm repo add stable https://charts.helm.sh/stable
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
helm repo add grafana https://grafana.github.io/helm-charts
helm install --generate-name grafana
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
