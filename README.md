# HCP Vault EKS Module

This repo contains a Terraform module creates a full deployment of a HCP Vault cluster
with an AWS EKS cluster and VPC peering. This module can also be customized to only deploy what you need.

This automates <a target="_blank" href="https://developer.hashicorp.com/vault/tutorials/cloud/get-started-vault">manual steps</a>.

## Deployment

A. <a href="#SetHCPEnv">Set HCP environment variables</a><br />
B. <a href="#SelectExample">Select Example Deploy</a><br />
C. <a href="#Edit_tfvars">Edit sample.auto.tfvars</a><br />
D. <a href="#SetAWSEnv">Set AWS environment variables</a><br />
E. <a href="#DeployTF">Run Terraform to Deploy</a><br />
F. <a href="#ConfirmHCP">Confirm HCP</a><br />
G. <a href="#AccessVault">Obtain HCP Vault GUI URL</a><br />
H. <a href="#AccessDemoApp">Access Vault API</a><br />

I. <a href="#Upgrade">Upgrade for reliability</a><br />
J. <a href="#DeleteVault">Delete Vault instance</a><br />

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

<a name="SignInHCP"></a>
1.  Reach the HCP portal at this URL:
    <a target="_blank" href="https://portal.cloud.hashicorp.com/">https://portal.cloud.hashicorp.com</a>
2.  Click "Sign in" or first "Create an account" (for an "org" to work with) to reach the Dashboard for your organization listed at the bottom-left.
3.  PROTIP: To quickly reach the URL specific to your org, save it to your bookmarks in your browser.
4.  PROTIP: HCP has a 7-minute interaction timeout. So many users auto-populate the browser form using 1Password, which stores and retrieves credentials locally.
   
5.  Click "Access control (IAM)" on the left menu item under your org.
6.  Click "Service principals" (which act like users on behalf of a service).
7.  Click the blue "Create Service principal".
8.  Specify a Name (for example, JohnDoe-23-12-31) for a Contributor.

    PROTIP: Add a date (such as 23-12-31) to make it easier to identify when it's time to refresh credentials.

9.  Click "Save" for the creation toast at the lower left. 
10. Click "Generate key" at the right or "Create service principal key" in the middle of the screen.
11. Click the icon for the <strong>Client ID</strong> to copy it into your Clipboard.
12. Switch to your Terminal to type, then paste from Clipboard a command such as:
    ```bash
    export HCP_CLIENT_ID=1234oTzq81L6DxXmQrrfkTl9lv9tYKHJ
    ```
13. Switch back to HCP.
14. Click the icon for the <strong>Client secret</strong> to copy it into your Clipboard.
15. Switch to your Terminal to type, then paste from Clipboard a command such as:
    ```bash
    export HCP_CLIENT_SECRET=abcdef123mPwF7VIOuHDdthq42V0fUQBLbq-ZxadCMT5WaJW925bbXN9UJ9zBut9
    ```

    <a name="SelectExample"></a>
    
    ### Select Example Deploy
 
18. Obtain a copy of the repository onto your laptop:
    ```bash
    git clone git@github.com:stoffee/terraform-hcp-vault-eks.git
    cd terraform-hcp-vault-eks
    ```
19. Since the <tt>main</tt> branch of this repo is under active change and thus may be unstable, copy to your Clipboard the last stable release of this repo to use at:

    <a target="_blank" href="https://github.com/stoffee/terraform-hcp-vault-eks/releases">
    https://github.com/stoffee/terraform-hcp-vault-eks/releases</a>

20. Set the repo to the release tag identified in the step above (such as "v0.0.6"):

    ```bash
    git checkout "v0.0.g"
    ```
21. Navigate into one of the <a target="_blank" href=https://github.com/stoffee/terraform-hcp-vault-eks/tree/primary/examples>[example]</a> deployment folders:

    ```bash
    cd examples
    cd full-deploy
    ```
    Alternately, the <tt>eks-hvn-only-deploy</tt> only creates the HVN (HashiCorp Network), which in AWS is the VPC (Virtual Private Cloud).

    TODO: A <tt>prod</tt> sample will be available.

    <a name="Edit_tfvars"></a>

    ### Edit sample.auto.tfvars

22. Rename <tt>sample.auto.tfvars_example</tt> to <tt>sample.auto.tfvars</tt>

    ```bash
    cp sample.auto.tfvars_example sample.auto.tfvars
    ```
    NOTE: The file <tt>sample.auto.tfvars</tt> is specified in the repo's <tt>.gitignore</tt> file so it doesn't get uploaded into GitHub.

23. Use a text editor program to customize the <tt>sample.auto.tfvars</tt> file. For example:

    <pre>cluster_id = "blue-blazer"
    deploy_hvn = true
    hvn_id               = "dev-eks-hvn"
    hvn_region           = "us-west-2"
    vpc_region           = "us-west-2"
    deploy_vault_cluster = true
    # uncomment this if setting deploy_vault_cluster to false for an existing vault cluster
    #hcp_vault_cluster_id = "vault-mycompany-io"
    make_vault_public    = true
    deploy_eks_cluster   = true
    </pre>
    
    CAUTION: Having different <tt>hvn_region</tt> and <tt>vpc_region</tt> will result in expensive AWS cross-region data access fees and slower performance.


    <a name="SetAWSEnv"></a>

    ### Set AWS environment variables:

24. In the Terminal window you will use to run Terraform, set the AWS account credentials used to build your Vault instance:
    ```bash
    export AWS_ACCESS_KEY_ID=
    export AWS_SECRET_ACCESS_KEY=
    ```

    <a name="DeployTF"></a>

    ### Run Terraform to Deploy

25. In the same Terminal window as the above step (or within a CI/CD workflow), run the Terraform HCL to create the environment within AWS based on specifications in <tt>sample.auto.tfvars</tt>:
    ```bash
    terraform init
    terraform plan
    time terraform apply -auto-approve
    ```

    Alternately, those who work with Terraform frequently define aliases such as <tt>tfi</tt>, <tt>tfp</tt>, <tt>tfa</tt> to reduce keystrokes and avoid typos.

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

    <a name="AccessVault"></a>

    ### Obtain HCP Vault GUI URL:

26. Open a browser window to your HCP Vault cluster URL obtained automatically (on a Mac):

    ```bash
    open $(terraform output --raw vault_public_url)
    ```

    Alternately, if you're using a client within AWS:

    ```bash
    open $(terraform output --raw vault_private_url)
    ```
    
    <a target="_blank" href="https://res.cloudinary.com/dcajqrroq/image/upload/v1675396720/vault-hcp-signin-468x397_g5twps.jpg"><img width="400" src="https://res.cloudinary.com/dcajqrroq/image/upload/v1675396720/vault-hcp-signin-468x397_g5twps.jpg"></a>

27. PROTIP: Optionally, save the URL in your browser for quicker access in the future.

28. Copy the admin Token into your Clipboard for "Sign in to Vault" (on a Mac). 

    ```bash
    terraform output --raw vault_root_token | pbcopy
    ```
    CAUTION: Do not share that token with others. Create a separate account for each user.

29. Click in the <strong>Token</strong> field within the "Sign in" form, then paste the token.
30. Click the blue "Sign in".

    <a name="ConfirmHCP"></a>

    ### Confirm HCP

    Switch back to the HCP screen to confirm what has been built:

31. At the <a href="https://portal.cloud.hashicorp.com/">HCP dashboard</a>,
32. Click the blue "View Vault".
33. Click the Vault ID text -- the text above "Running" for the <strong>Overview</strong> page for your Vault instance managed by HCP.
34. PROTIP: For quicker access in the future, save the URL in your browser bookmarks. Let's examine the <strong>Cluster Details</strong> such as this:

    <a target="_blank" href="https://res.cloudinary.com/dcajqrroq/image/upload/v1676446677/hcp-vault-dev-320x475_gh8olg.jpg"><img src="https://res.cloudinary.com/dcajqrroq/image/upload/v1676446677/hcp-vault-dev-320x475_gh8olg.jpg"></a>
    
    Notice that the instance created is an instance that's "Extra Small", with No HA (High Availability).

    CAUTION: You should not depend on a <strong>Development</strong> instance for productive use. 

42. Click <strong>Replication</strong> on the left menu. Click "Read more about Vault replication".


    Upgrading to a "Standard" instance provides backup and auditing.

    Upgrade to obtain <a target="_blank" href="https://developer.hashicorp.com/vault/docs/enterprise/replication">replication</a> needed for reliability.


    <a name="AccessEKS"></a>
    
    ### Access the EKS Cluster:

35. Obtain the contents of a kubeconfig file into your Clipboard:

    ```bash
    terraform output --raw kubeconfig_filename | pbcopy
    ```
36. Paste from Clipboard and remove the file path to yield:

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

37. setting the `KUBECONFIG` environment variable ???

    <a name="AccessDemoApp"></a>

    ### Access Vault API

    **Warning**: This application is publicly accessible, make sure to delete the Kubernetes resources associated with the application when done.

38. Dynamically obtain credentials to the Vault instance managed by HCP by running running these commands on your Terminal:

    ```bash
    export VAULT_ADDR=$(terraform output --raw vault_public_url)
    export VAULT_TOKEN=$(terraform output --raw vault_root_token)
    export VAULT_namespace=admin
    ```

39. Use the values to work with secrets from your Vault client program or custom application.

    See [HashiCorp's Vault tutorials](https://developer.hashicorp.com/vault/tutorials?optInFrom=learn)

    <a name="Upgrade"></a>


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

19. Test the app retrieves coffee info:
    ```bash
    curl -s localhost:9090/coffees | jq .
    ```

<hr />

<a name="Upgrade"></a>

### Upgrade for reliability    

TODO:

https://developer.hashicorp.com/vault/docs/enterprise/replication

<hr />

<a name="DeleteVault"></a>

## Delete Vault Instance

PROTIP: Because this repo enables a new Vault cluster to be easily created in HCP, there is less hesitancy about destroying them (to save money and avoid confusion).

1.  CAUTION: PROTIP: Save secrets data stored in your Vault instance before deleting. Security-minded enterprises transfer backup files to folders controlled by a different AWS account so that backups can't be deleted by the same account which created them.
2.  PROTIP: Well ahead of this action, notify all users and obtain their acknowledgments.

3.  <a href="#SignInHCP">Sign in HCP Portal GUI</a> as an Administrator, at the <strong>Overview</strong> page of your Vault instance in HCP.
4.  PROTIP: Click <strong>API Lock</strong> to stop all users from updating data in the Vault instance.

5.  If you ran Terraform to create the cluster, there is no need to click <strong>Manage</strong> at the upper right for this menu:

    <a target="_blank" href="https://res.cloudinary.com/dcajqrroq/image/upload/v1675389154/vault-hcp-manage-drop-410x306_ehwn0c.jpg"><img width="400" src="https://res.cloudinary.com/dcajqrroq/image/upload/v1675389154/vault-hcp-manage-drop-410x306_ehwn0c.jpg"></a>

    DO NOT click the red <strong>Delete cluster</strong> square nor type "DELETE" to confirm.

6.  In your Mac Terminal, set credentials for the same AWS account you used to create the cluster.
7.  <a href="#SelectExample">navigate to the folder</a> holding the <tt>sample.auto.tfvars</tt> file when Terraform was run.
8.  There should be files <tt>terraform.tfstate</tt> and <tt>terraform.tfstate.backup</tt>
    ```bash
    ls terraform.*
    ```
9.  Run:
    ```bash
    time terraform destroy -auto-respond
    ```
    Successful completion would be a response such as:
    <pre>module.hcp-eks.module.vpc.aws_vpc.this[0]: Destruction complete after 0s
    &nbsp;
    Destroy complete! Resources: 58 destroyed.
    </pre>
    Time to complete the command has been typically 20-40 minutes.

10. Delete the files <tt>terraform.tfstate</tt> and <tt>terraform.tfstate.backup</tt>
    ```bash
    rm terraform.*
    ```
11. PROTIP: Send another notification to all users and obtain their acknowledgments.
12. If you saved the HCP Vault cluster URL to your browser bookmarks, remove it.
