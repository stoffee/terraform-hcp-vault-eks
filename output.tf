output "vault_root_token" {
  value     = hcp_vault_cluster_admin_token.vault_admin_token[0].token
  sensitive = true
}

output "vault_priate_url" {
  value = hcp_vault_cluster.vault_cluster_new[0].vault_private_endpoint_url
}

output "vault_public_url" {
  value = hcp_vault_cluster.vault_cluster_new[0].vault_public_endpoint_url
}

output "kubeconfig_filename" {
  value = abspath(one(module.eks[*].aws_auth_configmap_yaml))
}

output "eks_cluster_name" {
  value = module.eks[0].cluster_id
}

output "node_security_group_id" {
  value = module.eks[0].node_security_group_id
}

/*
output "helm_values_filename" {
  value = abspath(module.eks_consul_client.helm_values_file)
}
*/