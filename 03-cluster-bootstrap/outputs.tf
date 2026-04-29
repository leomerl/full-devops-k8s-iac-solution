
output "argocd-url" {
  value = "https://argocd.${local.server_ip}.nip.io"
}

output "jenkins-url" {
   value = "http://${local.server_ip}.nip.io:32001 ... 10 minutes from now"


}


output "grafana-url" {
   value = "http://${local.server_ip}.nip.io:32004 ... 10 minutes from now"


}


