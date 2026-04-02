resource "null_resource" "kubeconfig" {
  depends_on = [module.k3s]

  provisioner "local-exec" {
    command = <<-EOT
      until ssh -i "${path.module}/${var.cluster_name}.pem" \
        -o StrictHostKeyChecking=no \
        -o ConnectTimeout=5 \
        ec2-user@${module.k3s.server_public_ip} \
        'kubectl get nodes --kubeconfig /etc/rancher/k3s/k3s.yaml 2>/dev/null | grep -q Ready' 2>/dev/null; do
        sleep 15
      done
      ssh -i "${path.module}/${var.cluster_name}.pem" \
        -o StrictHostKeyChecking=no \
        ec2-user@${module.k3s.server_public_ip} \
        'cat /etc/rancher/k3s/k3s.yaml' | \
        sed 's/127.0.0.1/${module.k3s.server_public_ip}/g' > "${path.module}/k3s.yaml"
    EOT
  }
}
