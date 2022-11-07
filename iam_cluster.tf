resource "aws_iam_role" "master" {
  name = format("%s-master-role", var.cluster_name)

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "master-AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.master.name
}

# Optionally, enable Security Groups for Pods
# Reference: https://docs.aws.amazon.com/eks/latest/userguide/security-groups-for-pods.html
resource "aws_iam_role_policy_attachment" "master-AmazonEKSVPCResourceController" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
  role       = aws_iam_role.master.name
}

data "aws_iam_policy_document" "console_policy" {
  version = "2012-10-17"

  statement {
    effect = "Allow"
    actions = [
      "eks:ListFargateProfiles",
      "eks:DescribeNodegroup",
      "eks:ListNodegroups",
      "eks:ListUpdates",
      "eks:AccessKubernetesApi",
      "eks:ListAddons",
      "eks:DescribeCluster",
      "eks:DescribeAddonVersions",
      "eks:ListClusters",
      "eks:ListIdentityProviderConfigs",
      "iam:ListRoles"
    ]

    resources = [
      "*"
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "ssm:GetParameter"
    ]

    resources = [
      "arn:aws:ssm:*:${data.aws_caller_identity.current.account_id}:parameter/*"
    ]
  }

}

resource "aws_iam_policy" "console_policy" {
  name        = format("%s-console-eks", var.cluster_name)
  path        = "/"
  description = var.cluster_name

  policy = data.aws_iam_policy_document.console_policy.json
}

resource "aws_iam_policy_attachment" "console_policy" {
  name = format("%s-console-eks", var.cluster_name)
  roles = [
    aws_iam_role.master.name
  ]

  policy_arn = aws_iam_policy.console_policy.arn
}
