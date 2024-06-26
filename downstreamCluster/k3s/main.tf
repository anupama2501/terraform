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

# Create a Cloud Credential
resource "rancher2_cloud_credential" "linode_cred" {
  name = "linode_cred"
  description = "linode credentials"
  linode_credential_config {
  token = var.linode_token
  }
}



# ___________________________________________________K3SClusterCreation_________________________________________________

# Create linode machine config v2
resource "rancher2_machine_config_v2" "k3s-tf-cluster" {
  generate_name = "k3s-tf-cluster"
  linode_config {
    region = var.linode_region
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
        kind = rancher2_machine_config_v2.k3s-tf-cluster.kind
        name = rancher2_machine_config_v2.k3s-tf-cluster.name
      }
    }
        machine_global_config = <<EOF
cni: "calico"
disable-kube-proxy: false
etcd-expose-metrics: false
EOF
  }
}


# Create a new k3s cluster with 3 nodes 1 role each
resource "rancher2_cluster_v2" "rke2-cluster-tf" {
  name = "rke2-cluster-tf"
  kubernetes_version = "v1.30.1+k3s1"
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