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



module "argo-cd" {
    source = "../modules/helm"
    name   = "argo-cd"
    repository = "https://argoproj.github.io/argo-helm"
    chart         = "argo-cd"
    chart_version = "9.4.17"
    namespace     = "argocd"   

    set = [
    {
      name  = "configs.secret.argocdServerAdminPassword"
      value = var.argocd_admin_password
    }
  ]

}


resource "null_resource" "argocd_appset" {
  depends_on = [module.argo-cd]

  provisioner "local-exec" {
    command = <<-EOT
      kubectl --kubeconfig ${var.kubeconfig_path} apply -f - <<'YAML'
      apiVersion: argoproj.io/v1alpha1
      kind: ApplicationSet
      metadata:
        name: projects-qa-only
        namespace: argocd
      spec:
        goTemplate: true
        goTemplateOptions:
          - missingkey=error
        generators:
          - list:
              elements:
                - app: app-1
                  cluster: k8s-qa
                - app: app-2
                  cluster: k8s-qa
        template:
          metadata:
            name: "{{.app}}-{{.cluster}}"
          spec:
            project: default
            source:
              repoURL: https://github.com/elevy99927/argo-demo-repo.git
              targetRevision: application
              path: "{{.app}}/{{.cluster}}"
            destination:
              server: https://kubernetes.default.svc
              namespace: "{{.app}}-{{.cluster}}"
            syncPolicy:
              automated:
                prune: true
                selfHeal: true
              syncOptions:
                - CreateNamespace=true
      YAML
    EOT
  }
}






# module "flux" {
#   source     = "../modules/helm"
#   name       = "flux2"
#   repository = "https://fluxcd-community.github.io/helm-charts"
#   chart         = "flux2"
#   chart_version = "2.18.2"
#   namespace     = "flux-system"
# }

# resource "null_resource" "gotk_sync" {
#   depends_on = [module.flux]

#   provisioner "local-exec" {
#     command = <<-EOT
#       ${local.ssh} 'kubectl apply --kubeconfig /etc/rancher/k3s/k3s.yaml -f -' << 'YAML'
#       apiVersion: source.toolkit.fluxcd.io/v1
#       kind: GitRepository
#       metadata:
#         name: flux-system
#         namespace: flux-system
#       spec:
#         interval: 1m0s
#         ref:
#           branch: gitops
#         url: https://github.com/leomerl/full-devops-k8s-iac-solution.git
#       ---
#       apiVersion: kustomize.toolkit.fluxcd.io/v1
#       kind: Kustomization
#       metadata:
#         name: flux-system
#         namespace: flux-system
#       spec:
#         interval: 10m0s
#         path: ./clusters/k3s
#         prune: true
#         sourceRef:
#           kind: GitRepository
#           name: flux-system
#       YAML
#     EOT
#   }
# }
