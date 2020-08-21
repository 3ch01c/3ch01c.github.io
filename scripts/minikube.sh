#!/bin/bash
CPUS=4
MEMORY=4096
DRIVER="virtualbox"

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

if [ ! -z ${DELETE+x} ]; then
  if [ ! -z ${VERBOSITY+x} ]; then echo "* Delete old Minikube instance"; fi
  minikube delete
fi
if [ ! -z ${UPGRADE+x} ]; then
  if [ ! -z ${VERBOSITY+x} ]; then echo "* Upgrade Minikube"; fi
  brew upgrade minikube
fi
if [ ! -z ${VERBOSITY+x} ]; then echo "* Start Minikube"; fi
minikube start --cpus $CPUS --memory $MEMORY --driver $DRIVER #--cni calico --container-runtime containerd
if [ ! -z ${VERBOSITY+x} ]; then echo "* Set Docker environment variables. To set them in your environment, source this script or run the following command:"; fi
if [ ! -z ${VERBOSITY+x} ]; then echo '    eval $(minikube docker-env)'; fi
eval $(minikube docker-env)
if [ ! -z ${no_proxy+x} ]; then
  if [ ! -z ${VERBOSITY+x} ]; then echo "* Add Minikube IP to no_proxy and NO_PROXY environment variables. To set them in your environment, source this script or run the following commands:"; fi
  if [ ! -z ${VERBOSITY+x} ]; then echo "  export no_proxy=$no_proxy,$(minikube ip)"; fi
  if [ ! -z ${VERBOSITY+x} ]; then echo "  export NO_PROXY=$no_proxy"; fi
  export no_proxy=$no_proxy,$(minikube ip)
  export NO_PROXY=$no_proxy
fi

POD=$(kubectl get pod -n kube-system --field-selector=status.phase=Pending -o name)
if [ ! -z ${VERBOSITY+x} ]; then echo "* You can watch progress with the following commands:"; fi
if [ ! -z ${VERBOSITY+x} ]; then echo "    watch kubectl get pod -n kube-system  --field-selector=status.phase=Pending"; fi
if [ ! -z ${VERBOSITY+x} ]; then echo "    kubectl get events -w -n kube-system"; fi
start=$(date +%s)
while [[ $POD != "" ]]; do
  countup $start "* Wait for Minikube to be ready..."
  POD=$(kubectl get pod -n kube-system --field-selector=status.phase=Pending -o name)
done
echo

if [ ! -z ${VERBOSITY+x} ]; then echo "Here's some things you might want to do in your environment:"; fi
if [ ! -z ${VERBOSITY+x} ]; then echo "* Set Docker environment variables:"; fi
if [ ! -z ${VERBOSITY+x} ]; then echo '    eval $(minikube docker-env)'; fi
if [ ! -z ${no_proxy+x} ]; then
  if [ ! -z ${VERBOSITY+x} ]; then echo "* Add Minikube IP to no_proxy and NO_PROXY environment variables:"; fi
  if [ ! -z ${VERBOSITY+x} ]; then echo '    export no_proxy=$no_proxy,$(minikube ip)'; fi
  if [ ! -z ${VERBOSITY+x} ]; then echo '    export NO_PROXY=$no_proxy'; fi
fi
