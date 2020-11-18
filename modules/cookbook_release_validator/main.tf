resource "kubernetes_deployment" "deployment" {
  metadata {
    name      = "cookbook-release-validator"
    namespace = var.namespace
    labels = {
      app = "cookbook-release-validator"
    }

  }
  spec {
    replicas = 2
    selector {
      match_labels = {
        app = "cookbook-release-validator"
      }
    }
    template {
      metadata {
        labels = {
          app = "cookbook-release-validator"
        }
      }
      spec {
        container {
          name  = "cookbook-release-validator"
          image = "xorima/cookbook_release_validator:${var.app_version}"

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
    name      = "cookbook-release-validator"
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
    name      = "cookbook-release-validator"
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
      secret_name = "cookbook-release-validator-tls"
    }
  }
}
