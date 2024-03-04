module "default_tags" {
  source = "git::https://github.com/gersontpc/aws_default_tags?ref=v1.0.2"

  service_name     = var.service_name
  feature_name     = var.feature_name
  owner_email      = var.owner_email
  tech_owner_email = var.tech_owner_email
  environment      = var.environment
  squad            = var.squad
  finops           = var.finops
  repo_name        = var.repo_name
  pipeline         = var.pipeline
  tier             = var.tier
  sigla            = var.sigla
  sn               = var.sn
  account_id       = var.account_id
}