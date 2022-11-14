#!/bin/bash -e

set -o xtrace

yum install -y amazon-ssm-agent
systemctl enable amazon-ssm-agent
systemctl start amazon-ssm-agent

echo "Join to Cluster"
/etc/eks/bootstrap.sh --b64-cluster-ca '${B64_CLUSTER_CA}' --apiserver-endpoint '${APISERVER_ENDPOINT}' '${CLUSTER_ID}';
echo "Node joined to cluster"

systemctl status kubelet
