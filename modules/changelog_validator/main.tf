resource "kubernetes_deployment" "deployment" {
  metadata {
    name      = "changelog-validator"
    namespace = var.namespace
    labels = {
      app = "changelog-validator"
    }

  }
  spec {
    replicas = 2
    selector {
      match_labels = {
        app = "changelog-validator"
      }
    }
    template {
      metadata {
        labels = {
          app = "changelog-validator"
        }
      }
      spec {
        container {
          name  = "changelog-validator"
          image = "xorima/changelog_validator:${var.app_version}"

          env {
            name = "SECRET_TOKEN"
            value_from {
              secret_key_ref {
                name = var.github_secret_name
                key  = "hmac_secret_token"
              }
            }
          }

          env {
            name = "GITHUB_TOKEN"
            value_from {
              secret_key_ref {
                name = var.github_secret_name
                key  = "github_token"
              }
            }
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "service" {
  metadata {
    name      = "changelog-validator"
    namespace = var.namespace
  }
  spec {
    selector = {
      app = kubernetes_deployment.deployment.metadata.0.labels.app
    }
    port {
      protocol    = "TCP"
      port        = 80
      target_port = 4567
    }
  }
}

resource "kubernetes_ingress" "ingress" {
  metadata {
    name      = "changelog-validator"
    namespace = var.namespace
    annotations = {
      "cert-manager.io/cluster-issuer" = "letsencrypt-prod"
      "kubernetes.io/ingress.class"    = "nginx"
    }
  }
  spec {
    rule {
      host = var.hostname
      http {
        path {
          path = "/"
          backend {
            service_name = kubernetes_service.service.metadata.0.name
            service_port = kubernetes_service.service.spec.0.port.0.port
          }
        }
      }
    }
    tls {
      hosts       = [var.hostname]
      secret_name = "changelog-validator-tls"
    }
  }
}
