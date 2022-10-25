resource "aws_eks_cluster" "master" {
  name     = var.cluster_name
  role_arn = aws_iam_role.master.arn
  version  = var.k8s_version

  enabled_cluster_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]

  vpc_config {
    subnet_ids = var.subnet_ids

    endpoint_private_access = false
    endpoint_public_access  = true
  }

  depends_on = [
    aws_iam_role_policy_attachment.master-AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.master-AmazonEKSVPCResourceController,
  ]

  tags = merge(
    var.tags,
    {
      "kubernetes.io/cluster/${var.cluster_name}" = "shared",
      "karpenter.sh/discovery"                    = var.cluster_name
    }
  )
}


