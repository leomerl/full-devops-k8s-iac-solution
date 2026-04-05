resource "kubernetes_secret" "docker-cred" {
  depends_on = [module.argo-cd]

  metadata {
    name      = "docker-cred"
    namespace = "argocd"
    annotations = {
      "reflector.v1.k8s.emberstack.com/reflection-allowed"            = "true"
      "reflector.v1.k8s.emberstack.com/reflection-allowed-namespaces" = ".*"
    }
  }

  data = {
    "config.json" = jsonencode({
      auths = {
        "https://index.docker.io/v1/" = {
          auth = base64encode("${var.dockerhub_username}:${var.dockerhub_token}")
        }
      }
    })
  }
}

resource "kubernetes_secret" "github_token" {
  depends_on = [module.argo-cd]

  metadata {
    name      = "github-token"
    namespace = "argocd"
    annotations = {
      "reflector.v1.k8s.emberstack.com/reflection-allowed"            = "true"
      "reflector.v1.k8s.emberstack.com/reflection-allowed-namespaces" = ".*"
    }
  }

  data = {
    "token" = var.github_token
  }
}

#########################################
# Define remote GitOps repo for argecd  #
#########################################
resource "kubernetes_secret" "argocd_repo" {
  depends_on = [module.argo-cd]

  metadata {
    name      = "argo-demo-repo"
    namespace = "argocd"
    labels = {
      "argocd.argoproj.io/secret-type" = "repository"
    }
  }

  data = {
    type     = "git"
    url      = "https://github.com/elevy99927/argo-demo-repo.git"
    username = "git"
    password = var.github_token
  }
}



# resource "kubernetes_secret" "argocd_admin" {
#   depends_on = [module.argo-cd]

#   metadata {
#     name      = "argocd-secret"
#     namespace = "argocd"
#   }

#   data = {
#     "admin.password" = var.argocd_admin_password
#   }
# }

# resource "kubernetes_secret" "weave_gitops_admin" {
#   depends_on = [module.argo-cd]

#   metadata {
#     name      = "weave-gitops-admin"
#     namespace = "argocd"
#   }

#   data = {
#     "passwordHash" = var.weave_gitops_password_hash
#   }
# }
