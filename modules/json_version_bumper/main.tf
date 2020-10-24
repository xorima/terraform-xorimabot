resource "kubernetes_deployment" "deployment" {
  metadata {
    name      = "json-version-bumper"
    namespace = var.namespace
    labels = {
      app = "json-version-bumper"
    }

  }
  spec {
    replicas = 2
    selector {
      match_labels = {
        app = "json-version-bumper"
      }
    }
    template {
      metadata {
        labels = {
          app = "json-version-bumper"
        }
      }
      spec {
        container {
          name  = "json-version-bumper"
          image = "xorima/json_version_bumper:${var.app_version}"

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
                name = github_secret_name
                key  = "github_admin_token"
              }
            }
          }

          env {
            name  = "JSON_FILE_PATH"
            value = var.json_file_path
          }

          env {
            name  = "TARGET_REPO"
            value = var.target_repo
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "service" {
  metadata {
    name      = "json-version-bumper"
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
    name      = "json-version-bumper"
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
      secret_name = "json-version-bumper-tls"
    }

  }
}