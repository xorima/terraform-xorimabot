resource "kubernetes_deployment" "deployment" {
  metadata {
    name      = "release-creator"
    namespace = var.namespace
    labels = {
      app = "release-creator"
    }

  }
  spec {
    replicas = 2
    selector {
      match_labels = {
        app = "release-creator"
      }
    }
    template {
      metadata {
        labels = {
          app = "release-creator"
        }
      }
      spec {
        container {
          name  = "release-creator"
          image = "xorima/release_creator:${var.app_version}"

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
                key  = "github_admin_token"
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
    name      = "release-creator"
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
    name      = "release-creator"
    namespace = var.namespace
    annotations = {
      "cert-manager.io/cluster-issuer" = "letsencrypt-prod"
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
      secret_name = "release-creator-tls"
    }
  }
}
