# install eks and kong
echo " starting to install ... "
mkdir -p /home/ssm-user/eks/
cd /home/ssm-user/eks/
curl -O https://s3.us-west-2.amazonaws.com/amazon-eks/1.31.3/2024-12-12/bin/linux/amd64/kubectl
chmod +x ./kubectl
mkdir -p $HOME/bin && cp ./kubectl $HOME/bin/kubectl && export PATH=$HOME/bin:$PATH
echo 'export PATH=$HOME/bin:$PATH' >> ~/.bashrc

echo " installing eksctl now ..."
echo 
echo
# for ARM systems, set ARCH to: `arm64`, `armv6` or `armv7`
ARCH=amd64
PLATFORM=$(uname -s)_$ARCH

curl -sLO "https://github.com/eksctl-io/eksctl/releases/latest/download/eksctl_$PLATFORM.tar.gz"

# (Optional) Verify checksum
curl -sL "https://github.com/eksctl-io/eksctl/releases/latest/download/eksctl_checksums.txt" | grep $PLATFORM | sha256sum --check

tar -xzf eksctl_$PLATFORM.tar.gz -C /tmp && rm eksctl_$PLATFORM.tar.gz

sudo mv /tmp/eksctl /usr/local/bin

eksctl create cluster \
  --name my-eks-cluster \
  --region us-east-1 \
  --nodegroup-name linux-nodes \
  --node-type t3.medium \
  --nodes 2 \
  --nodes-min 1 \
  --nodes-max 3 \
  --managed

sleep 1200

aws eks update-kubeconfig --region us-east-1 --name my-eks-cluster

## after adding kubectl context
helm repo add kong https://charts.konghq.com &> /dev/null || true
helm repo update
kubectl create namespace kong

helm install kong kong/kong \
  --namespace kong \
  --set ingressController.installCRDs=false \
  --set proxy.type=LoadBalancer
  
  

echo
echo
