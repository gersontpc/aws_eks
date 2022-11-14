resource "helm_release" "virtual_pod_autoscaler" {
  namespace  = "kube-system"
  name       = "vpa"
  repository = "https://charts.fairwinds.com/stable"
  chart      = "vpa"
  version    = "0.11"

  set {
    name  = "recommender.enabled"
    value = "true"
  }

  set {
    name  = "updater.enabled"
    value = "false"
  }

  set {
    name  = "admissionController.enabled"
    value = "false"
  }

  depends_on = [
    aws_eks_cluster.master,
    aws_eks_node_group.this
  ]
}
