variable "linode_token" {
  type = string
  sensitive = true
  description = "your Linode token"
}

variable "linode_region" {
  type = string
  default = "us-west"
  description = "the region to provision the nodes in"
}

variable "linode_instance_type" {
  type = string
  default = "g6-standard-4"
  description = "CPU / memory / arch specs for a node, see linode api for full list"
}

variable "rke_k8s_version" {
  type = string
  description = "Kubernetes version to install"
}

variable "rke2_k8s_version" {
  type = string
  description = "Kubernetes version to install"
}

variable "rancher_api_url" {
  type = string
  description = "Enter your rancher api URL"
}

variable "rancher_api_access_key"{
  type = string
  description = "Enter your access key"
}

variable "rancher_api_secret_key"{
  type = string
  description = "Enter your secret key"
}


