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



resource "aws_security_group_rule" "nodeport_eks" {
  cidr_blocks = ["0.0.0.0/0"]
  from_port   = 30000
  to_port     = 32768
  description = "nodeport"
  protocol    = "tcp"

  security_group_id = aws_eks_cluster.master.vpc_config[0].cluster_security_group_id
  type              = "ingress"
}

resource "aws_security_group_rule" "nodeport_eks_udp" {
  cidr_blocks = ["0.0.0.0/0"]
  from_port   = 30000
  to_port     = 32768
  description = "nodeport"
  protocol    = "udp"

  security_group_id = aws_eks_cluster.master.vpc_config[0].cluster_security_group_id
  type              = "ingress"
}

resource "aws_security_group_rule" "rule_443" {
  cidr_blocks = ["0.0.0.0/0"]
  from_port   = 443
  to_port     = 443
  description = ""
  protocol    = "tcp"

  security_group_id = aws_eks_cluster.master.vpc_config[0].cluster_security_group_id
  type              = "ingress"
}


resource "aws_security_group_rule" "rule_80" {
  cidr_blocks = ["0.0.0.0/0"]
  from_port   = 80
  to_port     = 80
  description = ""
  protocol    = "tcp"

  security_group_id = aws_eks_cluster.master.vpc_config[0].cluster_security_group_id
  type              = "ingress"
}

resource "aws_security_group_rule" "rule_8080" {
  cidr_blocks = ["0.0.0.0/0"]
  from_port   = 8080
  to_port     = 8080
  description = ""
  protocol    = "tcp"

  security_group_id = aws_eks_cluster.master.vpc_config[0].cluster_security_group_id
  type              = "ingress"
}

resource "aws_security_group_rule" "rule_53_tcp" {
  cidr_blocks = ["0.0.0.0/0"]
  from_port   = 53
  to_port     = 53
  description = ""
  protocol    = "tcp"

  security_group_id = aws_eks_cluster.master.vpc_config[0].cluster_security_group_id
  type              = "ingress"
}

resource "aws_security_group_rule" "rule_53_udp" {
  cidr_blocks = ["0.0.0.0/0"]
  from_port   = 53
  to_port     = 53
  description = ""
  protocol    = "udp"

  security_group_id = aws_eks_cluster.master.vpc_config[0].cluster_security_group_id
  type              = "ingress"
}

resource "aws_ec2_tag" "karpenter" {
  resource_id = aws_eks_cluster.master.vpc_config[0].cluster_security_group_id
  key         = "Name"
  value       = format("%s-eks", var.cluster_name)
}
