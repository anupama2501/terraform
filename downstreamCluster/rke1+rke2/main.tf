terraform {
  required_providers {
    rancher2 = {
      source = "rancher/rancher2"
      version = "4.1.0"
    }
  }
}


provider "rancher2" {
  api_url    = var.rancher_api_url
  token_key = var.rancher_bearer_token
  insecure = true
}

# ___________________________________________________RKE1ClusterCreation_________________________________________________

# Create a new rke1 Cloud Credential
resource "rancher2_cloud_credential" "linode_cred" {
  name = "linode_cred"
  description = "linode credentials"
  linode_credential_config {
  token = var.linode_token
  }
}

Create a new rke1 Node Template
resource "rancher2_node_template" "rke1-template" {
  name = "rke1-template"
  description = "rke1 test"
  engine_install_url = "https://releases.rancher.com/install-docker/20.10.sh"
  cloud_credential_id = rancher2_cloud_credential.linode_cred.id
  linode_config {
    instance_type= var.linode_instance_type
    region= var.linode_region
    image = "linode/ubuntu20.04"
    docker_port = "2376"
    ssh_port = "22"
  }
}


# Create a new rke1 RKE Cluster for 1 node pools all roles
resource "rancher2_cluster" "rke1-cluster2-tf" {
  name = "rke1-cluster2-tf"
  description = "RKE cluster created by TF"
  rke_config {
  kubernetes_version = var.rke_k8s_version
    network {
      plugin = "canal"
    }
    ingress{
      default_backend = false
      provider = "nginx"
    }
    monitoring {
      provider = "metrics-server"
      replicas = 1
    }
  }
}



# # Create a new rke1 1 Node Pool for all roles
resource "rancher2_node_pool" "allroles" {
  cluster_id       = rancher2_cluster.rke1-cluster2-tf.id
  name = "rke1-all"
  hostname_prefix =  "anu-rke1-all"
  node_template_id = rancher2_node_template.rke1-ntemplate.id
  quantity         = 1
  control_plane    = true
  etcd             = true 
  worker           = true 
}


# ___________________________________________________RKE2ClusterCreation_________________________________________________

# Create linode machine config v2
resource "rancher2_machine_config_v2" "rke2-cluster1" {
  generate_name = "anu-cluster1"
  linode_config {
    region = var.linode_region
  }
}

# Create linode machine config v2
resource "rancher2_machine_config_v2" "rke2-cluster2" {
  generate_name = "anu-cluster2"
  linode_config {
    region = var.linode_region
  }
}


# Create a new rke2 cluster 1 node all roles
resource "rancher2_cluster_v2" "rke2-cluster2-tf" {
  name = "rke2-cluster2-tf"
  kubernetes_version = "v1.23.10+rke2r1"
  enable_network_policy = false
  default_cluster_role_for_project_members = "user"
  rke_config {
    machine_pools {
      name = "anu-rke2-all"
      cloud_credential_secret_name = rancher2_cloud_credential.linode_cred.id
      control_plane_role = true
      etcd_role = true
      worker_role = true
      quantity = 1
      machine_config {
        kind = rancher2_machine_config_v2.rke2-cluster2.kind
        name = rancher2_machine_config_v2.rke2-cluster2.name
      }
    }
        machine_global_config = <<EOF
cni: "calico"
disable-kube-proxy: false
etcd-expose-metrics: false
EOF
  }
}


# ___________________________________________________K3SClusterCreation_________________________________________________


# Create a new k3s cluster 1 node all roles
resource "rancher2_cluster_v2" "k3s-cluster2-tf" {
  name = "k3s-cluster2-tf"
  kubernetes_version = "v1.30.1+k3s1"
  enable_network_policy = false
  default_cluster_role_for_project_members = "user"
  rke_config {
    machine_pools {
      name = "anu-k3s-all"
      cloud_credential_secret_name = rancher2_cloud_credential.linode_cred.id
      control_plane_role = true
      etcd_role = true
      worker_role = true
      quantity = 1
      machine_config {
        kind = rancher2_machine_config_v2.rke2-cluster2.kind
        name = rancher2_machine_config_v2.rke2-cluster2.name
      }
    }
        machine_global_config = <<EOF
cni: "calico"
disable-kube-proxy: false
etcd-expose-metrics: false
EOF
  }
}