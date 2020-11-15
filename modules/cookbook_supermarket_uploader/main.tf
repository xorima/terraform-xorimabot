resource "kubernetes_deployment" "deployment" {
  metadata {
    name      = "cookbook-supermarket-uploader"
    namespace = var.namespace
    labels = {
      app = "cookbook-supermarket-uploader"
    }

  }
  spec {
    replicas = 2
    selector {
      match_labels = {
        app = "cookbook-supermarket-uploader"
      }
    }
    template {
      metadata {
        labels = {
          app = "cookbook-supermarket-uploader"
        }
      }
      spec {
        container {
          name  = "cookbook-supermarket-uploader"
          image = "xorima/cookbook_supermarket_uploader:${var.app_version}"

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

          env {
            name = "NODE_NAME"
            value_from {
              secret_key_ref {
                name = var.supermarket_secret_name
                key  = "node_name"
              }
            }
          }

          env {
            name  = "CLIENT_KEY"
            value = "/tmp/supermarket/client_key"
          }

          volume_mount {
            mount_path = "/tmp/supermarket"
            name       = "client-key"
          }




        }
        volume {
          name = "client-key"
          secret {
            secret_name = var.supermarket_secret_name
            items {
              key  = "client_key"
              path = "client_key"
            }
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "service" {
  metadata {
    name      = "cookbook-supermarket-uploader"
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
    name      = "cookbook-supermarket-uploader"
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
      secret_name = "cookbook-supermarket-uploader-tls"
    }

  }
}