# get the join command from the kube master
CERT_HASH=$(openssl x509 -pubkey -in /etc/kubernetes/pki/ca.crt \
| openssl rsa -pubin -outform der 2>/dev/null \
| openssl dgst -sha256 -hex \
| sed 's/^.* //')
TOKEN=$(kubeadm token list -o json | jq -r '.token' | head -1)
IP=$(kubectl get nodes -lnode-role.kubernetes.io/master -o json \
| jq -r '.items[0].status.addresses[] | select(.type=="InternalIP") | .address')
PORT=6443
echo "sudo kubeadm join $IP:$PORT \
--token=$TOKEN --discovery-token-ca-cert-hash sha256:$CERT_HASH"