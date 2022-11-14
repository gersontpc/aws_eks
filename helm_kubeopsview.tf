resource "helm_release" "kube-ops-view" {

  namespace        = "kube-system"
  create_namespace = true

  name       = "kube-ops-view"
  repository = "https://christianknell.github.io/helm-charts"
  chart      = "kube-ops-view"
  # version    = "2.6.0"

  depends_on = [
    aws_eks_cluster.master,
    aws_eks_node_group.this
  ]
}
