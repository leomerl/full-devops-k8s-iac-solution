module "argocd" {
  source = "../modules/argocd"

  chart = "argo-cd"
}
