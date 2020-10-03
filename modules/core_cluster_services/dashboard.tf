resource "kubernetes_namespace" "kubernetes-dashboard" {
  metadata {
    labels = {
      purpose = "infrastructure"
    }
    name = var.namespace_dashboard
  }
}

resource "helm_release" "kubernetes-dashboard" {
  name            = "kubernetes-dashboard"
  repository      = "https://kubernetes.github.io/dashboard/"
  chart           = "kubernetes-dashboard"
  namespace       = var.namespace_dashboard
  wait            = true
  cleanup_on_fail = true
}
