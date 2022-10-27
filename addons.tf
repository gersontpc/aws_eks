resource "aws_eks_addon" "cni" {
  cluster_name = aws_eks_cluster.master.name
  addon_name   = "vpc-cni"

  addon_version = var.addon_cni_version

  resolve_conflicts = "OVERWRITE"

  depends_on = [
    kubernetes_config_map.aws-auth
  ]

}

resource "aws_eks_addon" "coredns" {
  cluster_name = aws_eks_cluster.master.name
  addon_name   = "coredns"

  addon_version = var.addon_coredns_version

  resolve_conflicts = "OVERWRITE"

  depends_on = [
    helm_release.karpenter
  ]
}

resource "aws_eks_addon" "kubeproxy" {
  cluster_name = aws_eks_cluster.master.name
  addon_name   = "kube-proxy"

  addon_version = var.addon_kubeproxy_version

  resolve_conflicts = "OVERWRITE"

  depends_on = [
    kubernetes_config_map.aws-auth
  ]
}