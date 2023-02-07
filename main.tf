data "aws_availability_zones" "available" {
  filter {
    name   = "zone-type"
    values = ["availability-zone"]
  }
}

resource "random_pet" "server" {}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 3.19.0"
  #version = "2.78.0"

  name                 = "${var.cluster_id}-vpc"
  cidr                 = "10.0.0.0/16"
  azs                  = data.aws_availability_zones.available.names
  public_subnets       = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  private_subnets      = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true
}

data "aws_eks_cluster" "cluster" {
  count = var.deploy_eks_cluster ? 0 : 1
  name  = "${var.cluster_id}-eks"
  #name  = module.eks[0].cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  count = var.deploy_eks_cluster ? 1 : 0
  name  = "${var.cluster_id}-cluster"
  #name  = module.eks[0].cluster_id
}

module "eks" {
  count  = var.deploy_eks_cluster ? 1 : 0
  source = "terraform-aws-modules/eks/aws"
  #version                = "17.24.0"
  version = "~> 19.6.0"
  #kubeconfig_api_version = "client.authentication.k8s.io/v1beta1"
  cluster_endpoint_public_access = true
  cluster_endpoint_public_access_cidrs = [ "0.0.0.0/0" ]

  cluster_name = "${var.cluster_id}-cluster"
  #cluster_version = "1.24"
  cluster_version = "1.21"
  subnet_ids      = module.vpc.private_subnets
  vpc_id          = module.vpc.vpc_id

  manage_aws_auth_configmap = false

  cluster_security_group_additional_rules = {
    ingress_node_vault_port = {
      description                = "Vault Port"
      protocol                   = "tcp"
      from_port                  = 8200
      to_port                    = 8200
      type                       = "ingress"
      source_node_security_group = true
    }
  }

  eks_managed_node_groups = {
    ubettawerk = {
      name_prefix    = random_pet.server.id
      #instance_types = ["t2.micro"]
      instance_types = ["t3a.medium"]

      desired_capacity = 3
      max_capacity     = 3
      min_capacity     = 2
    }
  }
}

# k8s 1.24 -> needs to manually create vault SA
/*
resource "kubernetes_secret" "vault" {
  metadata {
    name = "vault-auth-secret"
    annotations = {
      "kubernetes.io/service-account.name" = "vault-auth"
    }
  }
  type = "kubernetes.io/service-account-token"
}
*/

/*
data "hcp_hvn" "existing" {
  count  = var.deploy_hvn ? 0 : 1
  hvn_id = var.hvn_id
}
resource "hcp_vault_cluster" "vault_cluster_existing_hvn" {
  count      = var.deploy_vault_cluster ? 1 : 0 && var.deploy_hvn ? 0 : 1
  hvn_id     = data.hcp_hvn.existing[0].hvn_id
  cluster_id = var.cluster_id
}
*/

resource "hcp_vault_cluster" "vault_cluster_new" {
  count = var.deploy_vault_cluster ? 1 : 0
  #hvn_id     = data.hcp_hvn.existing[0].hvn_id
  hvn_id          = hcp_hvn.new.hvn_id
  cluster_id      = var.cluster_id
  public_endpoint = true
}

resource "hcp_vault_cluster_admin_token" "vault_admin_token" {
  count      = var.deploy_vault_cluster ? 1 : 0
  cluster_id = hcp_vault_cluster.vault_cluster_new[0].cluster_id
}

data "aws_arn" "peer" {
  arn = module.vpc.vpc_arn
}

resource "hcp_hvn" "new" {
  hvn_id         = var.hvn_id
  cloud_provider = "aws"
  region         = "us-west-2"
  cidr_block     = "172.25.16.0/20"
  depends_on     = [module.eks]
}

resource "hcp_aws_network_peering" "hcp" {
  hvn_id          = var.hvn_id
  peering_id      = "hcp"
  peer_vpc_id     = module.vpc.vpc_id
  peer_account_id = module.vpc.vpc_owner_id
  peer_vpc_region = data.aws_arn.peer.region
  depends_on       = [module.eks, hcp_vault_cluster_admin_token.vault_admin_token]
}

resource "hcp_hvn_route" "existing-to-hcp" {
  hvn_link = hcp_hvn.new.self_link
  #hvn_link         = data.hcp_hvn.existing[0].self_link
  hvn_route_id     = "aws-to-hcp"
  destination_cidr = module.vpc.vpc_cidr_block
  target_link      = hcp_aws_network_peering.hcp.self_link
  depends_on       = [helm_release.vault]
}

resource "aws_vpc_peering_connection_accepter" "peer" {
  vpc_peering_connection_id = hcp_aws_network_peering.hcp.provider_peering_id
  auto_accept               = true
}

resource "helm_release" "vault" {
  name       = "vault"
  repository = "https://helm.releases.hashicorp.com"
  chart      = "vault"
  depends_on = [hcp_vault_cluster_admin_token.vault_admin_token]
  /*
  # private vault enpoint
  values = [<<EOF
  injector:
   enabled: true
   externalVaultAddr: ${hcp_vault_cluster.vault_cluster_new[0].vault_private_endpoint_url}
  EOF
  ]
  */
  # public vault enpoint
  values = [<<EOF
  injector:
   enabled: true
   externalVaultAddr: ${hcp_vault_cluster.vault_cluster_new[0].vault_public_endpoint_url}
  EOF
  ]
}