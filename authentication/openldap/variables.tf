
variable "aws_access_key" {
  type        = string
  sensitive   = false
  description = "Access Token used for authenticating with AWS"
}

variable "aws_secret_key" {
  type        = string
  sensitive   = true
  description = "Secret Token used for authenticating with AWS"
}

variable "aws_ssh_key_name" {
  type        = string
  description = "the name of the key, already created in aws, that you will use to access the instances"
}

variable "aws_node_prefix" {
  type        = string
  description = "the prefix for the aws instances which will be created"
}
variable "aws_ami" {
  type        = string
  description = "Provide an ami with which the instance will be created"
  sensitive   = false
}

variable "aws_subnet" {
  type        = string
  description = "Provide a subnet with which the instance will be created"
  sensitive   = false

}

variable "aws_vpc" {
  type        = string
  description = "Provide a vpc with which the instance will be created"
  sensitive   = false
}

variable "aws_region" {
  type        = string
  default     = "us-east-2"
  description = "the region to provision the nodes in"
}

variable "domain" {
  type        = string
  description = "Openldap base domain"
}

variable "ldap_subdomain" {
  type = string
  validation {
    condition     = length(var.ldap_subdomain) > 0
    error_message = "The subdomain variable must be non-empty."
  }
  description = "subdomain for the openldap server"
}

variable "ldap_service_account_password" {
  type = string
  description = "Administrator password for the openldap server"
  sensitive   = true
}

variable "aws_node_size" {
  //Note: Use a smaller size at your own risk
  type        = string
  default     = "t3.large"
  description = "the size of the AWS instance that will run openldap"
  sensitive   = false
}

variable "user_name" {
  type        = string
  default     = "ubuntu"
  description = "username to ssh into the node"
}

variable "private_key_path" {
  type        = string
  description = "private key to log in to the ssh node"
  sensitive   = true
}

variable "user_login_password" {
  type = string
  description = "User password for the openldap user login. Note: Same password will be used for every user"
  sensitive   = true
}