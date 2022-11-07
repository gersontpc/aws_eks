provider "aws" {
  region = "us-east-1"
}

terraform {
  required_version = ">= 1.3.3"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.34.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.7.1"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.14.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0.3"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = ">= 1.7.0"
    }
    template = {
      source  = "hashicorp/template"
      version = ">= 2.2.0"
    }
  }
}

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