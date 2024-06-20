
variable "rancher_url" {
  type = string
  description = "Enter your rancher api URL"
}

variable "rancher_token_key"{
  type = string
  description = "Enter your token key"
  sensitive   = true
}

variable "insecure" {
  type        = bool
  description = "If using certs, set the flag to true otherwise false."
}

variable "roletemplate_name" {
  type        = string
  description = "Enter your desired name for your role template."
}

variable "roletemplate_context" {
  type        = string
  description = "Accepts cluster or project as context"
  sensitive   = true
}

variable "external_flag" {
  type        = bool
  description = "If creating role with external rules, set the flag to true otherwise false."
}