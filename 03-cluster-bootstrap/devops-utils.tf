###
# Only create namespace for future instalations 
# for example: reflector

resource "kubernetes_namespace" "devops-utils" {
  metadata {
    name = "devops-utils"
  }
}