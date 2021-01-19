resource "kubernetes_deployment" "deployment" {
  metadata {
    name      = "deployment-status-slack-notifier"
    namespace = var.namespace
    labels = {
      app = "deployment-status-slack-notifier"
    }

  }
  spec {
    replicas = 2
    selector {
      match_labels = {
        app = "deployment-status-slack-notifier"
      }
    }
    template {
      metadata {
        labels = {
          app = "deployment-status-slack-notifier"
        }
      }
      spec {
        container {
          name  = "deployment-status-slack-notifier"
          image = "xorima/deployment_status_slack_notifier:${var.app_version}"

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
            name  = "SUCCESS_WEBHOOKS"
            value = var.success_webhooks
          }
          env {
            name  = "FAILURE_WEBHOOKS"
            value = var.failure_webhooks
          }
          env {
            name  = "ERROR_WEBHOOKS"
            value = var.error_webhooks
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "service" {
  metadata {
    name      = "deployment-status-slack-notifier"
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
    name      = "deployment-status-slack-notifier"
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
      secret_name = "deployment-status-slack-notifier-tls"
    }

  }
}