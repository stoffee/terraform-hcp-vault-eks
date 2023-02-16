# HCP Vault EKS Module

<a target="_blank" href="https://github.com/stoffee/terraform-hcp-vault-eks">This repo</a> automates away the <a target="_blank" href="https://developer.hashicorp.com/vault/tutorials/cloud/get-started-vault">manual steps</a> to create a Vault EKS cluster managed by the HCP (HashiCorp Cloud Platform). This module can also be customized to only deploy what you need.


## Deployment

A. <a href="#Install">Install utility programs</a><br />
B. <a href="#SetHCPEnv">Set HCP environment variables</a><br />
C. <a href="#SelectExample">Select Example Deploy</a><br />
D. <a href="#Edit_tfvars">Edit options in sample.auto.tfvars</a><br />
E. <a href="#SetAWSEnv">Set AWS environment variables</a><br />
F. <a href="#DeployTF">Run Terraform to Deploy</a><br />

G. <a href="#ConfirmAWSGUI">Confirm resources in AWS GUI</a><br />
H. <a href="#ConfirmHCP">Confirm HCP</a><br />
I. &nbsp; <a href="#AccessVault">Obtain HCP Vault GUI URL</a><br />
J. <a href="#AccessDemoApp">Access Vault API</a><br />
K. <a href="#AccessEKS">Access the EKS Cluster</a><br />

L. <a href="#Upgrade">Manage Kubernetes</a><br />
M. <a href="#DestroyVault">Destroy Vault instance</a><br />

<hr />

<a name="Install"></a>

###     Install utility programs

1.  If you are using a MacOS machine, install Apple's utilities, then Homebrew formulas:

    <pre><strong>xcode select --install
    brew install  git  jq  awscli  tfsec  vault  kubectl
    </strong></pre>

    NOTE: HashiCorp Enterprise users instead use the Vault enterprise (vault-ent) program.

    
    <a name="SetHCPEnv"></a>

    ### Set HCP environment variables

    Below are steps to obtain credentials used to set up HCP within AWS:
    ```bash
    export HCP_CLIENT_ID=1234oTzq81L6DxXmQrrfkTl9lv9tYKHJ
    export HCP_CLIENT_SECRET=abcdef123mPwF7VIOuHDdthq42V0fUQBLbq-ZxadCMT5WaJW925bbXN9UJ9zBut9
    export AWS_ACCESS_KEY_ID=ZXYRQPONMLKJIHGFEDCBA
    export AWS_SECRET_ACCESS_KEY=abcdef12341uLY5oZCi5ILlWqyY++QpWEYnxz62w
    ```
    Most enterprises allocate AWS dynamically for a brief time (such as HashiCorp employees using "Bootcamp"). So the above are defined on a Terminal session for one-time use instead of being stored (long term, statically) in a <tt>~/.zshrc</tt> or <tt>~/.bash_profile</tt> file run automatically when a Terminal window is created.


    <a name="SignInHCP"></a>
2.  Be at the browser window which you want a new tab added to contain the URL in the next step:
3.  Click this URL to open the HCP portal:
    
    <a target="_blank" href="https://portal.cloud.hashicorp.com/">https://portal.cloud.hashicorp.com</a>

4.  Click "Sign in" or, if you haven't already, "Create an account" (for an "org" to work with) to reach the Dashboard for your organization listed at the bottom-left.

5.  PROTIP: To quickly reach the URL specific to your org, save it to your bookmarks in your browser.
6.  PROTIP: HCP has a 7-minute interaction timeout. So many users auto-populate the browser form using 1Password, which stores and retrieves credentials locally.
   
7.  Click "Access control (IAM)" on the left menu item under your org.
8.  Click "Service principals" (which act like users on behalf of a service).
9.  Click the blue "Create Service principal".
10. Specify a Name (for example, JohnDoe-23-12-31) for a Contributor.

    PROTIP: Add a date (such as 23-12-31) to make it easier to identify when it's time to refresh credentials.

11. Click "Save" for the creation toast at the lower left. 
12. Click "Generate key" at the right or "Create service principal key" in the middle of the screen.
13. Click the icon for the <strong>Client ID</strong> to copy it into your Clipboard.
14. Switch to your Terminal to type, then paste from Clipboard a command such as:
    ```bash
    export HCP_CLIENT_ID=1234oTzq81L6DxXmQrrfkTl9lv9tYKHJ
    ```
15. Switch back to HCP.
16. Click the icon for the <strong>Client secret</strong> to copy it into your Clipboard.
17. Switch to your Terminal to type, then paste from Clipboard a command such as:
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

20. Set the repo to the GitHub branch named by a release tag identified in the step above (such as "v0.0.6"):
    ```bash
    git checkout v0.0.6
    ```
21. Navigate into one of the <a target="_blank" href=https://github.com/stoffee/terraform-hcp-vault-eks/tree/primary/examples>example</a> folder of deployments:
    ```bash
    cd examples
    cd full-deploy
    ```
    NOTE: <tt><strong>full-deploy</strong></tt> example assumes the use of a "Development" tier of Vault instance size, which incur charges as described at
    <a target="_blank" href="https://cloud.hashicorp.com/products/vault/pricing">https://cloud.hashicorp.com/products/vault/pricing</a>.
    
    Alternately, the <tt><strong>eks-hvn-only-deploy</strong></tt> example only creates the HVN (HashiCorp Network), which in AWS is the VPC (Virtual Private Cloud).

    TODO: Example <tt><strong>prod-eks</strong></tt> (production-high availability) constructs (at a higher cost) features not in dev deploys:
    * Larger "Standard" type of servers
    * Vault clusters in each of the three Availability Zones within a single region
    * RBAC with least-privilege permissions (no wildcard resource specifications)
    * Encrypted communications, logging, and data at rest
    * Emitting VPC, CloudWatch, and other logs to a central repository for auditing and analysis by a central SOC (Security Operations Center)
    * <a target="_blank" href="https://n2ws.com/blog/how-to-guides/automate-amazon-ec2-instance-backup">Instance Backups</a>
    * <a target="_blank" href="https://aws.amazon.com/premiumsupport/knowledge-center/deleteontermination-ebs/">AWS Volume Purge Protection</a>
    * Node pools have automatic repair and auto-upgrade
    <br /><br />

    TODO: Example <tt><strong>dr-eks</strong></tt> (disaster recovery in production) example repeats example <tt>prod-eks</tt> to construct (at a higher cost) <strong>two regions</strong> for fail-over recovery.
    
    TODO: <a target="_blank" href="https://developer.hashicorp.com/vault/docs/enterprise/replication">Replication</a> for high transaction load.


    <a name="Edit_tfvars"></a>

    ### Edit options in sample.auto.tfvars

22. Rename <tt>sample.auto.tfvars_example</tt> to <tt>sample.auto.tfvars</tt>

    ```bash
    cp sample.auto.tfvars_example sample.auto.tfvars
    ```
    NOTE: The file <tt>sample.auto.tfvars</tt> is specified in the repo's <tt>.gitignore</tt> file so it doesn't get uploaded into GitHub.

23. Use a text editor program to customize the <tt>sample.auto.tfvars</tt> file. For example:

    <pre>cluster_id = "dev-blazer"
    deploy_hvn = true
    hvn_id               = "dev-eks"
    hvn_region           = "us-west-2"
    vpc_region           = "us-west-2"
    deploy_vault_cluster = true
    # uncomment this if setting deploy_vault_cluster to false for an existing vault cluster
    #hcp_vault_cluster_id = "vault-mycompany-io"
    make_vault_public    = true
    deploy_eks_cluster   = true
    </pre>
    
    CAUTION: Having a different hvn_region from <tt>vpc_region</tt> will result in expensive AWS cross-region data access fees and slower performance.

    NOTE: During deployment, Terraform HCL prepends the value of <tt>cluster_id</tt> (such as "dev-blazer") to construct resource names (such as "dev-blazer-eks" for <tt>eks_cluster_name</tt>, and <tt>eks_cluster_arn</tt> (such "dev-blazer-vps").


    <a name="SetAWSEnv"></a>

    ### Set AWS environment variables:

24. In the Terminal window, you will use to run Terraform in the next step, set the AWS account credentials used to build your Vault instance, such as:
    ```bash
    export AWS_ACCESS_KEY_ID=ZXYRQPONMLKJIHGFEDCBA
    export AWS_SECRET_ACCESS_KEY=abcdef12341uLY5oZCi5ILlWqyY++QpWEYnxz62w
    ```

    <a name="DeployTF"></a>

    ### Run Terraform to Deploy

25. In the same Terminal window as the above step (or within a CI/CD workflow), run a static scan for security vulnerabilities in Terraform HCL:
    ```bash
    tfsec | sed -r "s/\x1B\[([0-9]{1,2}(;[0-9]{1,2})?)?[m|K]//g"
    ```
    NOTE: The sed command filters out special characters used to display colors.

    WARNING: Do not continue until concerns raised by TFSec found are analyzed and remediated.


26. In the same Terminal window as the above step (or within a CI/CD workflow), run the Terraform HCL to create the environment within AWS based on specifications in <tt>sample.auto.tfvars</tt>:
    ```bash
    terraform init
    terraform plan
    time terraform apply -auto-approve
    ```

    Alternately, those who work with Terraform frequently define aliases such as <tt>tfi</tt>, <tt>tfp</tt>, <tt>tfa</tt> to reduce keystrokes and avoid typos.

    If successful, you should see metadata about your instance:
    <pre>cluster_security_group_arn = "arn:aws:ec2:us-west-2:123456789123:security-group/sg-081e335dd11b10860"
    cluster_security_group_id = "sg-081e335dd11b10860"
    eks_cluster_arn = "arn:aws:eks:us-west-2:123456789123:cluster/dev-blazer-eks"
    eks_cluster_certificate_authority_data = "...=="
    eks_cluster_endpoint = "https://1A2B3C4D5E6F4B5F9C8FC755105FAA00.gr7.us-west-2.eks.amazonaws.com"
    eks_cluster_name = "dev-blazer-eks"
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

    A sample time output shows 22 minutes 11 seconds total clock time:

    <pre>terraform apply -auto-approve  7.71s user 3.53s system 0% cpu 22:11.66 total</pre>

27. One helpful design feature of Terraform HCL is that it's "declarative". So <tt>terraform apply</tt> can be run again. A sample response if no changes need to be made:

    ```bash
    No changes. Your infrastructure matches the configuration.
    Terraform has compared your real infrastructure against your configuration and found no differences, so no changes are needed.
    ```

    NOTE: Terraform verifies the status of resources in the cloud, but does not verify the correctness of API calls to each service.


    <a name="ConfirmAWSGUI"></a>

    ### Confirm resources in AWS GUI

25. Use the AWS Account, User Name, and Password associated with the <a href="#SetAWSEnv">AWS variables</a> mentioned above to view different services in the AWS Management Console GUI:

    * <a target="_blank" href="https://console.aws.amazon.com/vpc/">VPC</a> (Virtual Private Cloud) with  Subnets, Route Tables, Gateways, Network ACLs, Peering, etc.
    * <a target="_blank" href="https://console.aws.amazon.com/ec2/">EC2</a> with Security Groups, Elastic IPs, Node Groups, Volumes, etc.
    * <a target="_blank" href="https://console.aws.amazon.com/eks/">Elastic Kubernetes Service</a>
    <br /><br />    

    NOTE: Vault in Development mode operates an in-memory database and so does not require an external database.

    <a name="AccessVault"></a>

    ### Obtain HCP Vault GUI URL:

26. Be at the browser window which you want a new tab added to contain the Vault UI.
27. Open a browser window to your HCP Vault cluster URL obtained automatically (on a Mac):

    ```bash
    open $(terraform output --raw vault_public_url)
    ```
    Alternately, if you're using a client within AWS:
    ```bash
    open $(terraform output --raw vault_private_url)
    ```
    Either way, you should see this form:

    <a target="_blank" href="https://res.cloudinary.com/dcajqrroq/image/upload/v1675396720/vault-hcp-signin-468x397_g5twps.jpg"><img width="400" src="https://res.cloudinary.com/dcajqrroq/image/upload/v1675396720/vault-hcp-signin-468x397_g5twps.jpg"></a>

28. PROTIP: Optionally, save the URL in your browser for quicker access in the future.

29. Copy the admin Token into your Clipboard for "Sign in to Vault" (on a Mac). 
    ```bash
    terraform output --raw vault_root_token | pbcopy
    ```
    That is equivalent to clicking <strong>Generate token</strong> under "New admin token" on your HCP Vault Overview page.

    CAUTION: Do not share this token with others. Create a separate account for each user.

30. Click <strong>Token</strong> selection under the "Method" heading within the "Sign in" form.

    NOTE: A generated token is one of <a target="_blank" href="https://developer.hashicorp.com/vault/docs/auth">many Authentication Methods</a> supported by Vault.

31. Click in the <strong>Token</strong> field within the "Sign in" form, then paste the token.

32. Click the blue "Sign in" (as Administrator).

    NOTE: As the Administrator, you have, by default, access to Vault's <a target="_blank" href="https://developer.hashicorp.com/vault/docs/secrets/cubbyhole">>cubbyhole/</a>. of the industry's widest support of <a target="_blank" href="https://developer.hashicorp.com/vault/docs/secrets">Secrets Engines</a>.

33. CAUTION: Use the Admin account only to do admin work:

    <a target="_blank" href="https://res.cloudinary.com/dcajqrroq/image/upload/v1675399191/vault-hcp-main-menu-485x53_lhdolz.jpg"><img width="485" height="53" src="https://res.cloudinary.com/dcajqrroq/image/upload/v1675399191/vault-hcp-main-menu-485x53_lhdolz.jpg"></a>

34. Click "Access" on the horizontal menu:

    <a target="_blank" href="https://res.cloudinary.com/dcajqrroq/image/upload/v1675424226/vault-hcp-access-menu-212x267_qkyci7.jpg"><img width="212" height="267" src="https://res.cloudinary.com/dcajqrroq/image/upload/v1675424226/vault-hcp-access-menu-212x267_qkyci7.jpg"></a>

35. Create an account for the Admin to use when developer persona work. This minimizes an attack vector for hackers.


    <a name="ConfirmHCP"></a>

    ### Confirm HCP

    Switch back to the HCP screen to confirm what has been built:

36. In an internet browser, go to the HCP portal at <a href="https://portal.cloud.hashicorp.com/">[HCP dashboard](https://portal.cloud.hashicorp.com)</a>
37. Click the blue "View Vault".
38. Click the Vault ID text -- the text above "Running" for the <strong>Overview</strong> page for your Vault instance managed by HCP.
39. PROTIP: For quicker access in the future, save the URL in your browser bookmarks. Let's examine the <strong>Cluster Details</strong> such as this:

    <a target="_blank" href="https://res.cloudinary.com/dcajqrroq/image/upload/v1676446677/hcp-vault-dev-320x475_gh8olg.jpg"><img src="https://res.cloudinary.com/dcajqrroq/image/upload/v1676446677/hcp-vault-dev-320x475_gh8olg.jpg"></a>
    
    Notice that the instance created is an instance that's "Extra Small", with No HA (High Availability) of clusters duplicated across several Availability Zones.

    CAUTION: You should not rely on a <strong>Development</strong> instance for productive use. 


    <a name="AccessDemoApp"></a>

    ### Access Vault API

    **Warning**: This application is publicly accessible, make sure to destroy the Kubernetes resources associated with the application when done.

38. Dynamically obtain credentials to the Vault cluster managed by HCP by running these commands on your Terminal:

    ```bash
    export VAULT_ADDR=$(terraform output --raw vault_public_url)
    export VAULT_TOKEN=$(terraform output --raw vault_root_token)
    export VAULT_namespace=admin
    ```
    Examples of such values are:

    * VAULT_ADDR = "https://hcp-vault-public-vault-9577a2dc.993dfd61.z1.hashicorp.cloud:8200"
    <br /><br />

    The above variables are sough by the Vault to authenticate client programs or custom applications.
    See <a target="_blank" href="https://developer.hashicorp.com/vault/tutorials?optInFrom=learn">HashiCorp's Vault tutorials</a>.



    <a name="AccessEKS"></a>
    
    ### Access the EKS Cluster:

37. Add new context AWS ARN into <tt>$HOME/.kube/config</tt> using awscli:

    ```bash
    aws eks --region us-west-2 update-kubeconfig \
    --name $(terraform output --raw eks_cluster_name)
    ```

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

37. TODO: Set the `KUBECONFIG` environment variable ???

    ### Configure Kube auth method for Vault:

40. Grab the kube auth info and stick it in ENVVARS:
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

41. Enable the auth method and write the Kubernetes auth info into Vault:
    ```bash
    vault auth enable kubernetes
    ```
    ```bash
    vault write auth/kubernetes/config \
    token_reviewer_jwt="$TOKEN_REVIEW_JWT" \
    kubernetes_host="$KUBE_HOST" \
    kubernetes_ca_cert="$KUBE_CA_CERT"
    ```

42. Deploy Postgres:
    ```bash 
    kubectl apply -f files/postgres.yaml
    ```

43. Check that Postgres is running:
    ```bash
    kubectl get pods
    ```

44. Grab the Postgres IP and then configure the Vault DB secrets engine:
    ```bash
    export POSTGRES_IP=$(kubectl get service -o jsonpath='{.status.loadBalancer.ingress[0].hostname}' postgres)

    echo $POSTGRES_IP
    ```

45. Enable DB secrets:
    ```bash
    vault secrets enable database
    ```

46. Write the Vault configuration for the postgresDB deployed earlier:
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

47. Ensure we can create credentials on the postgresDB with Vault:
    ```bash
    vault read database/creds/product
    ```

48. Create policy in Vault:
    ```bash
    vault policy write product files/product.hcl

    vault write auth/kubernetes/role/product \
        bound_service_account_names=product \
        bound_service_account_namespaces=default \
        policies=product \
        ttl=1h
    ```

49. Deploy the product app:
    ```bash
    kubectl apply -f files/product.yaml
    ```

50. Check the product app is running before moving on:
    ```bash
    kubectl get pods
    ```

51. Set into background job:
    ```bash
    kubectl port-forward service/product 9090 &
    ```

52. Test the app retrieves coffee info:
    ```bash
    curl -s localhost:9090/coffees | jq .
    ```

<hr />

<a name="DestroyVault"></a>

## Destroy Vault Instance

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

10. Remove the files <tt>terraform.tfstate</tt> and <tt>terraform.tfstate.backup</tt>
    ```bash
    rm terraform.*
    ```
11. PROTIP: Send another notification to all users and obtain their acknowledgments.
12. If you saved the HCP Vault cluster URL to your browser bookmarks, remove it.
