resource "kubernetes_namespace" "cert-manager" {
  metadata {
    labels = {
      purpose = "infrastructure"
    }
    name = var.namespace_cert_manager
  }

}

resource "helm_release" "cert-manager" {
  name       = "cert-manager"
  repository = "https://charts.jetstack.io"
  chart      = "cert-manager"
  namespace  = var.namespace_cert_manager

  set {
    name  = "installCRDs"
    value = true
  }
}

resource "kubernetes_secret" "cloudflare-api-token" {
  metadata {
    name      = var.cloudflare_config.secret_name
    namespace = var.namespace_cert_manager
  }
  data = {
    api-token = var.cloudflare_config.api_token
  }
}

resource "helm_release" "cluster-issuer" {
  name            = "cluster-issuer"
  chart           = "./charts/cluster-issuer"
  namespace       = var.namespace_cert_manager
  wait            = true
  cleanup_on_fail = true
  set {
    name  = "email"
    value = var.cloudflare_config.email
  }

  set {
    name  = "secretName"
    value = var.cloudflare_config.secret_name
  }

  set {
    name  = "secretKey"
    value = "api-token"
  }
}
