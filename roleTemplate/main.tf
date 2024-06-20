terraform {
  required_providers {
    rancher2 = {
      source = "rancher/rancher2"
      version = "4.1.0"
    }
  }
}

provider "rancher2" {
  api_url   = var.rancher_url
  token_key = var.rancher_token_key
  insecure  = var.insecure
}


# Create a new rancher2 cluster Role Template
resource "rancher2_role_template" "clustertemplate" {
  name = var.roletemplate_name
  context = var.roletemplate_context
  default_role = true
  description = "Terraform role template external rules test"
  external = var.external_flag
  externalRules {
    api_groups = ["*"]
    resources = ["secrets"]
    verbs = ["create"]
  }
  rules {
    api_groups = ["*"]
    resources = ["secrets"]
    verbs = ["create"]
  }
}
