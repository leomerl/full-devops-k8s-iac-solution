resource "kubernetes_secret" "dockerhub_creds" {
  metadata {
    name      = "dockerhub-creds"
    namespace = "jenkins"
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
  metadata {
    name      = "github-token"
    namespace = "jenkins"
  }

  data = {
    "token" = var.github_token
  }
}
