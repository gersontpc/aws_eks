resource "helm_release" "karpenter" {
  namespace        = "karpenter"
  create_namespace = true

  name       = "karpenter"
  repository = "https://charts.karpenter.sh"
  chart      = "karpenter"
  version    = "0.16.3"

  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = aws_iam_role.karpenter_role.arn
  }

  set {
    name  = "clusterName"
    value = var.cluster_name
  }

  set {
    name  = "clusterEndpoint"
    value = aws_eks_cluster.master.endpoint
  }

  set {
    name  = "aws.defaultInstanceProfile"
    value = aws_iam_instance_profile.nodes.name
  }

  depends_on = [
    aws_eks_cluster.master,
    aws_eks_addon.kubeproxy,
    kubernetes_config_map.aws-auth,
    aws_eks_node_group.this
  ]

}

resource "kubectl_manifest" "karpenter_provisioner" {
  yaml_body = templatefile(
    "${path.module}/files/karpenter/provisioner.yml.tpl", {
      EKS_CLUSTER        = aws_eks_cluster.master.name
      CAPACITY_TYPE      = var.karpenter.capacity_type
      INSTANCE_FAMILY    = var.karpenter.instance_family
      INSTANCE_SIZES     = var.karpenter.instance_sizes
      AVAILABILITY_ZONES = var.karpenter.availability_zones
      CPU_LIMIT          = var.karpenter.cpu_limit
      MEMORY_LIMIT       = var.karpenter.memory_limit
  })

  depends_on = [
    helm_release.karpenter
  ]
}

resource "kubectl_manifest" "karpenter_node_template" {
  yaml_body = templatefile(
    "${path.module}/files/karpenter/node-template.yml.tpl", {
      EKS_CLUSTER     = var.cluster_name,
      LAUNCH_TEMPLATE = format("%s-template", var.cluster_name)
  })

  depends_on = [
    helm_release.karpenter,
    kubectl_manifest.karpenter_provisioner
  ]
}