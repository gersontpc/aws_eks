# Doc
# https://artifacthub.io/packages/helm/aws/aws-node-termination-handler

# resource "helm_release" "node_termination_handler" {
#   namespace        = "kube-system"
#   create_namespace = false

#   name       = "aws-node-termination-handler"
#   repository = "https://aws.github.io/eks-charts/"
#   chart      = "aws-node-termination-handler"
#   version    = "0.15.0"

#   depends_on = [
#     aws_eks_cluster.master,
#     aws_eks_addon.kubeproxy,
#     kubernetes_config_map.aws-auth,
#     aws_eks_node_group.this
#   ]
# }