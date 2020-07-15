#!/bin/bash
# Install Kubernetes
PLATFORM=$(uname -s)
BREW=$(which brew)
TOOL="minikube"
HOSTNAME=kube-manager
POD_NETWORK_CIDR=192.168.0.0/24

unsupported() {
    echo $1
    exit 1
}

echo "* Tool: $TOOL"
echo "* Platform: $PLATFORM"
if [[ $TOOL == "minikube" ]]; then
    # Install Minikube
    if [[ $PLATFORM == "Darwin" ]]; then
        # macOS
        if [[ $BREW == "" ]]; then
            echo "* Download latest version of kubectl"
            curl -LO "https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/darwin/amd64/kubectl"
            echo "* Make the kubectl binary executable"
            chmod +x ./kubectl
            echo "* Move the kubectl binary to your PATH"
            sudo mv ./kubectl /usr/local/bin/kubectl
            echo "* Download latest version of minikube"
            curl -Lo minikube https://storage.googleapis.com/minikube/releases/latest/minikube-darwin-amd64
            echo "* Make the minikube binary executable"
            chmod +x minikube
            echo "* Move the minikube binary to your PATH."
            sudo mv minikube /usr/local/bin
        else
            echo "* Install kubectl with Homebrew"
            brew install kubernetes-cli # or kubectl
            brew link --overwrite kubernetes-cli
            echo "* Install minikube with Homebrew"
            brew install minikube
        fi
    elif [[ $PLATFORM == "Linux" ]]; then
        # Linux
        echo " * Check if virtualization is supported"
        VMX=$(grep -oE 'vmx|svm' /proc/cpuinfo)
        if [[ $VMX != "" ]]; then
            if [[ $BREW != "" ]]; then
                echo "* Install minikube with Homebrew"
                brew install minikube
            else
                unsupported "This script only supports installing $TOOL on $PLATFORM via Homebrew."
            fi
        else
            unsupported "Your hardware doesn't support virtualization."
        fi
    else
        unsupported "This script doesn't support installing $TOOL on $PLATFORM yet."
    fi
    echo "* start up a local Kubernetes cluster"
    minikube start #\
    # --driver=virtualbox \
    # --kubernetes-version v1.18.0 \
    # --network-plugin=cni \
    # --enable-default-cni \
    # --container-runtime=containerd \ # cri-o \
    # --bootstrapper=kubeadm
    echo "* check the status of the cluster"
    minikube status
    # To stop your cluster
    # minikube stop
    # To delete the local Minikube cluster
    # minikube delete
elif [[ $TOOL == "k8s" ]]; then
    # Install k8s
    if [[ $PLATFORM == "Linux" ]]; then
        # Disable proxy for IP addresses
        #if [[ ! -z ${no_proxy+x} ]]; then
        #    export no_proxy=$no_proxy,0,1,2,3,4,5,6,7,8,9
        #fi
        echo "* Install apt package"
        if [ -d /etc/apt ]; then
            curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add
            sudo apt-add-repository "deb http://apt.kubernetes.io/ kubernetes-xenial main"
            sudo apt install kubeadm kubectl -y
        fi
        # Turn off swap
        sudo swapoff -a
        # Set hostname to kube-manager or kube-worker##
        #sudo hostnamectl set-hostname $HOSTNAME
        # Initialize master
        sudo kubeadm init #--pod-network-cidr=$CIDR
        mkdir -p $HOME/.kube
        sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
        sudo chown $(id -u):$(id -g) $HOME/.kube/config
        # Apply calico network
        kubectl apply -f https://docs.projectcalico.org/manifests/calico.yaml
        # Wait for all pods to be running
        watch kubectl get pods --all-namespaces
        # Make master node available for scheduling
        kubectl taint nodes --all node-role.kubernetes.io/master-
        # Check node is available
        kubectl get nodes -o wide
    else
        unsupported "This script doesn't support installing $TOOL the hard way on $PLATFORM yet."
    fi
fi
# Test to ensure the kubectl version you installed is up-to-date
kubectl version --client
# create a Kubernetes Deployment using an existing image named echoserver, which
# is a simple HTTP server and expose it on port 8080 using --port.
kubectl create deployment hello-k8s --image=k8s.gcr.io/echoserver:1.10
# To access the hello-k8s Deployment, expose it as a Service. The option --type=NodePort specifies the type of the Service.
kubectl expose deployment hello-k8s --type=NodePort --port=8080
# The hello-k8s Pod is now launched but you have to wait until the Pod is up before accessing it via the exposed Service.
# Check if the Pod is up and running:
kubectl get pods
# If the output shows the STATUS as ContainerCreating, the Pod is still being
# created:
# If the output shows the STATUS as Running, the Pod is now up and running:
echo "Waiting for pod to be running..."
while [[ $POD == "" ]]; do
  POD=$(kubectl get pods --field-selector=status.phase=Running -o name)
done
# Get the URL of the exposed Service to view the Service details
URL=$(minikube service hello-k8s --url)
echo "$POD is running at $URL"
which open && open $URL
# Delete the hello-k8s Service
kubectl delete service hello-k8s
# Delete the hello-k8s Deployment
kubectl delete deployment hello-k8s
