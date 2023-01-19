/*
output "vault_root_token" {
  value     = hcp_vault_cluster_admin_token.vault_admin_token[0].token
  sensitive = true
}

output "vault_url" {
  value = hcp_vault_cluster.vault_cluster[0].public_endpoint ? (
    hcp_vault_cluster.vault_cluster[0].vault_public_endpoint_url
    ) : (
    hcp_vault_cluster.vault_cluster[0].vault_private_endpoint_url
  )
}
*/
output "kubeconfig_filename" {
  value = abspath(one(module.eks[*].kubeconfig_filename))
}

/*
output "helm_values_filename" {
  value = abspath(module.eks_consul_client.helm_values_file)
}
*/