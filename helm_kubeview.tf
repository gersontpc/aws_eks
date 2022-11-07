# Doc
# https://artifacthub.io/packages/helm/cowboysysop/kubeview

resource "helm_release" "kubeview" {
  namespace        = "kube-system"
  create_namespace = false

  name       = "kubeview"
  repository = "https://cowboysysop.github.io/charts/"
  chart      = "kubeview"
  # version    = "2.6.0"

  depends_on = [
    aws_eks_cluster.master,
    aws_eks_addon.kubeproxy,
    kubernetes_config_map.aws-auth,
    aws_eks_node_group.this
  ]
}
