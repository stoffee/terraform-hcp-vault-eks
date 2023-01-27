## HCP Vault EKS Module

This repo contains a Terraform module that stands up a full deployment of a HCP Vault cluster
with an AWS EKS cluster and VPC peering. This module can also be customized to only deploy what you need.

### Prerequisites

1. Create a HCP Service Key and set the required environment variables

```
export HCP_CLIENT_ID=...
export HCP_CLIENT_SECRET=...
```

2. Export your Vault Account credentials
```
export VAULT_ADDR=...
export VAULT_TOKEN=...
export VAULT_NAMESPACE=admin
```

3. Export your AWS Account credentials, as defined by the AWS Terraform provider

# Hashicorp Vault Namespace Module Examples

Please check the [examples](https://github.com/stoffee/terraform-hcp-vault-eks/tree/primary/examples) for example deployments.

### Deployment

1. Initialize and apply the Terraform configuration to get a full environment

```
terraform init && terraform apply
```

2. Rename sample.tfvars_example to sample.tfvars and edit to customize the install, then initialize and apply the Terraform configuration to get a customized environment

```
terraform init && terraform apply -var-file="sample.tfvars"
```

### Accessing the Deployment

#### HCP Vault

The HCP Vault cluster can be accessed via the outputs `vault_url` and
`vault_root_token`.

#### EKS Cluster

The EKS cluster can be accessed via the output `kubeconfig_filename`, which
references a created kubeconfig file that can be used by setting the
`KUBECONFIG` environment variable

```bash
export KUBECONFIG=$(terraform output --raw kubeconfig_filename)
```

#### Demo Application

**Warning**: This application is publicly accessible, make sure to delete the Kubernetes resources associated to the application when done.
