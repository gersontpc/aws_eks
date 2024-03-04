locals {

  create_aws_auth_configmap = length(var.map_roles) == 0 && length(var.map_users) == 0 && length(var.map_accounts) == 0

  aws_auth_configmap_yaml = templatefile("${path.module}/templates/auth/aws_auth_cm.tpl",
    {
      map_roles    = var.map_roles
      map_users    = var.map_users
      map_accounts = var.map_accounts
    }
  )

  # create_istio = (var.create_istio) ? 1 : 0

}