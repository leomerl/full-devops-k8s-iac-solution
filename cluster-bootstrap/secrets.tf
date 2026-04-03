resource "kubernetes_secret" "dockerhub_creds" {
  depends_on = [module.flux]

  metadata {
    name      = "dockerhub-creds"
    namespace = "flux-system"
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
  depends_on = [module.flux]

  metadata {
    name      = "github-token"
    namespace = "flux-system"
    annotations = {
      "reflector.v1.k8s.emberstack.com/reflection-allowed"            = "true"
      "reflector.v1.k8s.emberstack.com/reflection-allowed-namespaces" = ".*"
    }
  }

  data = {
    "token" = var.github_token
  }
}
