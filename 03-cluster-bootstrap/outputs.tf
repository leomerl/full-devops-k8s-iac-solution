
output "argocd-url" {
  value = "https://argocd.${data.terraform_remote_state.k3s.outputs.server_public_ip}.nip.io"
}


output "jenkins-url" {
   value = "JENKINS REMOVED"
}

output "temporal-url" {
   value = "http://${data.terraform_remote_state.k3s.outputs.server_public_ip}:32005 ... 10 minutes from now"
}


output "grafana-url" {
   value = "http://${data.terraform_remote_state.k3s.outputs.server_public_ip}.nip.io:32004 ... 10 minutes from now"


}