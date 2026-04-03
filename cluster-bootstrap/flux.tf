data "terraform_remote_state" "k3s" {
  backend = "s3"
  config = {
    bucket = "levys-test-bucket"
    key    = "k3s/terraform.tfstate"
    region = "eu-west-1"
  }
}

locals {
  kubectl = "kubectl --kubeconfig /etc/rancher/k3s/k3s.yaml"
  ssh     = "ssh -i ${data.terraform_remote_state.k3s.outputs.ssh_key_path} -o StrictHostKeyChecking=no ec2-user@${data.terraform_remote_state.k3s.outputs.server_public_ip}"
}

module "flux" {
  source     = "../modules/helm"
  name       = "flux2"
  repository = "https://fluxcd-community.github.io/helm-charts"
  chart         = "flux2"
  chart_version = "2.18.2"
  namespace     = "flux-system"
}

resource "null_resource" "gotk_sync" {
  depends_on = [module.flux]

  provisioner "local-exec" {
    command = <<-EOT
      ${local.ssh} 'kubectl apply --kubeconfig /etc/rancher/k3s/k3s.yaml -f -' << 'YAML'
      apiVersion: source.toolkit.fluxcd.io/v1
      kind: GitRepository
      metadata:
        name: flux-system
        namespace: flux-system
      spec:
        interval: 1m0s
        ref:
          branch: gitops
        url: https://github.com/leomerl/full-devops-k8s-iac-solution.git
      ---
      apiVersion: kustomize.toolkit.fluxcd.io/v1
      kind: Kustomization
      metadata:
        name: flux-system
        namespace: flux-system
      spec:
        interval: 10m0s
        path: ./clusters/k3s
        prune: true
        sourceRef:
          kind: GitRepository
          name: flux-system
      YAML
    EOT
  }
}
