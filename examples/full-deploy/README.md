# Hashicorp HCP Vault, AWS EKS Module Examples

This is an example deployment with all options supported by this module.

## Usage

### Everything On

```hcl
module "hcp-eks" {
  source               = "stoffee/vault-eks/hcp"
  version              = "~> 0.0.4"
  cluster_id           = "eks-cluster-name"
  deploy_hvn           = true
  hvn_id               = "my-hcp-hvn-name"
  hvn_region           = "us-west-2"
  deploy_vault_cluster = true
  hcp_vault_cluster_id = "my-hcp-vault-cluster-name"
  deploy_eks_cluster   = true
  vpc_region           = "us-west-2"
}
```