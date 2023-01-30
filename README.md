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

2. Rename sample.tfvars_example to sample.auto.tfvars and edit to customize the install, then initialize and apply the Terraform configuration to get a customized environment

```
terraform init && terraform apply
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



```bash
aws eks --region us-west-2 update-kubeconfig --name YOUR_CLUSTER_NAME
```

```bash
aws ec2 --region us-west-2 authorize-security-group-egress --group-id YOUR_WORKER_NODE_SECURITY_GROUP_NAME --ip-permissions IpProtocol=tcp,FromPort=8200,ToPort=8200,IpRanges='[{CidrIp=172.25.16.0/20}]'
```

```bash
export TOKEN_REVIEW_JWT=$(kubectl get secret \
   $(kubectl get serviceaccount vault -o jsonpath='{.secrets[0].name}') \
   -o jsonpath='{ .data.token }' | base64 --decode)

export KUBE_CA_CERT=$(kubectl get secret \
   $(kubectl get serviceaccount vault -o jsonpath='{.secrets[0].name}') \
   -o jsonpath='{ .data.ca\.crt }' | base64 --decode)

export KUBE_HOST=$(kubectl config view --raw --minify --flatten \
   -o jsonpath='{.clusters[].cluster.server}')

vault write auth/kubernetes/config \
   token_reviewer_jwt="$TOKEN_REVIEW_JWT" \
   kubernetes_host="$KUBE_HOST" \
   kubernetes_ca_cert="$KUBE_CA_CERT"
```

```bash
kubectl apply -f files/postgres.yaml

kubectl get pods
```

```bash
export POSTGRES_IP=$(kubectl get service -o jsonpath='{.status.loadBalancer.ingress[0].hostname}' \
   postgres)
```


vault write database/config/products \
    plugin_name=postgresql-database-plugin \
    allowed_roles="*" \
    connection_url="postgresql://{{username}}:{{password}}@${POSTGRES_IP}:5432/products?sslmode=disable" \
    username="postgres" \
    password="password"
```

Edit file/vaules.yaml and replace the hostname with your vault internal URL from the HCP console

```bash
kubectl apply -f files/product.yaml

kubectl get pods

kubectl port-forward service/product 9090 &

curl -s localhost:9090/coffees | jq .
```
