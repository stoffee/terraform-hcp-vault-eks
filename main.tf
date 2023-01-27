data "aws_availability_zones" "available" {
  filter {
    name   = "zone-type"
    values = ["availability-zone"]
  }
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "2.78.0"

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
  count = var.install_eks_cluster ? 1 : 0
  name  = module.eks[0].cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  count = var.install_eks_cluster ? 1 : 0
  name  = module.eks[0].cluster_id
}

module "eks" {
  count                  = var.install_eks_cluster ? 1 : 0
  source                 = "terraform-aws-modules/eks/aws"
  version                = "17.24.0"
  #version                = "19.5.1"
  kubeconfig_api_version = "client.authentication.k8s.io/v1beta1"

  cluster_name = "${var.cluster_id}-cluster"
  #cluster_version = "1.24"
  cluster_version = "1.21"
  subnets         = module.vpc.private_subnets
  vpc_id          = module.vpc.vpc_id

  manage_aws_auth = false

 /* 
  cluster_security_group_additional_rules = {
    ingress_nodes_ephemeral_ports_tcp = {
      description                = "Vault Port"
      protocol                   = "tcp"
      from_port                  = 8200
      to_port                    = 8200
      type                       = "ingress"
      source_node_security_group = true
    }
  }
*/
  node_groups = {
    application = {
      name_prefix    = "hashi"
      instance_types = ["t2.micro"]
      #instance_types = ["t3a.medium"]

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
    name = "vault"
    annotations = {
      "kubernetes.io/service-account.name" = "vault"
    }
  }

  type = "kubernetes.io/service-account-token"
}
*/

data "hcp_hvn" "existing" {
  count  = var.deploy_hvn ? 0 : 1
  hvn_id = var.hvn_id
}

resource "hcp_vault_cluster" "vault_cluster" {
  count      = var.deploy_vault_cluster ? 1 : 0
  hvn_id     = data.hcp_hvn.existing[0].hvn_id
  cluster_id = var.cluster_id
}

resource "hcp_vault_cluster_admin_token" "vault_admin_token" {
  count      = var.deploy_vault_cluster ? 1 : 0
  cluster_id = hcp_vault_cluster.vault_cluster[0].cluster_id
}

data "aws_arn" "peer" {
  arn = module.vpc.vpc_arn
}

resource "hcp_aws_network_peering" "hcp" {
  hvn_id          = var.hvn_id
  peering_id      = "hcp"
  peer_vpc_id     = module.vpc.vpc_id
  peer_account_id = module.vpc.vpc_owner_id
  peer_vpc_region = data.aws_arn.peer.region
}

resource "hcp_hvn_route" "existing-to-hcp" {
  hvn_link         = data.hcp_hvn.existing[0].self_link
  hvn_route_id     = "aws-to-hcp"
  destination_cidr = module.vpc.vpc_cidr_block
  target_link      = hcp_aws_network_peering.hcp.self_link
}

resource "aws_vpc_peering_connection_accepter" "peer" {
  vpc_peering_connection_id = hcp_aws_network_peering.hcp.provider_peering_id
  auto_accept               = true
}

resource "helm_release" "vault" {
  name       = "vault"
  repository = "https://helm.releases.hashicorp.com"
  chart      = "vault"

  values = [
    "${file("${path.module}/files/values.yaml")}"
    #"${file("files/values.yaml")}"
  ]
}

/*
resource "helm_release" "wordpress" {
  name       = "wordpress"
  repository = "https://charts.bitnami.com/bitnami"
  chart      = "wordpress"
}

resource "helm_release" "jenkins" {
  name       = "jenkins"
  repository = "https://charts.jenkins.io"
  chart      = "jenkins"

}
*/