resource "kubernetes_config_map" "aws-auth" {
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

resource "kubernetes_config_map_v1_data" "aws_auth" {
  count = local.create_aws_auth_configmap ? 0 : 1

  metadata {
    name      = "aws-auth"
    namespace = "kube-system"
  }

  data = {
    "mapRoles"    = yamlencode(var.map_roles)
    "mapUsers"    = yamlencode(var.map_users)
    "mapAccounts" = yamlencode(var.map_accounts)
  }

  force = true

}