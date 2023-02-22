# Hashicorp HCP Vault, AWS EKS Module Example of a EKS only deployment

   This is an example deployment that assumes you already have a HVn and HCP Vault cluster up and running. this will deploy the following resources.

   1. AWS EKS Cluster
   3. HCP HVN VPC Peering to your AWS VPC for the new EKS cluster

## Usage
   1. Clone this repo and change directory to examples/eks-only-deploy
   2. <strong>Complete steps 1 - 3</strong> of <a target="_blank" href=https://github.com/stoffee/terraform-hcp-vault-eks/tree/main#readme>the main README</a>


## quick example of eks only
```hcl
module "hcp-eks" {
  source               = "stoffee/vault-eks/hcp"
  version              = "~> 0.0.8"
  cluster_id           = "eks-cluster-name"
  deploy_hvn           = false
  hvn_id               = "my-existing-hcp-hvn-name"
  hvn_region           = "us-west-2"
  deploy_vault_cluster = false
  hcp_vault_cluster_id = "my-existing-hcp-vault-cluster-name"
  deploy_eks_cluster   = true
  vpc_region           = "us-west-2"
}
```

## Accessing the deployment
   Follow the steps in the main<a target="_blank" href=https://github.com/stoffee/terraform-hcp-vault-eks/tree/main#accessing-the-deployment> README</a>.