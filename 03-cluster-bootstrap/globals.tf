data "terraform_remote_state" "k3s" {
  backend = "s3"
  config = {
    bucket = "levy-test-bucket"
    key    = "k3s/terraform.tfstate"
    region = "eu-west-1"
  }
}

locals {
  kubectl = "kubectl --kubeconfig /etc/rancher/k3s/k3s.yaml"
  ssh     = "ssh -i ${data.terraform_remote_state.k3s.outputs.ssh_key_path} -o StrictHostKeyChecking=no ec2-user@${data.terraform_remote_state.k3s.outputs.server_public_ip}"
}

