output "eks_cluster_name" {
  value = module.hcp-eks.eks_cluster_name
}

output "vault_root_token" {
  value     = module.hcp-eks.vault_root_token
  sensitive = true
}

output "vault_private_url" {
  value = module.hcp-eks.vault_private_url
}

output "vault_public_url" {
  value = module.hcp-eks.vault_public_url
}

output "kubeconfig_filename" {
  value = module.hcp-eks.kubeconfig_filename
}

################################################################################
# Security Group
################################################################################

output "cluster_security_group_arn" {
  description = "Amazon Resource Name (ARN) of the cluster security group"
  value       = module.hcp-eks.cluster_security_group_arn
}

output "cluster_security_group_id" {
  description = "ID of the cluster security group"
  value       = module.hcp-eks.cluster_security_group_id
}

################################################################################
# Node Security Group
################################################################################

output "node_security_group_arn" {
  description = "Amazon Resource Name (ARN) of the node shared security group"
  value       = module.hcp-eks.node_security_group_arn
}
output "node_security_group_id" {
  value = module.hcp-eks.node_security_group_id
}

output "eks_cluster_arn" {
  description = "The Amazon Resource Name (ARN) of the cluster"
  value       = module.hcp-eks.eks_cluster_arn
}

output "eks_cluster_certificate_authority_data" {
  description = "Base64 encoded certificate data required to communicate with the cluster"
  value       = module.hcp-eks.eks_cluster_certificate_authority_data
}

output "eks_cluster_endpoint" {
  description = "Endpoint for your Kubernetes API server"
  value       = module.hcp-eks.eks_cluster_endpoint
}

output "eks_cluster_id" {
  description = "The ID of the EKS cluster. Note: currently a value is returned only for local EKS clusters created on Outposts"
  value       = module.hcp-eks.eks_cluster_id
}

output "eks_cluster_oidc_issuer_url" {
  description = "The URL on the EKS cluster for the OpenID Connect identity provider"
  value       = module.hcp-eks.eks_cluster_oidc_issuer_url
}

output "eks_cluster_platform_version" {
  description = "Platform version for the cluster"
  value       = module.hcp-eks.eks_cluster_platform_version
}

output "eks_cluster_status" {
  description = "Status of the EKS cluster. One of `CREATING`, `ACTIVE`, `DELETING`, `FAILED`"
  value       = module.hcp-eks.eks_cluster_status
}