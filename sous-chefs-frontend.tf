locals {
  sous_chefs_hostnames = {
    label_validator     = "${var.app_hostname_prefix.label_validator}.souschefs.${local.domain_config.base_domain}"
    json_version_bumper = "${var.app_hostname_prefix.json_version_bumper}.souschefs.${local.domain_config.base_domain}"
  }
}

resource "kubernetes_namespace" "sous-chefs-frontend" {
  metadata {
    labels = {
      purpose = "sous-chefs"
    }
    name = "sous-chefs-frontend"
  }
}

resource "kubernetes_secret" "webhook-github-sous-chef-frontend" {
  metadata {
    name      = "github-webhook"
    namespace = kubernetes_namespace.sous-chefs-frontend.metadata[0].name
  }

  data = {
    hmac_secret_token = var.github_hmac_secret_sous_chefs
    github_token      = var.github_user_token
  }
}


resource "kubernetes_deployment" "labelvalidator-sous-chef-frontend" {
  metadata {
    name      = "labelvalidator"
    namespace = kubernetes_namespace.sous-chefs-frontend.metadata[0].name
    labels = {
      app = "labelvalidator"
    }

  }
  spec {
    replicas = 2
    selector {
      match_labels = {
        app = "labelvalidator"
      }
    }
    template {
      metadata {
        labels = {
          app = "labelvalidator"
        }
      }
      spec {
        container {
          name  = "labelvalidator"
          image = "xorima/labelvalidator:${local.app_version.labelvalidator}"
          env {
            name = "SECRET_TOKEN"
            value_from {
              secret_key_ref {
                name = kubernetes_secret.webhook-github-sous-chef-frontend.metadata[0].name
                key  = "hmac_secret_token"
              }
            }
          }
          env {
            name = "GITHUB_TOKEN"
            value_from {
              secret_key_ref {
                name = kubernetes_secret.webhook-github-sous-chef-frontend.metadata[0].name
                key  = "github_token"
              }
            }
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "labelvalidator-sous-chef-frontend" {
  metadata {
    name      = "labelvalidator"
    namespace = kubernetes_namespace.sous-chefs-frontend.metadata.0.name
  }
  spec {
    selector = {
      app = kubernetes_deployment.labelvalidator-sous-chef-frontend.metadata.0.labels.app
    }
    port {
      protocol    = "TCP"
      port        = 80
      target_port = 4567
    }
  }
}

resource "kubernetes_ingress" "labelvalidator-sous-chef-frontend" {
  metadata {
    name      = "labelvalidator"
    namespace = kubernetes_namespace.sous-chefs-frontend.metadata.0.name
    annotations = {
      "cert-manager.io/cluster-issuer" = "letsencrypt-prod"
    }
  }
  spec {
    rule {
      host = local.sous_chefs_hostnames.label_validator
      http {
        path {
          path = "/"
          backend {
            service_name = kubernetes_service.labelvalidator-sous-chef-frontend.metadata.0.name
            service_port = kubernetes_service.labelvalidator-sous-chef-frontend.spec.0.port.0.port
          }
        }
      }
    }
    tls {
      hosts       = [local.sous_chefs_hostnames.label_validator]
      secret_name = "labelvalidator-tls"
    }

  }
}

resource "cloudflare_record" "labelvalidator-sous-chef-frontend" {
  zone_id = local.cloudflare_dns_zone_id
  name    = local.sous_chefs_hostnames.label_validator
  value   = local.kubernetes_public_ip
  type    = "A"
  ttl     = 1
}

resource "kubernetes_deployment" "jsonversionbumper-sous-chef-frontend" {
  metadata {
    name      = "jsonversionbumper"
    namespace = kubernetes_namespace.sous-chefs-frontend.metadata[0].name
    labels = {
      app = "jsonversionbumper"
    }

  }
  spec {
    replicas = 2
    selector {
      match_labels = {
        app = "jsonversionbumper"
      }
    }
    template {
      metadata {
        labels = {
          app = "jsonversionbumper"
        }
      }
      spec {
        container {
          name  = "jsonversionbumper"
          image = "xorima/json_version_bumper:${local.app_version.json_version_bumper}"

          env {
            name = "SECRET_TOKEN"
            value_from {
              secret_key_ref {
                name = kubernetes_secret.webhook-github-sous-chef-frontend.metadata[0].name
                key  = "hmac_secret_token"
              }
            }
          }

          env {
            name = "GITHUB_TOKEN"
            value_from {
              secret_key_ref {
                name = kubernetes_secret.webhook-github-sous-chef-frontend.metadata[0].name
                key  = "github_token"
              }
            }
          }

          env {
            name  = "JSON_FILE_PATH"
            value = "app_versions.json"
          }

          env {
            name  = "TARGET_REPO"
            value = "xorima/terraform-xorimabot"
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "jsonversionbumper-sous-chef-frontend" {
  metadata {
    name      = "jsonversionbumper"
    namespace = kubernetes_namespace.sous-chefs-frontend.metadata.0.name
  }
  spec {
    selector = {
      app = kubernetes_deployment.jsonversionbumper-sous-chef-frontend.metadata.0.labels.app
    }
    port {
      protocol    = "TCP"
      port        = 80
      target_port = 4567
    }
  }
}

resource "kubernetes_ingress" "jsonversionbumper-sous-chef-frontend" {
  metadata {
    name      = "jsonversionbumper"
    namespace = kubernetes_namespace.sous-chefs-frontend.metadata.0.name
    annotations = {
      "cert-manager.io/cluster-issuer" = "letsencrypt-prod"
    }
  }
  spec {
    rule {
      host = local.sous_chefs_hostnames.json_version_bumper
      http {
        path {
          path = "/"
          backend {
            service_name = kubernetes_service.jsonversionbumper-sous-chef-frontend.metadata.0.name
            service_port = kubernetes_service.jsonversionbumper-sous-chef-frontend.spec.0.port.0.port
          }
        }
      }
    }
    tls {
      hosts       = [local.sous_chefs_hostnames.json_version_bumper]
      secret_name = "jsonversionbumper-tls"
    }

  }
}

resource "cloudflare_record" "jsonversionbumper-sous-chef-frontend" {
  zone_id = local.cloudflare_dns_zone_id
  name    = local.sous_chefs_hostnames.json_version_bumper
  value   = local.kubernetes_public_ip
  type    = "A"
  ttl     = 1
}
