resource "helm_release" "kube-state-metrics" {

  name             = "kube-state-metrics"
  namespace        = "kube-system"
  create_namespace = true
  repository       = "https://prometheus-community.github.io/helm-charts"
  chart            = "kube-state-metrics"

  set {
    name  = "replicas"
    value = 1
  }
  set {
    name  = "prometheus.monitor.enabled"
    value = false
  }
  set {
    name  = "metricLabelsAllowlist[0]"
    value = "nodes=[*],pods=[*]"
  }
  set {
    name  = "metricAnnotationsAllowList[0]"
    value = "nodes=[*],pods=[*]"
  }

  depends_on = [
    aws_eks_cluster.master,
    aws_eks_node_group.this
  ]
}

resource "helm_release" "metrics_server" {

  name       = "metrics-server"
  repository = "https://charts.bitnami.com/bitnami"
  chart      = "metrics-server"
  namespace  = "kube-system"

  set {
    name  = "apiService.create"
    value = "true"
  }

  depends_on = [
    aws_eks_cluster.master,
    aws_eks_node_group.this
  ]
}
