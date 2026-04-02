module "argocd" {
  source = "../modules/argocd"

  chart = "argo-cd"
}

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

resource "null_resource" "root_app" {
  depends_on = [module.argocd]

  provisioner "local-exec" {
    command = <<-EOT
      ${local.ssh} 'kubectl apply --kubeconfig /etc/rancher/k3s/k3s.yaml -f -' << 'YAML'
      apiVersion: argoproj.io/v1alpha1
      kind: Application
      metadata:
        name: root-app
        namespace: argocd
      spec:
        project: default
        source:
          repoURL: https://github.com/leomerl/full-devops-k8s-iac-solution.git
          targetRevision: main
          path: cluster-apps/apps
        destination:
          server: https://kubernetes.default.svc
          namespace: argocd
        syncPolicy:
          automated:
            prune: true
            selfHeal: true
      YAML
    EOT
  }
}

resource "null_resource" "root_app_sync" {
  depends_on = [null_resource.root_app]

  provisioner "local-exec" {
    command = <<-EOT
      ${local.ssh} '
        ${local.kubectl} -n argocd exec deploy/argocd-server -- \
          argocd app sync root-app --insecure --server argocd-server:443
        until ${local.kubectl} get app root-app -n argocd \
          -o jsonpath="{.status.sync.status}" 2>/dev/null | grep -q Synced; do
          sleep 10
        done
      '
    EOT
  }
}
