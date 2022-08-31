terraform {
  required_providers {
    rancher2 = {
      source = "rancher/rancher2"
      version = "1.22.2"
    }
  }
}


provider "rancher2" {
  api_url    = var.rancher_api_url
  access_key = var.rancher_api_access_key
  secret_key = var.rancher_api_secret_key
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

# Create a new rke1 Node Template
resource "rancher2_node_template" "rke1-ntemplate" {
  name = "rke1-ntemplate"
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


# Create a new rke1 RKE Cluster for 3 node pools
resource "rancher2_cluster" "rke1-cluster-tf" {
  name = "rke1-cluster-tf"
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



# # Create a new rke1 Node Pool for each role
# Creates 3 pools for each role
resource "rancher2_node_pool" "pool-etcd" {
  cluster_id =  rancher2_cluster.rke1-cluster-tf.id
  name = "etcd"
  hostname_prefix =  "anupool-etcd"
  node_template_id = rancher2_node_template.rke1-ntemplate.id
  quantity = 1
  control_plane = false
  etcd = true
  worker = false
}

resource "rancher2_node_pool" "pool-cp" {
  cluster_id       = rancher2_cluster.rke1-cluster-tf.id
  name = "cp"
  hostname_prefix =  "anupool-cp"
  node_template_id = rancher2_node_template.rke1-ntemplate.id
  quantity         = 1
  control_plane    = true
  etcd             = false 
  worker           = false 
}

resource "rancher2_node_pool" "pool-worker" {
  cluster_id       = rancher2_cluster.rke1-cluster-tf.id
  name = "worker"
  hostname_prefix =  "anupool-worker"
  node_template_id = rancher2_node_template.rke1-ntemplate.id
  quantity         = 1
  control_plane    = false
  etcd             = false 
  worker           = true 
}

# # Create a new rke1 1 Node Pool for all roles
resource "rancher2_node_pool" "allroles" {
  cluster_id       = rancher2_cluster.rke1-cluster2-tf.id
  name = "all"
  hostname_prefix =  "anu-all"
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



# Create a new rke2 cluster
resource "rancher2_cluster_v2" "rke2-cluster-tf" {
  name = "rke2-cluster-tf"
  kubernetes_version = "v1.23.10+rke2r1"
  enable_network_policy = false
  default_cluster_role_for_project_members = "user"
  rke_config {
    machine_pools {
      name = "anu-rke2-etcd"
      cloud_credential_secret_name = rancher2_cloud_credential.linode_cred.id
      control_plane_role = false
      etcd_role = true
      worker_role = false
      quantity = 1
      machine_config {
        kind = rancher2_machine_config_v2.rke2-cluster1.kind
        name = rancher2_machine_config_v2.rke2-cluster1.name
      }
    }
        machine_pools {
      name = "anu-rke2-cp"
      cloud_credential_secret_name = rancher2_cloud_credential.linode_cred.id
      control_plane_role = true
      etcd_role = false
      worker_role = false
      quantity = 1
      machine_config {
        kind = rancher2_machine_config_v2.rke2-cluster1.kind
        name = rancher2_machine_config_v2.rke2-cluster1.name
      }
    }
    machine_pools {
      name = "anu-rke2-worker"
      cloud_credential_secret_name = rancher2_cloud_credential.linode_cred.id
      control_plane_role = false
      etcd_role = false
      worker_role = true
      quantity = 1
      machine_config {
        kind = rancher2_machine_config_v2.rke2-cluster1.kind
        name = rancher2_machine_config_v2.rke2-cluster1.name
      }
    }
        machine_global_config = <<EOF
cni: "calico"
disable-kube-proxy: false
etcd-expose-metrics: false
EOF
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