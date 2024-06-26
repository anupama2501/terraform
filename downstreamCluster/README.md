# Purpose of this Script

> There are multiple folders with terraform script to easily create downstream node driver clusters with either 3 nodes having 1 role in each pool or 1 node all role cluster


## Setup Guide

1. Install Terraform on your local machine, instructions located here: [https://learn.hashicorp.com/tutorials/terraform/install-cli](https://learn.hashicorp.com/tutorials/terraform/install-cli)


```tf
# Variable Section

# Linode Specific Variables
linode_access_token      = "your-linode-api-token-you-create-on-linode"

# Cluster spefic variables

kubernetes_version #optional. If no version is provided, default value in the script will be considered.

### How to run 

After following the Setup Guide above

1. Run the following commands
2. `terraform init`
3. `terraform plan`
4. `terraform apply`
5. It will ask you to verify what you're creating by typing `Yes` it's a good idea to check and make sure terraform is creating what you're expecting. 
6. You can watch the log output, at the very end you will recieve Apply Complete and the cluster will be created. 


```

### What Gets Created

Following downstream clusters are created:

- RKE2 node driver 1 node all roles
- RKE2 node driver 3 nodes 1 role on each node.
- K3s node driver 1 node all roles
- K3s node driver 3 nodes 1 role on each node.
- RKE node driver 1 node all roles
- RKE node driver 3 nodes 1 role on each node.


