resource "helm_release" "karpenter" {
  namespace        = "karpenter"
  create_namespace = true

  name       = "karpenter"
  repository = "https://charts.karpenter.sh"
  chart      = "karpenter"
  version    = "0.33.2"

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

resource "kubectl_manifest" "karpenter_nodepool" {
  count = length(var.karpenter_nodepool)
  yaml_body = templatefile(
    "${path.module}/templates/karpenter/node_pool.yml.tpl", {
      NODEPOOL_NAME                   = var.karpenter_nodepool[count.index].nodepool_name
      LABELS                          = var.karpenter_nodepool[count.index].labels
      INSTANCE_CATEGORY               = var.karpenter_nodepool[count.index].instance_category
      INSTANCE_CPU                    = var.karpenter_nodepool[count.index].instance_cpu
      INSTANCE_HYPERVISOR             = var.karpenter_nodepool[count.index].instance_hypervisor
      INSTANCE_GENERATION             = var.karpenter_nodepool[count.index].instance_generation
      AVAILABILITY_ZONES              = var.karpenter_nodepool[count.index].avaiability_zones
      CPU_ARQ                         = var.karpenter_nodepool[count.index].cpu_arq
      CAPACITY_TYPE                   = var.karpenter_nodepool[count.index].capacity_type
      DISRUPTION_CONSOLIDATION_POLICY = var.karpenter_nodepool[count.index].disruption_policy
      DISRUPTION_COSOLIDATION_AFTER   = var.karpenter_nodepool[count.index].disruption_after
      DISRUPTION_EXPIRE_AFTER         = var.karpenter_nodepool[count.index].disruption_after_expire
      CPU_LIMIT                       = var.karpenter_nodepool[count.index].cpu_limit
      MEMORY_LIMIT                    = var.karpenter_nodepool[count.index].memory_limit
      NODEPOOL_WEIGHT                 = var.karpenter_nodepool[count.index].nodepool_weight
  })

  depends_on = [
    helm_release.karpenter
  ]
}
