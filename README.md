## HCP Vault EKS

This Terraform example stands up a full deployment of a HCP Vault cluster
with an AWS EKS cluster.

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

### Deployment

1. Initialize and apply the Terraform configuration to get a full environment

```
terraform init && terraform apply
```

2. Rename and edit the sample.tfvars to customize the install, then initialize and apply the Terraform configuration to get a customized environment

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

**Warning**: This application is publicly accessible, make sure to delete the Kubernetes
resources associated to the application when done.