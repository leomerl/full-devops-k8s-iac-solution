resource "null_resource" "get_k3s_token" {
  depends_on = [module.k3s]

  provisioner "local-exec" {
    command = <<-EOT
      echo "============================"
      echo "=   Save k3s Token localy  ="
      echo "============================"
      until ssh -i "${path.module}/${var.cluster_name}.pem" \
        -o StrictHostKeyChecking=no \
        -o ConnectTimeout=5 \
        ec2-user@${module.k3s.server_public_ip} \
        'sudo test -f /var/lib/rancher/k3s/server/node-token' 2>/dev/null; do
        sleep 10
      done
      ssh -i "${path.module}/${var.cluster_name}.pem" \
        -o StrictHostKeyChecking=no \
        ec2-user@${module.k3s.server_public_ip} \
        'sudo cat /var/lib/rancher/k3s/server/node-token' > "${path.module}/k3s-token.txt"
    EOT
  }
}

resource "null_resource" "wipe_userdata" {
  depends_on = [null_resource.get_k3s_token]

  provisioner "local-exec" {
    command = <<-EOT

      echo "=================================="
      echo "=   Wiping user-data from AWS    ="
      echo "= Need to Stop and Start machine ="
      echo "= ** This may take some time **  ="
      echo "=================================="

      echo "============================"
      echo "=  Step 1: Stop Instance   ="
      echo "============================"
      OLD_IP=$(aws ec2 describe-instances \
        --instance-ids ${module.k3s.server_instance_id} \
        --region ${var.AWS_REGION} \
        --query 'Reservations[0].Instances[0].PublicIpAddress' \
        --output text)

      aws ec2 stop-instances \
        --instance-ids ${module.k3s.server_instance_id} \
        --region ${var.AWS_REGION}
      aws ec2 wait instance-stopped \
        --instance-ids ${module.k3s.server_instance_id} \
        --region ${var.AWS_REGION}

      echo "==============================="
      echo "=  Step 2: wipe AWS metadata  ="
      echo "==============================="
      aws ec2 modify-instance-attribute \
        --instance-id ${module.k3s.server_instance_id} \
        --user-data Value="" \
        --region ${var.AWS_REGION}

      echo "==============================="
      echo "=   Step 3: Start Instance.   ="
      echo "==============================="
      aws ec2 start-instances \
        --instance-ids ${module.k3s.server_instance_id} \
        --region ${var.AWS_REGION}
      aws ec2 wait instance-running \
        --instance-ids ${module.k3s.server_instance_id} \
        --region ${var.AWS_REGION}

      echo "======================================"
      echo "=  Step 4: Updating kubeconfig & IP  ="
      echo "======================================"
      NEW_IP=$(aws ec2 describe-instances \
        --instance-ids ${module.k3s.server_instance_id} \
        --region ${var.AWS_REGION} \
        --query 'Reservations[0].Instances[0].PublicIpAddress' \
        --output text)
      echo "$NEW_IP" > "${path.module}/../ServerIP.txt"


      echo " update k3s cerificates"
      until ssh -i "${path.module}/${var.cluster_name}.pem" \
        -o StrictHostKeyChecking=no \
        -o ConnectTimeout=5 \
        ec2-user@$NEW_IP \
        "sudo sed -i 's/$OLD_IP/$NEW_IP/g' /etc/systemd/system/k3s.service" 2>/dev/null; do
        sleep 10
      done

      echo " restart k3s"
      until ssh -i "${path.module}/${var.cluster_name}.pem" \
        -o StrictHostKeyChecking=no \
        -o ConnectTimeout=5 \
        ec2-user@$NEW_IP \
        'sudo systemctl daemon-reload && sudo systemctl restart k3s' 2>/dev/null; do
        sleep 10
      done
           

  EOT
  }
}

resource "null_resource" "kubeconfig" {
  depends_on = [null_resource.wipe_userdata]

  provisioner "local-exec" {
    command = <<-EOT
      NEW_IP=$(cat ${path.module}/../ServerIP.txt)
      
      echo "==========================================="
      echo "=      Regenerate k3s TLS certs for       ="
      echo "=         new IP: $NEW_IP                 ="
      echo "==========================================="
      
      
      until ssh -i "${path.module}/${var.cluster_name}.pem" \
        -o StrictHostKeyChecking=no \
        -o ConnectTimeout=5 \
        ec2-user@$NEW_IP \
        'sudo test -f /var/lib/rancher/k3s/server/tls/serving-kube-apiserver.crt' 2>/dev/null; do
        sleep 10
      done
      ssh -i "${path.module}/${var.cluster_name}.pem" \
        -o StrictHostKeyChecking=no \
        ec2-user@$NEW_IP \
        'sudo rm -f /var/lib/rancher/k3s/server/tls/dynamic-cert.json /var/lib/rancher/k3s/server/tls/serving-kube-apiserver.crt /var/lib/rancher/k3s/server/tls/serving-kube-apiserver.key && sudo systemctl restart k3s'

      echo "= Waiting for k3s to be ready with new certs..."
      until ssh -i "${path.module}/${var.cluster_name}.pem" \
        -o StrictHostKeyChecking=no \
        -o ConnectTimeout=5 \
        ec2-user@$NEW_IP \
        'kubectl get nodes --kubeconfig /etc/rancher/k3s/k3s.yaml 2>/dev/null | grep -q Ready' 2>/dev/null; do
        sleep 10
      done

      echo "pulling kubeconfig to local machine..."
      ssh -i "${path.module}/${var.cluster_name}.pem" \
        -o StrictHostKeyChecking=no \
        ec2-user@$NEW_IP \
        'cat /etc/rancher/k3s/k3s.yaml' | \
        sed "s/127.0.0.1/$NEW_IP/g" > "${path.module}/k3s.yaml"

    EOT
  }
}

resource "null_resource" "cleanup" {
  depends_on = [null_resource.kubeconfig]

  provisioner "local-exec" {
    command = <<-EOT
      NEW_IP=$(cat ${path.module}/../ServerIP.txt)

      echo "===================================="
      echo "=     Cleaning User-Data files     ="
      echo "===================================="
      
      ssh -i "${path.module}/${var.cluster_name}.pem" \
        -o StrictHostKeyChecking=no \
        ec2-user@$NEW_IP \
        sudo rm -f /var/lib/cloud/instance/user-data.txt*  /var/lib/cloud/instance/scripts/part-001* /var/lib/cloud/instances/*/user-data.txt* /var/lib/cloud/instances/*/scripts/part-001*
  
    EOT
  }
}
