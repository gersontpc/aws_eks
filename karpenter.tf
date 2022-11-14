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
  count = length(var.karpenter_provider)
  yaml_body = templatefile(
    "${path.module}/templates/karpenter/provisioner.yml.tpl", {
      PROVIDER_NAME      = var.karpenter_provider[count.index].provider_name
      CAPACITY_TYPE      = var.karpenter_provider[count.index].capacity_type
      INSTANCE_FAMILY    = var.karpenter_provider[count.index].instance_family
      INSTANCE_SIZES     = var.karpenter_provider[count.index].instance_sizes
      AVAILABILITY_ZONES = var.karpenter_provider[count.index].availability_zones
      CPU_LIMIT          = var.karpenter_provider[count.index].cpu_limit
      MEMORY_LIMIT       = var.karpenter_provider[count.index].memory_limit
      TTL_SCALING_EMPTY  = var.karpenter_provider[count.index].ttl_scaling_empty
      TTL_NODES          = var.karpenter_provider[count.index].ttl_nodes
  })

  depends_on = [
    helm_release.karpenter
  ]
}

resource "kubectl_manifest" "karpenter_node_template" {
  count = length(var.karpenter_provider)
  yaml_body = templatefile(
    "${path.module}/templates/karpenter/node-template.yml.tpl", {
      PROVIDER_NAME   = var.karpenter_provider[count.index].provider_name
      LAUNCH_TEMPLATE = format("%s-template-karpenter", var.cluster_name)
      CLUSTER_NAME    = var.cluster_name
  })

  depends_on = [
    helm_release.karpenter,
    kubectl_manifest.karpenter_provisioner
  ]
}