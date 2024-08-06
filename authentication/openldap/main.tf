resource "aws_instance" "provider_node" {
  ami     = var.aws_ami
  instance_type      = var.aws_node_size
  key_name = var.aws_ssh_key_name
  subnet_id = var.aws_subnet
  tags = {
    Name = var.aws_node_prefix
  }
}

data "aws_route53_zone" "primary" {
  name         = var.domain
  private_zone = false
}

resource "aws_route53_record" "domain" {
  zone_id = data.aws_route53_zone.primary.zone_id
  name = var.ldap_subdomain
  type = "A"
  ttl = 1800

  records = [
    aws_instance.provider_node.public_ip
  ]
}

output "hostname_ip" {
  value = aws_instance.provider_node.public_ip
}

resource "null_resource" "install_ldap" {
  provisioner "remote-exec" {
 inline = [
      "echo 'slapd slapd/internal/adminpw password ${var.ldap_service_account_password}' | sudo debconf-set-selections",
      "echo 'slapd slapd/internal/generated_adminpw password ${var.ldap_service_account_password}' | sudo debconf-set-selections",
      "echo 'slapd slapd/password2 password ${var.ldap_service_account_password}' | sudo debconf-set-selections",
      "echo 'slapd slapd/password1 password ${var.ldap_service_account_password}' | sudo debconf-set-selections",
      "echo 'slapd slapd/domain ${var.domain}' | sudo debconf-set-selections",  
      "sudo apt-get update",
      "sudo DEBIAN_FRONTEND=noninteractive apt-get install -y slapd ldap-utils",
      "echo '${local.ou_users_template_ldif_content}' > /tmp/add_ou_users.sh",
      "echo '${local.ou_groups_template_ldif_content}' > /tmp/add_ou_groups.sh",  
      "echo '${local.user_template_ldif_content}' > /tmp/add_users.sh",  
      "echo '${local.group_template_ldif_content}' > /tmp/add_groups.sh",  
      "echo '${local.run_all}' > /tmp/run_all.sh",  
      "chmod +x /tmp/*.sh",
      "sudo /tmp/run_all.sh ${var.ldap_service_account_password} ${var.user_login_password}",
    ]

    connection {
      type        = "ssh"
      user        = "ubuntu" 
      private_key = file(var.private_key_path)
      host        = aws_instance.provider_node.public_ip
    }
  }
}

provider "aws" {
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}

locals {
  ou_users_template_ldif_content = templatefile("${path.module}/templates/scripts/add_ou_users.sh", {})
  ou_groups_template_ldif_content = templatefile("${path.module}/templates/scripts/add_ou_groups.sh", {})
  user_template_ldif_content = templatefile("${path.module}/templates/scripts/add_user.sh", {})
  group_template_ldif_content = templatefile("${path.module}/templates/scripts/add_group.sh", {})
  run_all = templatefile("${path.module}/templates/scripts/run_all.sh", {})
}
