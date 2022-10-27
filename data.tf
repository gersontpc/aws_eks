data "aws_eks_cluster_auth" "default" {
  name = aws_eks_cluster.master.id
}

data "aws_caller_identity" "current" {}
