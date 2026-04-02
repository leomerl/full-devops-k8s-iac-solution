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
  value = abspath("${path.module}/${var.cluster_name}.pem")
}
