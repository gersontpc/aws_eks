resource "aws_eks_node_group" "this" {
  count           = length(var.node_groups)
  node_group_name = var.node_groups[count.index].name
  cluster_name    = aws_eks_cluster.master.name
  node_role_arn   = aws_iam_role.node_group.arn
  subnet_ids      = var.subnet_ids
  instance_types  = var.node_groups[count.index].instance_types

  labels = var.node_groups[count.index].labels

  capacity_type = var.node_groups[count.index].capacity_type

  update_config {
    max_unavailable_percentage = var.node_groups[count.index].max_unavailable_percentage
  }

  scaling_config {
    desired_size = var.node_groups[count.index].desired_capacity
    max_size     = var.node_groups[count.index].max_capacity
    min_size     = var.node_groups[count.index].min_capacity
  }

  launch_template {
    id      = aws_launch_template.main.id
    version = aws_launch_template.main.latest_version
  }

  lifecycle {
    create_before_destroy = true
  }

  tags = merge({
    "kubernetes.io/cluster/${var.cluster_name}"  = "owned",
    "karpenter.sh/discovery/${var.cluster_name}" = "${var.cluster_name}"
  }, var.tags)


  depends_on = [
    aws_iam_role_policy_attachment.cni,
    aws_iam_role_policy_attachment.node,
    aws_iam_role_policy_attachment.ecr,
    aws_iam_role_policy_attachment.ssm,
    aws_iam_role_policy_attachment.cloudwatch,
    aws_launch_template.main,
    aws_eks_cluster.master
  ]
}
