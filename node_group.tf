resource "aws_eks_node_group" "this" {
  cluster_name    = aws_eks_cluster.master.name
  node_group_name = format("%s-node-group", var.cluster_name)
  node_role_arn   = aws_iam_role.node_group.arn
  subnet_ids      = var.subnet_ids

  scaling_config {
    desired_size = 1
    max_size     = 2
    min_size     = 1
  }

  instance_types = ["t3.medium"]

  update_config {
    max_unavailable = 1
  }

  # Ensure that IAM Role permissions are created before and deleted after EKS Node Group handling.
  # Otherwise, EKS will not be able to properly delete EC2 Instances and Elastic Network Interfaces.
  depends_on = [
    aws_iam_role_policy_attachment.cni,
    aws_iam_role_policy_attachment.node,
    aws_iam_role_policy_attachment.ecr,
    aws_iam_role_policy_attachment.ssm,
    aws_iam_role_policy_attachment.cloudwatch,
  ]
}
