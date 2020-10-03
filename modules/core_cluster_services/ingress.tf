resource "kubernetes_namespace" "ingress" {
  metadata {
    labels = {
      purpose = "infrastructure"
    }
    name = var.namespace_ingress
  }
}

resource "helm_release" "nginx-ingress" {
  name            = "nginx-ingress"
  repository      = "https://helm.nginx.com/stable"
  chart           = "nginx-ingress"
  namespace       = var.namespace_ingress
  wait            = true
  cleanup_on_fail = true
  set {
    name  = "rbac.create"
    value = true
  }
  set {
    name  = "rbac.createRole"
    value = true
  }
  set {
    name  = "rbac.createClusterRole"
    value = true
  }
  set {
    name  = "controller.metrics.enabled"
    value = true
  }
  set {
    name  = "config.http2"
    value = true
  }
  set {
    name  = "config.redirect-to-https"
    value = false
  }
  set {
    name  = "config.proxy-buffer-size"
    value = "12k"
  }
  set {
    name  = "config.ssl-protocols"
    value = "TLSv1.2"
  }
  # set {
  #   name  = "config.ssl-ciphers"
  #   value = join(":", var.ssl_ciphers)

  # }
  set {
    name  = "config.ssl-prefer-server-ciphers"
    value = true
  }
  set {
    name  = "config.server-tokens"
    value = false
  }
}

data "kubernetes_service" "nginx-ingress" {
  metadata {
    name      = "nginx-ingress-nginx-ingress"
    namespace = "ingress"
  }
  depends_on = [
    helm_release.nginx-ingress,
  ]
}