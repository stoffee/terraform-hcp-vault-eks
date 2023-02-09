# HCP Vault EKS Module

This repo contains a Terraform module that stands up a full deployment of a HCP Vault cluster
with an AWS EKS cluster and VPC peering. This module can also be customized to only deploy what you need.

## HCP Vault EKS Module Examples

Please check the <a target="_blank" href=https://github.com/stoffee/terraform-hcp-vault-eks/tree/primary/examples>[examples]</a> for example deployments.

## Deployment

### Prerequisites

1. Set HCP environment variables: Log into the HCP portal at:

   <a target="_blank" href="https://portal.cloud.hashicorp.com/access/service-principals">https://portal.cloud.hashicorp.com/access/service-principals</a>
   
   Then at the "Access control (IAM)" menu item under your org, "Service principals", "Create a new Service principal", specify a new Name (for example, JohnDoe) for a Contributor, and Save. 
   
   Click "Generate key".
   
   Click the icon for the <strong>Client ID</strong> to copy it into your Clipboard.
   
   In your Terminal, construct the command from your Clipboard, such as:

   ```
   export HCP_CLIENT_ID=johndoe-189296@abcdef12-f178-45dd-a22d-e04643fecc7b
   ```

   Switch back to HCP to click the icon for the <strong>Client Secret</strong> to copy it into your Clipboard.


   In your Terminal, construct the command from your Clipboard, such as:

   ```
   export HCP_CLIENT_SECRET=abcdef123mPwF7VIOuHDdthq42V0fUQBLbq-ZxadCMT5WaJW925bbXN9UJ9zBut9
   ```

   Then in your Terminal, apply the environment variables with the output from creating the key.

2. Export your AWS Account credentials (such as from Doormat), as defined by the AWS Terraform provider:

   ```
   export AWS_ACCESS_KEY_ID=
   export AWS_SECRET_ACCESS_KEY=
   ```

3. Rename sample.auto.tfvars_example to sample.auto.tfvars and edit to customize the install.   Edit the sample.auto.tfvars to your liking

  ```bash
  cp sample.auto.tfvars_example sample.auto.tfvars
  ```

  
4. Initialize and apply the Terraform configuration to get a customized environment. Ensure you view the plan details and approve with a yes.
  ```bash
  terraform init
  terraform apply
  ```

### Accessing the Deployment

#### HCP Vault

The HCP Vault cluster can be accessed via the terraform outputs `vault_private_url`, `vault_public_url`, and `vault_root_token`.

```bash
terraform output --raw vault_public_url
```
```bash
terraform output --raw vault_priate_url
```
```bash
terraform output --raw vault_root_token
```


#### EKS Cluster

The EKS cluster can be accessed via the terraform output `kubeconfig_filename`, which references a created kubeconfig file that can be used by setting the
`KUBECONFIG` environment variable

```bash
terraform output --raw kubeconfig_filename
```

## Demo Application

**Warning**: This application is publicly accessible, make sure to delete the Kubernetes resources associated to the application when done.

### Export your Vault Account credentials from terraform output
```bash
export VAULT_ADDR=$(terraform output --raw vault_public_url)
export VAULT_TOKEN=$(terraform output --raw vault_root_token)
export VAULT_namespace=admin
```

Alternatively you can find this info in the HCP portal:

1.  On a browser login into <a target="_blank" href=https://portal.cloud.hashicorp.com>HCP Portal</a>

    <a target="_blank" href=https://portal.cloud.hashicorp.com>https://portal.cloud.hashicorp.com</a>

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

### Setup cli auth for kubectl through awscli 
    ```bash
    aws eks --region us-west-2 update-kubeconfig --name $(terraform output --raw eks_cluster_name)
    terraform output --raw eks_cluster_name
    ```

### Configure Kube auth method for Vault
1. First grab the kube auth info and stick it in ENVVARS
```bash
export TOKEN_REVIEW_JWT=$(kubectl get secret \
   $(kubectl get serviceaccount vault -o jsonpath='{.secrets[0].name}') \
   -o jsonpath='{ .data.token }' | base64 --decode)

echo $TOKEN_REVIEW_JWT

export KUBE_CA_CERT=$(kubectl get secret \
   $(kubectl get serviceaccount vault -o jsonpath='{.secrets[0].name}') \
   -o jsonpath='{ .data.ca\.crt }' | base64 --decode)

echo $KUBE_CA_CERT

export KUBE_HOST=$(kubectl config view --raw --minify --flatten \
   -o jsonpath='{.clusters[].cluster.server}')

echo $KUBE_HOST
```

### Continue with configuration of Vault and deployment of Postgres, Vault agent, and Hashicups app
2. Enable the auth method and write the Kubernetes auth info into Vault
    ```bash
    vault auth enable kubernetes
    ```
    ```bash
    vault write auth/kubernetes/config \
    token_reviewer_jwt="$TOKEN_REVIEW_JWT" \
    kubernetes_host="$KUBE_HOST" \
    kubernetes_ca_cert="$KUBE_CA_CERT"
    ```

3. Deploy Postgres
    ```bash 
    kubectl apply -f files/postgres.yaml
    ```

4. Check that Postgres is running before moving on
    ```bash
    kubectl get pods
    ```

5. Grab the Postgres IP and then configure the Vault DB secrets engine
    ```bash
    export POSTGRES_IP=$(kubectl get service -o jsonpath='{.status.loadBalancer.ingress[0].hostname}' postgres)

    echo $POSTGRES_IP
    ```

6. Enable DB secrets
    ```bash
    vault secrets enable database
    ```

7. Write the Vault configuration for the postgresDB deployed earlier
    ```bash
    vault write database/config/products \
        plugin_name=postgresql-database-plugin \
       allowed_roles="*" \
       connection_url="postgresql://{{username}}:{{password}}@${POSTGRES_IP}:5432/products?sslmode=disable" \
       username="postgres" \
       password="password"

    vault write database/roles/product \
       db_name=products \
       creation_statements="CREATE ROLE \"{{name}}\" WITH LOGIN PASSWORD '{{password}}' VALID UNTIL '{{expiration}}'; \
        GRANT SELECT ON ALL TABLES IN SCHEMA public TO \"{{name}}\";" \
       revocation_statements="ALTER ROLE \"{{name}}\" NOLOGIN;"\
       default_ttl="1h" \
       max_ttl="24h"
    ```

8. Ensure we can create credentials on the postgresDB with Vault
    ```bash
    vault read database/creds/product
    ```

9. Create policy in Vault
```bash
vault policy write product files/product.hcl

vault write auth/kubernetes/role/product \
    bound_service_account_names=product \
    bound_service_account_namespaces=default \
    policies=product \
    ttl=1h
```

9. Deploy the product app
```bash
kubectl apply -f files/product.yaml
```

10.  Check the product app is running before moving on
```bash
kubectl get pods
```

11. Test the app retrieves coffee info
```bash
kubectl port-forward service/product 9090 &

curl -s localhost:9090/coffees | jq .
```
