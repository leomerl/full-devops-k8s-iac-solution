
output "argocd-url" {
  value = "https://argocd.${data.terraform_remote_state.k3s.outputs.server_public_ip}.nip.io"
}

