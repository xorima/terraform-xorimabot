resource "kubernetes_namespace" "ingress" {
  metadata {
    labels = {
      purpose = "infrastructure"
    }
    name = var.namespace_ingress
  }
}

resource "helm_release" "traefik" {
  name            = "traefik"
  repository      = "https://helm.traefik.io/traefik"
  chart           = "traefik"
  namespace       = var.namespace_ingress
  wait            = true
  cleanup_on_fail = true

  set {
    name  = "logs.level"
    value = "INFO"
  }

  set {
    name  = "logs.access.enabled"
    value = true
  }

  set {
    name = "dashboard.domain"
    value = "traefik.174.138.103.44.nip.io"
  }

}

data "kubernetes_service" "traefik" {
  metadata {
    name      = "traefik"
    namespace = "ingress"
  }

  depends_on = [
    helm_release.traefik,
  ]
}
