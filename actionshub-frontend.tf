locals {
  actionshub_hostnames = {
    label_validator     = "${var.app_hostname_prefix.label_validator}.actionshub.${local.domain_config.base_domain}"
    release_creator     = "${var.app_hostname_prefix.release_creator}.actionshub.${local.domain_config.base_domain}"
    changelog_reset     = "${var.app_hostname_prefix.changelog_reset}.actionshub.${local.domain_config.base_domain}"
    changelog_validator = "${var.app_hostname_prefix.changelog_validator}.actionshub.${local.domain_config.base_domain}"
  }
}

resource "kubernetes_namespace" "actionshub-frontend" {
  metadata {
    labels = {
      purpose = "actionshub"
    }
    name = "actionshub-frontend"
  }
}

resource "kubernetes_secret" "webhook-github-actionshub-frontend" {
  metadata {
    name      = "github-webhook"
    namespace = kubernetes_namespace.actionshub-frontend.metadata[0].name
  }

  data = {
    hmac_secret_token  = var.github_hmac_secret_actionshub
    github_token       = var.github_user_token
    github_admin_token = var.github_user_token
  }
}

module "actionshub-label_validator" {
  source             = "./modules/label_validator"
  kube_config        = local.kube_config
  namespace          = kubernetes_namespace.actionshub-frontend.metadata[0].name
  app_version        = local.app_version.labelvalidator
  github_secret_name = kubernetes_secret.webhook-github-actionshub-frontend.metadata[0].name
  hostname           = local.actionshub_hostnames.label_validator
}


resource "cloudflare_record" "labelvalidator-actionshub-frontend" {
  zone_id = local.cloudflare_dns_zone_id
  name    = local.actionshub_hostnames.label_validator
  value   = local.kubernetes_public_ip
  type    = "A"
  ttl     = 1
}


module "actionshub-release-creator" {
  source             = "./modules/release_creator"
  kube_config        = local.kube_config
  namespace          = kubernetes_namespace.actionshub-frontend.metadata[0].name
  app_version        = local.app_version.release_creator
  github_secret_name = kubernetes_secret.webhook-github-actionshub-frontend.metadata[0].name
  hostname           = local.actionshub_hostnames.release_creator
}

resource "cloudflare_record" "release-creator-actionshub-frontend" {
  zone_id = local.cloudflare_dns_zone_id
  name    = local.actionshub_hostnames.release_creator
  value   = local.kubernetes_public_ip
  type    = "A"
  ttl     = 1
}

module "actionshub-changelog-reset" {
  source             = "./modules/changelog_reset"
  kube_config        = local.kube_config
  namespace          = kubernetes_namespace.actionshub-frontend.metadata[0].name
  app_version        = local.app_version.changelog_reset
  github_secret_name = kubernetes_secret.webhook-github-actionshub-frontend.metadata[0].name
  hostname           = local.actionshub_hostnames.changelog_reset
}

resource "cloudflare_record" "changelog-reset-actionshub-frontend" {
  zone_id = local.cloudflare_dns_zone_id
  name    = local.actionshub_hostnames.changelog_reset
  value   = local.kubernetes_public_ip
  type    = "A"
  ttl     = 1
}

module "actionshub-changelog-validator" {
  source             = "./modules/changelog_validator"
  kube_config        = local.kube_config
  namespace          = kubernetes_namespace.actionshub-frontend.metadata[0].name
  app_version        = local.app_version.changelog_validator
  github_secret_name = kubernetes_secret.webhook-github-actionshub-frontend.metadata[0].name
  hostname           = local.actionshub_hostnames.changelog_validator
}

resource "cloudflare_record" "changelog-validator-actionshub-frontend" {
  zone_id = local.cloudflare_dns_zone_id
  name    = local.actionshub_hostnames.changelog_validator
  value   = local.kubernetes_public_ip
  type    = "A"
  ttl     = 1
}
