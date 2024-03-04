data "template_file" "user_data" {
  template = file("${path.module}/templates/userdata/userdata.tpl")
  vars = {
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

  user_data = base64encode(data.template_file.user_data.rendered)

  # iam_instance_profile {
  #   name = aws_iam_instance_profile.nodes.name
  # }

  monitoring {
    enabled = true
  }

  ebs_optimized = true

  block_device_mappings {
    device_name = "/dev/xvda"

    ebs {
      volume_size           = 100
      volume_type           = "gp3"
      encrypted             = true
      delete_on_termination = true
    }
  }

  tag_specifications {
    resource_type = "instance"

    tags = merge({
      "karpenter.sh/discovery" = var.cluster_name,
      Name                     = format("%s-node", var.cluster_name)
    }, var.tags)
  }

  lifecycle {
    create_before_destroy = true
  }

}

# karpenter

resource "aws_launch_template" "karpenter" {
  image_id = data.aws_ssm_parameter.eks.value
  name     = format("%s-template-karpenter", var.cluster_name)

  update_default_version = true

  vpc_security_group_ids = [
    aws_eks_cluster.master.vpc_config[0].cluster_security_group_id
  ]

  user_data = base64encode(data.template_file.user_data.rendered)

  iam_instance_profile {
    name = aws_iam_instance_profile.nodes.name
  }

  monitoring {
    enabled = true
  }

  ebs_optimized = true

  block_device_mappings {
    device_name = "/dev/xvda"

    ebs {
      volume_size           = 100
      volume_type           = "gp3"
      encrypted             = true
      delete_on_termination = true
    }
  }

  tag_specifications {
    resource_type = "instance"

    tags = merge({
      "karpenter.sh/discovery" = var.cluster_name,
      Name                     = format("%s-node", var.cluster_name)
    }, var.tags)
  }

  lifecycle {
    create_before_destroy = true
  }

}
