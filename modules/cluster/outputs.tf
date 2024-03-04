
output "endpoint" {
  value = aws_eks_cluster.master.endpoint
}

output "kubeconfig-certificate-authority-data" {
  value = aws_eks_cluster.master.certificate_authority[0].data
}

output "oidc_cluster_url" {
  value = aws_eks_cluster.master.identity[0].oidc[0].issuer
}
