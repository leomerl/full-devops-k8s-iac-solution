

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


resource "null_resource" "applicationsets" {
  depends_on = [module.argo-cd]

  for_each = fileset("${path.module}/applicationsets", "*.yaml")

  provisioner "local-exec" {
    command = "kubectl --kubeconfig ${var.kubeconfig_path} apply -f ${path.module}/applicationsets/${each.value}"
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
