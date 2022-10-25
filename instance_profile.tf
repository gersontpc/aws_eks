resource "aws_iam_instance_profile" "nodes" {
  name = "${var.cluster_name}-instance-profile"
  role = aws_iam_role.node_group.name
}