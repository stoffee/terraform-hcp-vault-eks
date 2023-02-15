# HCP Vault EKS Module

This repo contains a Terraform module that stands up a full deployment of a HCP Vault cluster
with an AWS EKS cluster and VPC peering. This module can also be customized to only deploy what you need.

## Deployment

A. <a href="#SetHCPEnv">Set HCP environment variables</a><br />
B. <a href="#SetAWSEnv">Set AWS environment variables</a><br />
C. <a href="#SelectExample">Select Example Deploy</a><br />
D. <a href="#Edit_tfvars">Edit sample.auto.tfvars</a><br />
E. <a href="#DeployTF">Run Terraform to Deploy</a><br />
F. <a href="#ConfirmHCP">Confirm HCP</a><br />
G. <a href="#AccessVault">Access HCP Vault GUI</a><br />
H. <a href="#AccessDemoApp">Use Vault in Demo App</a><br />

<hr />

<a name="SetHCPEnv"></a>

### Set HCP environment variables

These statements define how to reach HCP:
```bash
export HCP_CLIENT_ID=1234oTzq81L6DxXmQrrfkTl9lv9tYKHJ
export HCP_CLIENT_SECRET=abcdef123mPwF7VIOuHDdthq42V0fUQBLbq-ZxadCMT5WaJW925bbXN9UJ9zBut9
export AWS_ACCESS_KEY_ID=
export AWS_SECRET_ACCESS_KEY=
```
The above are defined on a Terminal session for one-time use or in a <tt>~/.zshrc</tt> or <tt>~/.bash_profile</tt> file to be run when a Terminal window is created.

Below are steps to obtain the values above:

1.  Log into the HCP portal at:
    <a target="_blank" href="https://portal.cloud.hashicorp.com/access/service-principals">https://portal.cloud.hashicorp.com/access/service-principals</a>

    NOTE: HCP has a 7-minute interaction timeout.
   
2.  Click "Sign in" or "Create an account" (for an "org" to work with).
3.  Click "Access control (IAM)" on the left menu item under your org
4.  Click "Service principals" (which act like users on behalf of a service).
5.  Click the blue "Create Service principal".
6.  Specify a Name (for example, JohnDoe-23-12-31) for a Contributor.

    PROTIP: Some prefer to add a date to make it easier to identify when it's time to refresh credentials.

7.  Click "Save" for the creation toast at the lower left. 
8.  Click "Generate key" at the right or "Create service principal key" in the middle of the screen.
9.  Click the icon for the <strong>Client ID</strong> to copy it into your Clipboard.
10. Switch to your Terminal to type, then paste from Clipboard a command such as:

    ```bash
    export HCP_CLIENT_ID=1234oTzq81L6DxXmQrrfkTl9lv9tYKHJ
    ```
11. Switch back to HCP.
12. Click the icon for the <strong>Client secret</strong> to copy it into your Clipboard.
13. Switch to your Terminal to type, then paste from Clipboard a command such as:

    ```bash
    export HCP_CLIENT_SECRET=abcdef123mPwF7VIOuHDdthq42V0fUQBLbq-ZxadCMT5WaJW925bbXN9UJ9zBut9
    ```

    <a name="SetAWSEnv"></a>

    ### Set AWS environment variables:

14. Export your AWS Account credentials (such as from Doormat), as defined by the AWS Terraform provider:
    ```bash
    export AWS_ACCESS_KEY_ID=
    export AWS_SECRET_ACCESS_KEY=
    ```
15. Set the environment variables by pressing Enter on the Terminal or running <tt>source ~/.zshrc</tt> or <tt>~/.bash_profile</tt>

    <a name="SelectExample"></a>
    
    ### Select Example Deploy
 
16. Use your favorite editor to navigate into the <tt>examples</tt> folder:

    Select <tt>full-deploy</tt>

17. cd into one of the <a target="_blank" href=https://github.com/stoffee/terraform-hcp-vault-eks/tree/primary/examples>[examples]</a> example deployments.

    <a name="Edit_tfvars"></a>

    ### Edit sample.auto.tfvars

18. Rename <tt>sample.auto.tfvars_example</tt> to <tt>sample.auto.tfvars</tt>

    ```bash
    cp sample.auto.tfvars_example sample.auto.tfvars
    ```
    NOTE: The file <tt>sample.auto.tfvars</tt> is specified in the repo's <tt>.gitignore</tt> file so it doesn't get uploaded into GitHub.

19. Edit the file to customize your install.

    <pre>cluster_id = "blue-blazer"
    deploy_hvn = true
    hvn_id               = "eks-hvn"
    hvn_region           = "us-west-2"
    deploy_vault_cluster = true
    # uncomment this if setting deploy_vault_cluster to false for an existing vault cluster
    #hcp_vault_cluster_id = "vault-mycompany-io"
    make_vault_public    = true
    deploy_eks_cluster   = true
    vpc_region           = "us-west-2"
    </pre>
    
    <a name="DeployTF"></a>

    ### Run Terraform to Deploy

20. Initialize and apply the Terraform configuration to get a customized environment. Ensure you view the plan details and approve with a yes.

    ```bash
    terraform init
    terraform plan
    terraform apply
    ```

    If successful, you should see metadata about your instance:
    <pre>cluster_security_group_arn = "arn:aws:ec2:us-west-2:123456789123:security-group/sg-081e335dd11b10860"
    cluster_security_group_id = "sg-081e335dd11b10860"
    eks_cluster_arn = "arn:aws:eks:us-west-2:123456789123:cluster/brown-blazer-eks"
    eks_cluster_certificate_authority_data = "...=="
    eks_cluster_endpoint = "https://1A2B3C4D5E6F4B5F9C8FC755105FAA00.gr7.us-west-2.eks.amazonaws.com"
    eks_cluster_name = "brown-blazer-eks"
    eks_cluster_oidc_issuer_url = "https://oidc.eks.us-west-2.amazonaws.com/id/1A2B3C4D5E6F4B5F9C8FC755105FAA00"
    eks_cluster_platform_version = "eks.15"
    eks_cluster_status = "ACTIVE"
    kubeconfig_filename = &LT;&LT;EOT
    /Users/wilsonmar/githubs/terraform-hcp-vault-eks/examples/full-deploy/apiVersion: v1
    kind: ConfigMap
    metadata:
    name: aws-auth
    namespace: kube-system
    data:
    mapRoles: |
        - rolearn: arn:aws:iam::123456789123:role/node_group_01-eks-node-group-12340214203844029700000001
        username: system:node:{{EC2PrivateDNSName}}
        groups:
            - system:bootstrappers
            - system:nodes
    EOT
    node_security_group_arn = "arn:aws:ec2:us-west-2:123456789123:security-group/sg-abcdef123456789abc"
    node_security_group_id = "sg-abcdef123456789abc"
    vault_private_url = "https://hcp-vault-private-vault-9577a2dc.993dfd61.z1.hashicorp.cloud:8200"
    vault_public_url = "https://hcp-vault-public-vault-9577a2dc.993dfd61.z1.hashicorp.cloud:8200"
    vault_root_token = &LT;sensitive&LT;
    </pre>

    <a name="ConfirmHCP"></a>

    ### Confirm HCP

21. Switch back to the HCP screen to confirm what has been built:

    <a target="_blank" href="https://res.cloudinary.com/dcajqrroq/image/upload/v1676446677/hcp-vault-dev-320x475_gh8olg.jpg"><img src="https://res.cloudinary.com/dcajqrroq/image/upload/v1676446677/hcp-vault-dev-320x475_gh8olg.jpg"></a>
    

    <a name="AccessVault"></a>

    ### Access HCP Vault GUI:

21. Open a browser window to your HCP Vault cluster (on a Mac):

    ```bash
    open $(terraform output --raw vault_public_url)
    ```

    ```bash
    open $(terraform output --raw vault_private_url)
    ```

22. Obtain the Token to Sign in to Vault (on a Mac):

    ```bash
    terraform output --raw vault_root_token | pbcopy
    ```

    <a name="AccessEKS"></a>
    
    ### Access the EKS Cluster:

23. Obtain the contents of a kubeconfig file into your Clipboard:

    ```bash
    terraform output --raw kubeconfig_filename | pbcopy
    ```
24. Paste from Clipboard and remove the file path to yield:

    <pre>apiVersion: v1
    kind: ConfigMap
    metadata:
    name: aws-auth
    namespace: kube-system
    data:
    mapRoles: |
        - rolearn: arn:aws:iam::123456789123:role/node_group_01-eks-node-group-12340214203844029700000001
        username: system:node:{{EC2PrivateDNSName}}
        groups:
            - system:bootstrappers
            - system:nodes
    </pre>

25. setting the `KUBECONFIG` environment variable ???

    <a name="AccessDemoApp"></a>

    ### Use Vault in Demo App:

    **Warning**: This application is publicly accessible, make sure to delete the Kubernetes resources associated with the application when done.

26. Set your Vault Account credentials dynamically using your connection to HCP by copying these commands and running them on your Terminal:

    ```bash
    export VAULT_ADDR=$(terraform output --raw vault_public_url)
    export VAULT_TOKEN=$(terraform output --raw vault_root_token)
    export VAULT_namespace=admin
    ```

27. Use the values to work with secrets from your Vault client program or custom application.

    See [HashiCorp's Vault tutorials](https://developer.hashicorp.com/vault/tutorials?optInFrom=learn)

Alternatively, find this info in the HCP portal:

1.  On a browser login into HCP Portal:

    <a target="_blank" href="https://portal.cloud.hashicorp.com">https://portal.cloud.hashicorp.com</a>

2.  Click the name of your cluster (such as "my-vault").
3.  Click "Private" link at the right of "Cluster URLs" to obtain a URL such as this in your Clipboard:

    <a target="_blank" href="https://my-vault-private-vault-c6443333.9d787275.z1.hashicorp.cloud:8200">https://my-vault-private-vault-c6443333.9d787275.z1.hashicorp.cloud:8200</a>

4.  Click "Public" link at the right of "Cluster URLs" to obtain a URL such as this in your Clipboard:
    
    <a target="_blank" href="https://my-vault-public-vault-c6443333.9d787275.z1.hashicorp.cloud:8200">https://my-vault-public-vault-c6443333.9d787275.z1.hashicorp.cloud:8200</a>

5. Construct this line in Bash from your Clipboard contents from above:
   
    ```bash
    export VAULT_ADDR=https://my-vault-public-vault-c6443333.9d787275.z1.hashicorp.cloud:8200
    export VAULT_TOKEN=
    export VAULT_NAMESPACE=admin
    ```

6.  Setup cli auth for kubectl through awscli:

    ```bash
    aws eks --region us-west-2 update-kubeconfig --name $(terraform output --raw eks_cluster_name)
    terraform output --raw eks_cluster_name
    ```

    ### Configure Kube auth method for Vault:

7.  Grab the kube auth info and stick it in ENVVARS:
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

8.  Enable the auth method and write the Kubernetes auth info into Vault:
    ```bash
    vault auth enable kubernetes
    ```
    ```bash
    vault write auth/kubernetes/config \
    token_reviewer_jwt="$TOKEN_REVIEW_JWT" \
    kubernetes_host="$KUBE_HOST" \
    kubernetes_ca_cert="$KUBE_CA_CERT"
    ```

9.  Deploy Postgres:
    ```bash 
    kubectl apply -f files/postgres.yaml
    ```

10. Check that Postgres is running:
    ```bash
    kubectl get pods
    ```

11. Grab the Postgres IP and then configure the Vault DB secrets engine:
    ```bash
    export POSTGRES_IP=$(kubectl get service -o jsonpath='{.status.loadBalancer.ingress[0].hostname}' postgres)

    echo $POSTGRES_IP
    ```

12. Enable DB secrets:
    ```bash
    vault secrets enable database
    ```

13. Write the Vault configuration for the postgresDB deployed earlier:
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

14. Ensure we can create credentials on the postgresDB with Vault:
    ```bash
    vault read database/creds/product
    ```

15. Create policy in Vault:
    ```bash
    vault policy write product files/product.hcl

    vault write auth/kubernetes/role/product \
        bound_service_account_names=product \
        bound_service_account_namespaces=default \
        policies=product \
        ttl=1h
    ```

16. Deploy the product app:
    ```bash
    kubectl apply -f files/product.yaml
    ```

17. Check the product app is running before moving on:
    ```bash
    kubectl get pods
    ```

18. Set into background job:
    ```bash
    kubectl port-forward service/product 9090 &
    ```

19. Test the app retrieves coffee info
    ```bash
    curl -s localhost:9090/coffees | jq .
    ```
