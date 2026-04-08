

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
        },
        {
          name  = "server.ingress.enabled"
          value = "true"
        },
        {
          name  = "server.ingress.hostname"
          value = "argocd.${data.terraform_remote_state.k3s.outputs.server_public_ip}.nip.io"
        },
        {
          name  = "server.ingress.ingressClassName"
          value = "traefik"
        },
        {
          name  = "configs.params.server\\.insecure"
          value = "true"
        },
        {
          name  = "server.ingress.annotations.traefik\\.ingress\\.kubernetes\\.io/router\\.entrypoints"
          value = "websecure"
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





resource "null_resource" "argo_path" {
  depends_on = [module.argo-cd]

  provisioner "local-exec" {
    command = <<-EOT
        kubectl --kubeconfig ${var.kubeconfig_path} -n argocd patch configmap argocd-cmd-params-cm --patch '{"data":{"server.insecure":"true"}}'
        kubectl --kubeconfig ${var.kubeconfig_path} -n argocd rollout restart deployment argo-cd-argocd-server
    EOT
  }
}