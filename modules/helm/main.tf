resource "helm_release" "this" {
  name             = var.name
  repository       = var.repository
  chart            = var.chart
  version          = var.chart_version
  namespace        = var.namespace
  create_namespace = true
  wait             = true

  dynamic "set" {
    for_each = var.set
    content {
      name  = set.value.name
      value = set.value.value
    }
  }


}
