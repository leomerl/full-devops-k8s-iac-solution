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


resource "null_resource" "get_k3s_token" {
  depends_on = [null_resource.kubeconfig]

  provisioner "local-exec" {
    command = <<-EOT
      ssh -i "${path.module}/${var.cluster_name}.pem" \
        -o StrictHostKeyChecking=no \
        ec2-user@${module.k3s.server_public_ip} \
        'sudo cat /var/lib/rancher/k3s/server/node-token' > "${path.module}/k3s-token.txt"
    EOT
  }
}

resource "null_resource" "cleanup" {
  depends_on = [null_resource.kubeconfig]

  provisioner "local-exec" {
    command = <<-EOT
        echo "================================"
        echo "=   Cleaning User-Data files.  ="
        echo "================================"
      ssh -i "${path.module}/${var.cluster_name}.pem" \
        -o StrictHostKeyChecking=no \
        ec2-user@${module.k3s.server_public_ip} \
        sudo rm -f /var/lib/cloud/instance/user-data.txt*  /var/lib/cloud/instance/scripts/part-001* /var/lib/cloud/instances/*/user-data.txt* /var/lib/cloud/instances/*/scripts/part-001*
    EOT
  }
}
