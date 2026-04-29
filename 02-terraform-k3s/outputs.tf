locals {
  ssh_key_path = abspath("${path.module}/${var.cluster_name}.pem")
}

output "server_public_ip" {
  value = module.k3s.server_public_ip
}

output "server_private_ip" {
  value = module.k3s.server_private_ip
}

output "kubeconfig_command" {
  value = module.k3s.kubeconfig_command
}

output "k3s_token" {
  value     = module.k3s.k3s_token
  sensitive = true
}

output "ssh_key_path" {
  value = local.ssh_key_path
}

output "ssh_login_cmd" {
  value = "ssh -i ${local.ssh_key_path} ec2-user@$(cat ${path.module}/../ServerIP.txt)"
}

output "k3s_token_file" {
  value = "K3S TOKEN: k3s-token.txt"
}

resource "local_file" "exported-server-ip" {
  content  = module.k3s.server_public_ip
  filename = "../ServerIP.txt"

}


