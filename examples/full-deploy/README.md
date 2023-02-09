# Hashicorp HCP Vault, AWS EKS Module Example of a full deployment

   This is an example deployment with all options supported by this module. this will deploy the following resources.

   1. AWS EKS Cluster
   2. HCP Vault Cluster
   3. HCP HVN with VPC Peering to your AWS VPC for the EKS cluster

## Usage
   1. Clone this repo and change directory to examples/full-deploy
   2. <strong>Complete steps 1 - 3</strong> of <a target="_blank" href=https://github.com/stoffee/terraform-hcp-vault-eks/tree/main#readme>the main README</a>


## quick example of everything on
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

## Accessing the deployment
   Follow the steps in the main<a target="_blank" href=https://github.com/stoffee/terraform-hcp-vault-eks/tree/main#accessing-the-deployment> README</a>.

## deployment graph
<svg>graph.normal.svg</svg>
<svg>graph.cycles.svg</svg>