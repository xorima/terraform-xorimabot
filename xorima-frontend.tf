locals {
  xorima_hostnames = {
    label_validator     = "${var.app_hostname_prefix.label_validator}.xorima.${local.domain_config.base_domain}"
    json_version_bumper = "${var.app_hostname_prefix.json_version_bumper}.xorima.${local.domain_config.base_domain}"
  }
}

resource "kubernetes_namespace" "xorima-frontend" {
  metadata {
    labels = {
      purpose = "xorima"
    }
    name = "xorima-frontend"
  }
}

resource "kubernetes_secret" "webhook-github-xorima-frontend" {
  metadata {
    name      = "github-webhook"
    namespace = kubernetes_namespace.xorima-frontend.metadata[0].name
  }

  data = {
    hmac_secret_token = var.github_hmac_secret_xorima
    github_token      = var.github_user_token
  }
}

module "xorima-label_validator" {
  source             = "./modules/label_validator"
  kube_config        = local.kube_config
  namespace          = kubernetes_namespace.xorima-frontend.metadata[0].name
  app_version        = local.app_version.labelvalidator
  github_secret_name = kubernetes_secret.webhook-github-xorima-frontend.metadata[0].name
  hostname           = local.xorima_hostnames.label_validator
}


resource "cloudflare_record" "labelvalidator-xorima-frontend" {
  zone_id = local.cloudflare_dns_zone_id
  name    = local.xorima_hostnames.label_validator
  value   = local.kubernetes_public_ip
  type    = "A"
  ttl     = 1
}


resource "cloudflare_record" "jsonversionbumper-xorima-frontend" {
  zone_id = local.cloudflare_dns_zone_id
  name    = local.xorima_hostnames.json_version_bumper
  value   = local.kubernetes_public_ip
  type    = "A"
  ttl     = 1
}
