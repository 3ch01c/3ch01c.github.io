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
- [Monitoring](#monitoring)
  - [Prometheus](#prometheus)
- [Nvidia](#nvidia)
  - [GPU Monitoring](#gpu-monitoring)
  - [kubeflow](#kubeflow)
- [High Availability](#high-availability)
- [Role Based Access Control (RBAC)](#role-based-access-control-rbac)
  - [User Certificates](#user-certificates)
  - [Service Accounts](#service-accounts)
  - [Roles & Role Bindings](#roles--role-bindings)
  - [Accessing multiple clusters (contexts)](#accessing-multiple-clusters-contexts)
- [References](#references)

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
sudo apt-mark hold kubelet kubeadm kubectl containerd.io docker-ce docker-ce-cli
```

If you ever want to upgrade those packages, you can unhold them.

```sh
sudo apt-mark unhold kubelet kubeadm kubectl containerd.io docker-ce docker-ce-cli
sudo apt update
sudo apt upgrade kubelet kubeadm kubectl containerd.io docker-ce docker-ce-cli -y
sudo apt-mark hold kubelet kubeadm kubectl containerd.io docker-ce docker-ce-cli
```

##### Other K8s Flavors

[Docker Desktop](https://www.docker.com/products/docker-desktop) is a popular choice for developers.

[Minikube](https://minikube.sigs.k8s.io/docs/) is single-node Kubernetes in a virtual machine. I recommend this because [Docker for Mac doesn't honor `NO_PROXY` environment variables](https://github.com/docker/for-mac/issues/2732), but you might not use proxies, you lucky dog.

[k3s](https://k3s.io/) is a lightweight Kubernetes distribution optimized for Raspberry Pis and other low-end computing hardware. It removes a lot of features you probably don't use making it extremely efficient.

[microk8s](https://microk8s.io/) is an Ubuntu-based lightweight Kubernetes distribution.

[kind](https://kind.sigs.k8s.io/) stands for "Kubernetes in Docker". One advantage over Minikube is that you can run multi-node clusters, but it requires Docker to be installed on the host. [Until recently](https://www.tcg.com/blog/yes-you-can-run-docker-and-virtualbox-on-windows-10-home/), VirtualBox doesn't play well with Docker on Windows so that's why I don't use it.

[Google Kubernetes Engine (GKE)](https://cloud.google.com/kubernetes-engine) / [Elastic Kubernetes Service(EKS)](https://aws.amazon.com/eks/) / [Azure Kubernetes Service (AKS)](https://azure.microsoft.com/en-us/services/kubernetes-service/) are some of the major cloud versions of Kubernetes. They make it easy to use K8s without the all the infrastructure setup. In theory, at least.

[OpenShift](https://www.redhat.com/en/technologies/cloud-computing/openshift) is Red Hat's enterprise Kubernetes platform. This might also be easier to use if you don't mind ponying up the bills.

### Set up a cluster with `kubeadm`

Initialize the [control-plane node](https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/create-cluster-kubeadm/). The control-plane node is the machine where the control plane components run, including etcd (the cluster database) and the API Server (which the kubectl command line tool communicates with).

- Make sure the `--pod-network-cidr` doesn't conflict with your LAN network (e.g., if you're already using 192.168.0.0/16 for your host LAN, use 10.0.0.0/16 or something else that's available). You might need to use a specific pod network CIDR depending on your [pod network add-on](https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/create-cluster-kubeadm/#pod-network).
- The `--apiserver-advertise-address` is the IP address of the interfaces your API server communicates on. It defaults to the interface of the default gateway.
- If you're setting up a high-availability cluster, the `--control-plane-endpoint` is the address of the control plane load balancer.
- If you're behind a proxy, make sure your `no_proxy` environment variable has the k8s IP addresses including your node IP(s) and pod network.

```sh
# export no_proxy=$no_proxy,192.168.0.0/16,172.31.27.0 # ignore proxy for k8s IPs
sudo kubeadm init --pod-network-cidr 192.168.0.0/16 # single-node default
# sudo kubeadm init --pod-network-cidr 192.168.0.0/16 --apiserver-advertise-address=172.31.27.0 # single-node non-default interface
# sudo kubeadm init --pod-network-cidr 192.168.0.0/16 --control-plane-endpoint k8s-example-1234567890.us-west-1.elb.amazonaws.com # ha cluster
```

### Troubleshooting

1. If you get the error `rpc error: code = Unimplemented desc = unknown service runtime.v1alpha2.RuntimeService`, check `/etc/containerd/config.toml` and comment out the following line if it exists:

   ```
   disabled_plugins = ["cri"]
   ```

1. Set your proxy environment variables. 

   ```sh
   sudo systemctl set-environment http_proxy=http://proxy.example.com:8080
   sudo systemctl set-environment https_proxy=http://proxy.example.com:8080
   ```

1. Then, restart containerd.

   ```sh
   sudo systemctl restart containerd
   ```
   
After initialization completes, copy the cluster configuration to your local account so you can communicate with the cluster.

```sh
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
```

You also need to save the `kubeadm join` command from the output in order to join worker nodes to your cluster. If you forget to save the join command, you can generate a new one.

```sh
kubeadm token create --print-join-command > join.sh && chmod +x join.sh
```

Now, you can use `kubectl`.

```sh
kubectl get pods -A
```

You might notice some pods in `Pending` status because you need to deploy a pod network add-on like [Calico](https://docs.projectcalico.org/getting-started/kubernetes/quickstart).

```sh
kubectl create -f https://projectcalico.docs.tigera.io/manifests/tigera-operator.yaml
kubectl create -f https://projectcalico.docs.tigera.io/manifests/custom-resources.yaml
```

Watch the pods until they're all in the 'Running' state.

```sh
watch kubectl get pods -A
```

If the `calico-node` pod is failing with a `CrashLoopBack` state, check its logs.

```sh
kubectl logs -f calico-node-75n2n -n kube-system
```

If you see an error `Kernel's RPF check is set to 'loose'.`, you can change disable the check by setting the environment variable `IgnoreLooseRPF` to `true` in the `calico-node` [DaemonSet](https://kubernetes.io/docs/concepts/workloads/controllers/daemonset/). (Thanks [Alex](https://alexbrand.dev/post/creating-a-kind-cluster-with-calico-networking/)!)

```sh
kubectl -n kube-system set env daemonset/calico-node FELIX_IGNORELOOSERPF=true
```

If you're having other issues, check the event logs.

```sh
kubectl get events --sort-by='.metadata.creationTimestamp' -A
```

If you're running a single-node cluster, untaint the master node so it's available for scheduling.

```sh
kubectl taint nodes --all node-role.kubernetes.io/master-
```

Check nodes are available.

```sh
kubectl get nodes -o wide
```

See all resources in your cluster.

```sh
kubectl get all -A -o wide
```

If you ever want to get rid of your cluster, use `kubeadm reset`.

```sh
sudo kubeadm reset
```

## Helm

[Official installation documentation](https://helm.sh/docs/intro/install/)

Download and run the install script.

```sh
curl -fsSL https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | bash -
helm init --client-only
```

## Monitoring

### Prometheus

Add the Bitnami Helm repo.

```sh
helm repo add bitnami https://charts.bitnami.com/bitnami
```

Install the Prometheus chart.

```sh
helm install prometheus bitnami/kube-prometheus
```

Watch the Prometheus Operator Deployment status using the command:

    kubectl get deploy -w --namespace default -l app.kubernetes.io/name=kube-prometheus-operator,app.kubernetes.io/instance=prometheus

Watch the Prometheus StatefulSet status using the command:

    kubectl get sts -w --namespace default -l app.kubernetes.io/name=kube-prometheus-prometheus,app.kubernetes.io/instance=prometheus

Prometheus can be accessed via port "9090" on the following DNS name from within your cluster:

    prometheus-kube-prometheus-prometheus.default.svc.cluster.local

To access Prometheus from outside the cluster execute the following commands:

    echo "Prometheus URL: http://127.0.0.1:9090/"
    kubectl port-forward --namespace default svc/prometheus-kube-prometheus-prometheus 9090:9090

Watch the Alertmanager StatefulSet status using the command:

    kubectl get sts -w --namespace default -l app.kubernetes.io/name=kube-prometheus-alertmanager,app.kubernetes.io/instance=prometheus

Alertmanager can be accessed via port "9093" on the following DNS name from within your cluster:

    prometheus-kube-prometheus-alertmanager.default.svc.cluster.local

To access Alertmanager from outside the cluster execute the following commands:

    echo "Alertmanager URL: http://127.0.0.1:9093/"
    kubectl port-forward --namespace default svc/prometheus-kube-prometheus-alertmanager 9093:9093

To remove `kube-prometheus`:

```sh
helm delete prometheus
```

## Nvidia

[Official installation guide](https://docs.nvidia.com/datacenter/cloud-native/gpu-operator/getting-started.html#operator-install-guide)

Uninstall pre-existing Nvidia drivers.

```sh
# On Ubuntu
sudo apt remove nvidia-driver-450 # might be a different version number
sudo apt autoremove
```

Load `i2c_core` and `ipmi_msghandler` modules.

```sh
sudo modprobe -a i2c_core ipmi_msghandler
```

Make sure a container runtime (e.g., [Docker](#docker)) is installed.

```sh
docker version
```

If using Ubuntu 18.04 or later, disable the `nouveau` driver.

```sh
cat << EOF | sudo tee /etc/modprobe.d/blacklist-nouveau.conf
blacklist nouveau
options nouveau modeset=0
EOF
sudo update-initramfs -u
```

Add the [NVIDIA/gpu-operator](https://github.com/NVIDIA/gpu-operator) repository.

```sh
helm repo add nvidia https://nvidia.github.io/gpu-operator
helm repo update
```

Run the following command to check if [Node Feature Discovery (NFD)](https://github.com/kubernetes-sigs/node-feature-discovery) is already enabled. If it returns resources, it's enabled. Otherwise, it's not.

```sh
kubectl -n node-feature-discovery get all
```

Add custom configuration values.

```yaml
# values.yml
---
nfd:
  enabled: true # false if NFD is already enabled
driver:
  env:
    - name: http_proxy
      value: http://proxyout.example.com
    - name: https_proxy
      value: http://proxyout.example.com
toolkit:
  env:
    - name: http_proxy
      value: http://proxyout.example.com
    - name: https_proxy
      value: http://proxyout.example.com
devicePlugin:
  env:
    - name: http_proxy
      value: http://proxyout.example.com
    - name: https_proxy
      value: http://proxyout.example.com
dcgmExporter:
  args:
    - "-f"
    - "/etc/dcgm-exporter/default-counters.csv"
  env:
    - name: http_proxy
      value: http://proxyout.example.com
    - name: https_proxy
      value: http://proxyout.example.com
    - name: NVIDIA_VISIBILE_DEVICES
      value: "1"
gfd:
  env:
    - name: http_proxy
      value: http://proxyout.example.com
    - name: https_proxy
      value: http://proxyout.example.com
```

Install `nvidia/gpu-operator`. If NFD is already enabled, add `--set nfd.enabled=false` to the command.

```sh
kubectl create ns gpu-operator
helm install -n gpu-operator -f values.yml -n gpu-operator gpu-operator nvidia/gpu-operator # if nfd is not enabled
# helm install -n gpu-operator -f values.yml -n gpu-operator --set nfd.enabled=true gpu-operator nvidia/gpu-operator # if nfd is enabled
```

Check all the pods are running. This can take several minutes.

```sh
watch kubectl get pods -A
```

If you get a `CrashLoopBackOff` with the `nvidia-driver-daemonset` pod, check the logs.

```
kubectl logs -n gpu-operator -f nvidia-driver-daemonset-k5mh2
```

If there's an error `Could not unload NVIDIA driver kernel modules, driver is in use`, you probably need to reboot the node.

```sh
sudo reboot
```

If you ever need to uninstall/reinstall the GPU operator, reboot the node to finish unloading the GPU drivers.

```
helm delete -n gpu-operator gpu-operator
sudo reboot
```

### GPU Monitoring

[Original documentation](https://github.com/NVIDIA/gpu-operator#gpu-monitoring)

Create [dcgm-exporter](https://github.com/NVIDIA/gpu-monitoring-tools#dcgm-exporter) config.

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
      - gpu-operator

  relabel_configs:
  - source_labels: [__meta_kubernetes_pod_node_name]
    action: replace
    target_label: kubernetes_node
EOF
```

Deploy [prometheus-operator](https://github.com/helm/charts/tree/master/stable/prometheus-operator).

```sh
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
kubectl create ns prom-operator
helm install -n prom-operator --set additionalScrapeConfigs=./dcgmScrapeConfig.yaml prom-operator prometheus-community/kube-prometheus-stack
```

Optional: add port forwarding for Prometheus.

```sh
kubectl port-forward $(kubectl get pods -lapp=prometheus -ojsonpath='{range .items[*]}{.metadata.name}{"\n"}{end}') 9090 &
```

Get Grafana admin credentials.

```sh
export GRAFANA_PASSWORD=$(kubectl get secret -n prom-operator -lapp.kubernetes.io/name=grafana -o jsonpath='{.items[0].data.admin-password}' | base64 --decode ; echo)
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

Optional: Set up port forwarding for dcgm exporter.

```sh
kubectl port-forward $(kubectl get pods -lapp=nvidia-dcgm-exporter -n gpu-operator-resources -o jsonpath='{.items[0].metadata.name}') -n gpu-operator-resources 9400 &
```

### kubeflow

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

## Role Based Access Control (RBAC)

In a real world environment, you probably don't want to use admin credentials just like you wouldn't use root credentials. To do so, create a [user certificate](https://kubernetes.io/docs/reference/access-authn-authz/certificate-signing-requests/#normal-user) or [`ServiceAccount`](https://kubernetes.io/docs/tasks/configure-pod-container/configure-service-account/).

### User Certificates

To set up a user certificate, generate a certificate signing request, approve it, and export the certificate.

```sh
openssl req -newkey rsa:2048 -nodes -sha256 -keyout podreader.key -out podreader.csr -subj /CN=podreader@example.com
cat <<EOF | kubectl apply -f -
apiVersion: certificates.k8s.io/v1
kind: CertificateSigningRequest
metadata:
  name: podreader
spec:
  groups:
  - system:authenticated
  request: $(cat podreader.csr | base64 | tr -d "\n")
  signerName: kubernetes.io/kube-apiserver-client
  usages:
  - client auth
EOF
kubectl certificate approve podreader
kubectl get csr podreader -o jsonpath='{.status.certificate}'| base64 -d > podreader.crt
```

### Service Accounts

To set up a `ServiceAccount`, use `kubectl`.

```sh
kubectl create serviceaccount podreader
```

To get the authentication token for a `ServiceAccount`:

```sh
TOKEN=$(kubectl describe secrets "$(kubectl describe serviceaccount podreader | grep -i Tokens | awk '{print $2}')" | grep token: | awk '{print $2}')
```

### Roles & Role Bindings

Regardless if you use certificates or service accounts, you need to create a `Role` (or `ClusterRole` if it's for cluster-wide operations) defining the permissions, and a `RoleBinding` (or `ClusterRoleBinding`) to associate the account with the role (thereby giving it permissions).

```
kubectl create clusterrole podreader --verb=get --verb=list --verb=watch --resource=pods
kubectl create clusterrolebinding podreader --clusterrole=podreader --user=myuser # if using user certificate
#kubectl create clusterrolebinding podreader --clusterrole=podreader --serviceaccount=default:podreader # if using serviceaccount
```

### Accessing multiple clusters (contexts)

On the machine you'll be using `kubectl`, create a new `cluster`, `user`, and/or `context` as needed.

```sh
kubectl config set-cluster development --server=https://1.2.3.4 --certificate-authority=fake-ca-file
kubectl config set-credentials developer --client-certificate=/path/to/user.crt --client-key=/path/to/user.key # if using certificate authentication
# kubectl config set-credentials developer --token=$TOKEN # if using token authentication
kubectl config set-context dev --cluster=development --user=developer --namespace=default
```

To use a specific context:

```sh
kubectl config use-context development
```

To see the current context's configuration:

```sh
kubectl config view --minify
```

## References

- [NVIDIA GPU Operator](https://nvidia.github.io/gpu-operator/)
- [NVIDIA GPU Operator Install Guide](https://docs.nvidia.com/datacenter/cloud-native/gpu-operator/getting-started.html#operator-install-guide)
- [Kubeflow](https://www.kubeflow.org/docs/started/k8s/overview/)
- [Resource metrics pipeline](https://kubernetes.io/docs/tasks/debug-application-cluster/resource-metrics-pipeline/)
- [Node Problem Detector](https://github.com/kubernetes/node-problem-detector)
- [Kubernetes monitoring with Prometheus, the ultimate guide](https://sysdig.com/blog/kubernetes-monitoring-prometheus/)
- [Traefik](https://github.com/traefik/traefik/blob/master/docs/content/getting-started/install-traefik.md)
- [Prometheus Operator](https://github.com/prometheus-operator/kube-prometheus)
- [Nvidia GPU Grafana Dashboard](https://grafana.com/grafana/dashboards/6387)
- [NVIDIA Prometheus Exporter](https://github.com/BugRoger/nvidia-exporter)
- [DCGM Exporter](https://ngc.nvidia.com/catalog/containers/nvidia:k8s:dcgm-exporter)
- [Configure Access to Multiple Clusters](https://kubernetes.io/docs/tasks/access-application-cluster/configure-access-multiple-clusters/)
- [Create user in Kubernetes for kubectl](https://stackoverflow.com/a/55534445)
- [Certificate Signing Requests](https://kubernetes.io/docs/reference/access-authn-authz/certificate-signing-requests/#normal-user)
