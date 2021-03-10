#!/bin/bash

countup () {
  secs=$(expr $(date +%s) - $1)
  printf "\r$2 %02d:%02d:%02d" $((secs/3600)) $(( (secs/60)%60)) $((secs%60))
}

echo "* Deploy nginx load balancer" # https://github.com/kubernetes/ingress-nginx/blob/master/docs/deploy/index.md#using-helm
# https://devopscube.com/setup-ingress-kubernetes-nginx-controller/
# Normally you'd use the addon, but it's [broken](https://github.com/kubernetes/minikube/issues/8756)
# minikube addons enable ingress
kubectl apply -f https://raw.githubusercontent.com/kubernetes/minikube/master/deploy/addons/ingress/ingress-rbac.yaml.tmpl
kubectl apply -f https://raw.githubusercontent.com/kubernetes/minikube/master/deploy/addons/ingress/ingress-configmap.yaml.tmpl
kubectl apply -f https://raw.githubusercontent.com/kubernetes/minikube/68bc935e7fdf0aa00b62940bbc975b2ce70a9ad4/deploy/addons/ingress/ingress-dp.yaml.tmpl
echo "* You can watch progress with the following commands:"
echo "    watch kubectl get pod -n kube-system -lapp.kubernetes.io/name=ingress-nginx -lapp.kubernetes.io/component=controller"
echo "    kubectl get events -w -n kube-system -lapp.kubernetes.io/name=ingress-nginx -lapp.kubernetes.io/component=controller"
POD=$(kubectl get pod -n kube-system -lapp.kubernetes.io/name=ingress-nginx -lapp.kubernetes.io/component=controller --field-selector=status.phase=Running -o name)
start=$(date +%s)
while [[ $POD == "" ]]; do
  countup $start "* Wait for load balancer to be ready..."
  POD=$(kubectl get pod -n kube-system -lapp.kubernetes.io/name=ingress-nginx -lapp.kubernetes.io/component=controller --field-selector=status.phase=Running -o name)
done
echo

echo "* Create dev namespace" # https://devopscube.com/setup-ingress-kubernetes-nginx-controller/
kubectl create namespace dev

echo "* Create demo deployment" # https://devopscube.com/setup-ingress-kubernetes-nginx-controller/
kubectl apply -f - <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: hello-app
  namespace: dev
spec:
  selector:
    matchLabels:
      app: hello
  replicas: 3
  template:
    metadata:
      labels:
        app: hello
    spec:
      containers:
      - name: hello
        image: "gcr.io/google-samples/hello-app:2.0"
EOF

echo "* Create demo service" # https://devopscube.com/setup-ingress-kubernetes-nginx-controller/
kubectl apply -f - <<EOF
apiVersion: v1
kind: Service
metadata:
  name: hello-service
  namespace: dev
  labels:
    app: hello
spec:
  type: ClusterIP
  selector:
    app: hello
  ports:
  - port: 80
    targetPort: 8080
    protocol: TCP
EOF

echo "* Create ingress for demo service" # https://devopscube.com/setup-ingress-kubernetes-nginx-controller/
HOSTNAME="example.local"
echo "* Update /etc/hosts to route ingress hostname to the Minikube IP:"
echo "  sudo sed -E -i '' 's/(.+) "$HOSTNAME"/"$(minikube ip)" "$HOSTNAME"/g' /etc/hosts"
kubectl apply -f - <<EOF
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: test-ingress
  namespace: dev
spec:
  rules:
  - host: $HOSTNAME
    http:
      paths:
      - backend:
          serviceName: hello-service
          servicePort: 80
EOF

# Access app
echo "* Open demo app web page"
open "https://$HOSTNAME"
