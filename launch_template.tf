data "aws_ssm_parameter" "eks" {
  name = format("/aws/service/eks/optimized-ami/%s/amazon-linux-2/recommended/image_id", var.k8s_version)
}

data "template_file" "user_data" {
  template = file("${path.module}/files/userdata.tpl")
  vars = {
    CLUSTER_NAME       = var.cluster_name,
    CLUSTER_ID         = var.cluster_name,
    APISERVER_ENDPOINT = aws_eks_cluster.master.endpoint,
    B64_CLUSTER_CA     = aws_eks_cluster.master.certificate_authority.0.data,
  }
}

resource "aws_launch_template" "main" {
  image_id = data.aws_ssm_parameter.eks.value
  name     = format("%s-template", var.cluster_name)

  update_default_version = true

  vpc_security_group_ids = [
    aws_eks_cluster.master.vpc_config[0].cluster_security_group_id
  ]

  user_data = filebase64("${path.module}/files/userdata.tpl")

  iam_instance_profile {
    name = aws_iam_instance_profile.nodes.name
  }

  tags = {
    Name = format("%s-node", var.cluster_name)
  }

}