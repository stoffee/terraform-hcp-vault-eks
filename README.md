## HCP Vault EKS Module

This repo contains a Terraform module that stands up a full deployment of a HCP Vault cluster
with an AWS EKS cluster and VPC peering. This module can also be customized to only deploy what you need.

# HCP Vault EKS Module Examples

Please check the [examples](https://github.com/stoffee/terraform-hcp-vault-eks/tree/primary/examples) for example deployments.

### Deployment

### Prerequisites

1. Create a HCP Service Key and set the required environment variables. Log into the HCP portal and go to IAM/Service principals and create a new Service principal and a key under the new Service principal. Then apply the environment variables with the output from creating the key.
https://portal.cloud.hashicorp.com/access/service-principals

```
export HCP_CLIENT_ID=
export HCP_CLIENT_SECRET=
```

1. Export your AWS Account credentials, as defined by the AWS Terraform provider
```
export AWS_ACCESS_KEY_ID=
export AWS_SECRET_ACCESS_KEY=
```

1. Rename sample.auto.tfvars_example to sample.auto.tfvars and edit to customize the install, then initialize and apply the Terraform configuration to get a customized environment. Ensure you view the plan details and approve with a yes.

```
terraform init && terraform apply
```

### Accessing the Deployment

#### HCP Vault

The HCP Vault cluster can be accessed via the outputs `vault_private_url`, `vault_public_url`, and `vault_root_token`.

#### EKS Cluster

The EKS cluster can be accessed via the output `kubeconfig_filename`, which
references a created kubeconfig file that can be used by setting the
`KUBECONFIG` environment variable

```bash
export KUBECONFIG=$(terraform output --raw kubeconfig_filename)
```

#### Demo Application

**Warning**: This application is publicly accessible, make sure to delete the Kubernetes resources associated to the application when done.

Export your Vault Account credentials from terraform output
```bash
export VAULT_ADDR=$(terraform output --raw vault_public_url)
export VAULT_TOKEN=$(terraform output --raw vault_root_token)
export VAULT_namespace=admin
```

Alternatively you can find this info in the HCP portal:

1.  On a browser login into HCP Portal

    https://portal.cloud.hashicorp.com

2.  Click the name of your cluster (such as "my-vault").
3.  Click "Private" link at the right of "Cluster URLs" to obtain a URL such as this in your Clipboard:

    https://my-vault-private-vault-c6443333.9d787275.z1.hashicorp.cloud:8200

4.  Click "Public" link at the right of "Cluster URLs" to obtain a URL such as this in your Clipboard:
    https://my-vault-public-vault-c6443333.9d787275.z1.hashicorp.cloud:8200

5. Construct this line in Bash from your Clipboard contents from above.
   
```bash
export VAULT_ADDR=https://my-vault-public-vault-c6443333.9d787275.z1.hashicorp.cloud:8200
export VAULT_TOKEN=
export VAULT_NAMESPACE=admin
```

#### setup cli auth for kubectl 
```bash
aws eks --region us-west-2 update-kubeconfig --name $(terraform output --raw eks_cluster_name)
```
#### allow 8200 traffic for worker nodes
```bash
aws ec2 --region us-west-2 authorize-security-group-egress --group-id $(terraform output --raw node_security_group_id) --ip-permissions IpProtocol=tcp,FromPort=8200,ToPort=8200,IpRanges='[{CidrIp=172.25.16.0/20}]' --output
```
Sample response:

```
True
SECURITYGROUPRULES      172.25.16.0/20  8200    sg-0366c6d221833eb8e    670394095681    tcp     True    sgr-09c3f57e2dfec5515   8200
```

#### Configure Kube auth method for Vault
```bash
export TOKEN_REVIEW_JWT=$(kubectl get secret \
   $(kubectl get serviceaccount vault -o jsonpath='{.secrets[0].name}') \
   -o jsonpath='{ .data.token }' | base64 --decode)
# TODO: Display first 20 chars to verify.

export KUBE_CA_CERT=$(kubectl get secret \
   $(kubectl get serviceaccount vault -o jsonpath='{.secrets[0].name}') \
   -o jsonpath='{ .data.ca\.crt }' | base64 --decode)

export KUBE_HOST=$(kubectl config view --raw --minify --flatten \
   -o jsonpath='{.clusters[].cluster.server}')
# example: KUBE_HOST=https://6677B3488C2D5C0162A558C881AF9922.gr7.us-west-2.eks.amazonaws.com

vault write auth/kubernetes/config \
   token_reviewer_jwt="$TOKEN_REVIEW_JWT" \
   kubernetes_host="$KUBE_HOST" \
   kubernetes_ca_cert="$KUBE_CA_CERT"
```
# Error writing data to auth/kubernetes/config: Put "https://127.0.0.1:8200/v1/auth/kubernetes/config": dial tcp 127.0.0.1:8200: connect: connection refused

#### Deploy Postgres
```bash
kubectl apply -f files/postgres.yaml
```

##### Check that Postgres is running before moving on
```bash
kubectl get pods
```
##### Grab the Postgres IP and then configure the Vault DB secrets engine
```bash
export POSTGRES_IP=$(kubectl get service -o jsonpath='{.status.loadBalancer.ingress[0].hostname}' \
   postgres)

vault write database/config/products \
    plugin_name=postgresql-database-plugin \
    allowed_roles="*" \
    connection_url="postgresql://{{username}}:{{password}}@${POSTGRES_IP}:5432/products?sslmode=disable" \
    username="postgres" \
    password="password"
```

#### Edit file/values.yaml and replace the hostname with your vault internal URL from the HCP console
you can retrieve it with this command
```bash
terraform output --raw vault_private_url
```

#### Deploy the prodcut app
```bash
kubectl apply -f files/product.yaml
```

##### Check the product app is running before moving on
```bash
kubectl get pods
```

# Test the app retrieves coffee info
```bash
kubectl port-forward service/product 9090 &

curl -s localhost:9090/coffees | jq .
```
