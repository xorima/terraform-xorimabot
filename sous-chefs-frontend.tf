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


module "sous-chefs-label_validator" {
  source             = "./modules/label_validator"
  kube_config        = local.kube_config
  namespace          = kubernetes_namespace.xorima-frontend.metadata[0].name
  app_version        = local.app_version.labelvalidator
  github_secret_name = kubernetes_secret.webhook-github-sous-chef-frontend.metadata[0].name
  hostname           = local.sous_chefs_hostnames.label_validator
}

resource "cloudflare_record" "labelvalidator-sous-chef-frontend" {
  zone_id = local.cloudflare_dns_zone_id
  name    = local.sous_chefs_hostnames.label_validator
  value   = local.kubernetes_public_ip
  type    = "A"
  ttl     = 1
}
