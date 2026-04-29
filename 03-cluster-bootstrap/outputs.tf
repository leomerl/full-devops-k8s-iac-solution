
output "argocd-url" {
  value = "https://argocd.${local.server_ip}.nip.io"
}


output "jenkins-url" {
   value = "JENKINS REMOVED"
}

output "temporal-url" {
   value = "http://${local.server_ip}:32005 ... 10 minutes from now"
}


output "grafana-url" {
   value = "http://${local.server_ip}.nip.io:32004 ... 10 minutes from now"


}