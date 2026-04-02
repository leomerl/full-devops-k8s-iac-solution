output "server_instance_id" {
  value = aws_instance.server.id
}

output "server_public_ip" {
  value = aws_instance.server.public_ip
}

output "server_private_ip" {
  value = aws_instance.server.private_ip
}

output "agent_instance_id" {
  value = var.create_agent ? aws_instance.agent[0].id : null
}

output "agent_public_ip" {
  value = var.create_agent ? aws_instance.agent[0].public_ip : null
}

output "k3s_token" {
  value     = random_password.k3s_token.result
  sensitive = true
}

output "kubeconfig_command" {
  description = "Fetch kubeconfig from the server (replace <key-file>)"
  value       = "ssh ec2-user@${aws_instance.server.public_ip} -i <key-file> 'cat /etc/rancher/k3s/k3s.yaml' | sed 's/127.0.0.1/${aws_instance.server.public_ip}/'"
}
