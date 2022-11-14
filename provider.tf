provider "aws" {
  region = "us-east-1"
}

# Backend
# terraform {
#   backend "s3" {
#     bucket = "223341017520-tfstate"
#     key    = "479610723/gson-labs-new.tfvars"
#     region = "us-east-1"
#   }
# }

provider "kubernetes" {
  host                   = aws_eks_cluster.master.endpoint
  cluster_ca_certificate = base64decode(aws_eks_cluster.master.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.default.token
}

provider "kubectl" {
  apply_retry_count      = 5
  host                   = aws_eks_cluster.master.endpoint
  cluster_ca_certificate = base64decode(aws_eks_cluster.master.certificate_authority.0.data)
  load_config_file       = false

  exec {
    api_version = "client.authentication.k8s.io/v1alpha1"
    command     = "aws"
    args        = ["eks", "get-token", "--cluster-name", aws_eks_cluster.master.id]
  }
}

provider "helm" {
  kubernetes {
    host                   = aws_eks_cluster.master.endpoint
    cluster_ca_certificate = base64decode(aws_eks_cluster.master.certificate_authority.0.data)
    token                  = data.aws_eks_cluster_auth.default.token
  }
}