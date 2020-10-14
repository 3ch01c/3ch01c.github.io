#!/bin/bash
CPUS=4
MEMORY=4096
DRIVER="virtualbox"
DELETE=0
UPGRADE=0
VERBOSITY=0

printHelp () {
  echo "A script to create a Minikube VM."
	echo ""
	echo "Usage: $0 [--cpus CPUS] [--memory MEMORY] [--driver DRIVER] [--delete] [--upgrade] [-v]"
  echo "  --cpus CPUS number of CPUs (default: $CPUS)"
  echo "  --memory MEMORY Memory in MBs (default: $MEMORY)"
  echo "  --driver DRIVER Virtualization driver (default: $DRIVER)"
  echo "  --delete Delete/overwrite existing Minikube VM"
  echo "  --upgrade Upgrade Minikube"
	echo "  -v, --verbose increase output verbosity"
  echo ""
  exit 0
}

msg_info () {
  if [[ $VERBOSITY == 1 ]]; then echo "$1"; fi
}

while [[ $# -gt 0 ]]; do
	key="$1"
	case $key in
    -h|--help) printHelp ;;
    --cpus) CPUS=$2; shift ;;
    --memory) MEMORY=$2; shift ;;
    --driver) DRIVER=$2; shift ;;
    --delete) DELETE=1 ;;
    --upgrade) UPGRADE=1 ;;
		-v|--verbose) VERBOSITY=1 ;;
	esac
	shift
done

countup () {
  secs=$(expr $(date +%s) - $1)
  printf "\r$2 %02d:%02d:%02d" $((secs/3600)) $(( (secs/60)%60)) $((secs%60))
}

if [[ $DELETE == 1 ]]; then
  msg_info "* Delete old Minikube instance"
  minikube delete
fi
if [[ $UPGRADE == 1 ]]; then
  msg_info "* Upgrade Minikube"
  brew upgrade minikube
fi
msg_info "* Start Minikube"
minikube start --cpus $CPUS --memory $MEMORY --driver $DRIVER #--cni calico --container-runtime containerd
if [ ! -z ${no_proxy+x} ]; then
  # Used by the minikube kvm2 driver.
  if [[ $DRIVER == "kvm2" ]]; then no_proxy=$no_proxy,192.168.39.0/24
  # Used by the minikube docker driver’s first cluster.
  elif [[ $DRIVER == "docker" ]]; then no_proxy=$no_proxy,192.168.49.0/24
  # Used by the minikube VM. Configurable for some hypervisors via --host-only-cidr
  else no_proxy=$no_proxy,192.168.99.0/24; fi
  # Used by service cluster IP’s. Configurable via --service-cluster-ip-range
  no_proxy=$no_proxy,10.96.0.0/12
  msg_info "* Add Kuberntes service IPs to no_proxy and NO_PROXY environment variables. To set them in your environment, source this script or run the following commands:"
  msg_info "  export no_proxy=$no_proxy,192.168.99.0/24,192.168.39.0/24,192.168.49.0/24,10.96.0.0/12"
  msg_info "  export NO_PROXY=$no_proxy"
  export no_proxy=$no_proxy,$(minikube ip)
  export NO_PROXY=$no_proxy
fi
msg_info "* Set Docker environment variables. To set them in your environment, source this script or run the following command:"
msg_info '    eval $(minikube docker-env)'
eval $(minikube docker-env)
if [ ! -z ${no_proxy+x} ]; then
  msg_info "* Add Minikube IP to no_proxy and NO_PROXY environment variables. To set them in your environment, source this script or run the following commands:"
  msg_info "  export no_proxy=$no_proxy,$(minikube ip)"
  msg_info "  export NO_PROXY=$no_proxy"
  export no_proxy=$no_proxy,$(minikube ip)
  export NO_PROXY=$no_proxy
fi

POD=$(kubectl get pod -n kube-system --field-selector=status.phase=Pending -o name)
msg_info "* You can watch progress with the following commands:"
msg_info "    watch kubectl get pod -n kube-system  --field-selector=status.phase=Pending"
msg_info "    kubectl get events -w -n kube-system"
start=$(date +%s)
while [[ $POD != "" ]]; do
  countup $start "* Wait for Minikube to be ready..."
  POD=$(kubectl get pod -n kube-system --field-selector=status.phase=Pending -o name)
done
echo

msg_info "Here's some things you might want to do in your environment:"
msg_info "* Set Docker environment variables:"
msg_info '    eval $(minikube docker-env)'
if [ ! -z ${no_proxy+x} ]; then
  msg_info "* Add Minikube IP to no_proxy and NO_PROXY environment variables:"
  msg_info '    export no_proxy=$no_proxy,$(minikube ip)'
  msg_info '    export NO_PROXY=$no_proxy'
fi
