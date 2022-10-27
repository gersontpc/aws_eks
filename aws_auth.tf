resource "kubernetes_config_map" "aws-auth" {
  count = 0

  metadata {
    name      = "aws-auth"
    namespace = "kube-system"
  }
  data = {
    mapRoles = <<YAML
- rolearn: ${aws_iam_role.master.arn}
  username: system:node:{{EC2PrivateDNSName}}
  groups:
  - system:bootstrappers
  - system:nodes
  - system:node-proxier
- rolearn: ${aws_iam_role.master.arn}
  username: system:node:{{SessionName}}
  groups:
  - system:bootstrappers
  - system:nodes
  - system:node-proxier  
YAML
  }
}