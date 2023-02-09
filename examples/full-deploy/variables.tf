variable "deploy_eks_cluster" {
  type        = string
  description = "Choose if you want an eks cluster to be provisioned"
  default     = true
}

variable "cluster_id" {
  type        = string
  description = "The name of your EKS cluster"
  default     = "hcp-eks"
}

variable "vpc_region" {
  type        = string
  description = "The AWS region to create resources in"
  default     = "us-west-2"
}

variable "eks_instance_types" {
  type        = list(any)
  description = "The node size of your EKS cluster"
  #default     = ["t3a.medium"]
  default = ["t2.small"]
}

variable "deploy_hvn" {
  type        = string
  description = "Choose to deploy HCP HVP or use an existing one"
  default     = false
}

variable "hvn_id" {
  type        = string
  description = "The name of your existing HCP HVN"
  default     = "PUT-YOUR-HVN-NAME-HERE"
}

variable "hvn_cidr_block" {
  type        = string
  description = "The CIDR range to create the HCP HVN with"
  default     = "172.25.32.0/20"
}

variable "hvn_region" {
  type        = string
  description = "The HCP region to create resources in"
  default     = "us-west-2"
}

variable "deploy_vault_cluster" {
  type        = string
  description = "Choose to deploy HCP Vault Cluster"
  default     = false
}

variable "make_vault_public" {
  type        = string
  description = "Choose if you want your Vault cluster to have a public address"
  default     = false
}

variable "hcp_vault_cluster_id" {
  type        = string
  description = "The name of your HCP Vault cluster"
  default     = "hcp-vault"
}

variable "vault_internal_addr" {
  type        = string
  description = "The internal url of your HCP vault cluster"
  default     = "https://MyVault.private.vault.f4cfade2-df28-47f2-a365-56gb2a62d8c5.aws.hashicorp.cloud:8200"
}


variable "vault_tier" {
  type        = string
  description = "The HCP Vault tier to use when creating a Vault cluster"
  default     = "development"
}