output "eks_cluster_name" {
  value = module.eks[0].cluster_name
}

output "vault_root_token" {
  value     = hcp_vault_cluster_admin_token.vault_admin_token.token
  sensitive = true
}

output "vault_private_url" {
  value = var.deploy_vault_cluster ? hcp_vault_cluster.new_vault_cluster[0].vault_private_endpoint_url : data.hcp_vault_cluster.existing_vault_cluster[0].vault_private_endpoint_url
}

output "vault_public_url" {
  value = var.deploy_vault_cluster ? hcp_vault_cluster.new_vault_cluster[0].vault_public_endpoint_url : data.hcp_vault_cluster.existing_vault_cluster[0].vault_public_endpoint_url
}

output "kubeconfig_filename" {
  value = abspath(one(module.eks[*].aws_auth_configmap_yaml))
}

################################################################################
# Security Group
################################################################################

output "cluster_security_group_arn" {
  description = "Amazon Resource Name (ARN) of the cluster security group"
  value       = module.eks[0].cluster_security_group_arn
}

output "cluster_security_group_id" {
  description = "ID of the cluster security group"
  value       = module.eks[0].cluster_security_group_id
}

################################################################################
# Node Security Group
################################################################################

output "node_security_group_arn" {
  description = "Amazon Resource Name (ARN) of the node shared security group"
  value       = module.eks[0].node_security_group_arn
}
output "node_security_group_id" {
  value = module.eks[0].node_security_group_id
}

output "eks_cluster_arn" {
  description = "The Amazon Resource Name (ARN) of the cluster"
  value       = module.eks[0].cluster_arn
}

output "eks_cluster_certificate_authority_data" {
  description = "Base64 encoded certificate data required to communicate with the cluster"
  value       = module.eks[0].cluster_certificate_authority_data
}

output "eks_cluster_endpoint" {
  description = "Endpoint for your Kubernetes API server"
  value       = module.eks[0].cluster_endpoint
}

output "eks_cluster_id" {
  description = "The ID of the EKS cluster. Note: currently a value is returned only for local EKS clusters created on Outposts"
  value       = module.eks[0].cluster_id
}

output "eks_cluster_oidc_issuer_url" {
  description = "The URL on the EKS cluster for the OpenID Connect identity provider"
  value       = module.eks[0].cluster_oidc_issuer_url
}

output "eks_cluster_platform_version" {
  description = "Platform version for the cluster"
  value       = module.eks[0].cluster_platform_version
}

output "eks_cluster_status" {
  description = "Status of the EKS cluster. One of `CREATING`, `ACTIVE`, `DELETING`, `FAILED`"
  value       = module.eks[0].cluster_status
}
