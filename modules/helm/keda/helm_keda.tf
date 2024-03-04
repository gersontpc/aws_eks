resource "helm_release" "keda" {
  namespace        = "keda"
  create_namespace = true

  name       = "keda"
  repository = "https://kedacore.github.io/charts"
  chart      = "keda"
  version    = "2.8.2"

  depends_on = [
    aws_eks_cluster.master,
    aws_eks_node_group.this
  ]
}
