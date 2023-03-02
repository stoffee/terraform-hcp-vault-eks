terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      #version = "~> 3.43"
      version = "~> 4.51"
    }

    hcp = {
      source  = "hashicorp/hcp"
      version = ">= 0.53.0"
    }

    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.17.0"
    }

    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.8.0"
    }

    /*
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "~> 1.14.0"
    }
    */
  }

  provider_meta "hcp" {
    module_name = "hcp-consul"
  }
}

provider "aws" {
  region = var.vpc_region
}

provider "helm" {
  kubernetes {
    host                   = var.deploy_eks_cluster ? module.eks[0].cluster_endpoint : data.aws_eks_cluster.cluster[0].endpoint
    cluster_ca_certificate = var.deploy_eks_cluster ? base64decode(module.eks[0].cluster_certificate_authority_data) : base64decode(data.aws_eks_cluster.cluster[0].certificate_authority.0.data)
    exec {
      api_version = "networking.k8s.io/v1"
      #api_version = "client.authentication.k8s.io/v1beta1"
      command     = "aws"
      # This requires the awscli to be installed locally where Terraform is executed
      args = ["eks", "get-token", "--cluster-name", module.eks[0].cluster_name]
    }
    # token                  = var.deploy_eks_cluster ? module.eks[0].cluster_certificate_authority_data : data.aws_eks_cluster_auth.cluster[0].token
  }
}

provider "kubernetes" {
  host                   = var.deploy_eks_cluster ? module.eks[0].cluster_endpoint : data.aws_eks_cluster.cluster[0].endpoint
  cluster_ca_certificate = var.deploy_eks_cluster ? base64decode(module.eks[0].cluster_certificate_authority_data) : base64decode(data.aws_eks_cluster.cluster[0].certificate_authority.0.data)
  exec {
    api_version = "networking.k8s.io/v1"
    command     = "aws"
    # This requires the awscli to be installed locally where Terraform is executed
    args = ["eks", "get-token", "--cluster-name", module.eks[0].cluster_name]
  }
  # token                  = var.deploy_eks_cluster ? module.eks[0].cluster_certificate_authority_data : data.aws_eks_cluster_auth.cluster[0].token
  # host                   = var.deploy_eks_cluster ? data.aws_eks_cluster.cluster[0].endpoint : ""
  # cluster_ca_certificate = var.deploy_eks_cluster ? base64decode(data.aws_eks_cluster.cluster[0].certificate_authority.0.data) : ""
  # token                  = var.deploy_eks_cluster ? data.aws_eks_cluster_auth.cluster[0].token : ""
}

/*
provider "kubectl" {
  host                   = var.deploy_eks_cluster ? data.aws_eks_cluster.cluster[0].endpoint : ""
  cluster_ca_certificate = var.deploy_eks_cluster ? base64decode(data.aws_eks_cluster.cluster[0].certificate_authority.0.data) : ""
  token                  = var.deploy_eks_cluster ? data.aws_eks_cluster_auth.cluster[0].token : ""
  load_config_file       = false
}
*/