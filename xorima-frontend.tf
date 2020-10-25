locals {
  xorima_hostnames = {
    label_validator     = "${var.app_hostname_prefix.label_validator}.xorima.${local.domain_config.base_domain}"
    json_version_bumper = "${var.app_hostname_prefix.json_version_bumper}.xorima.${local.domain_config.base_domain}"
    release_creator     = "${var.app_hostname_prefix.release_creator}.xorima.${local.domain_config.base_domain}"
    changelog_reset     = "${var.app_hostname_prefix.changelog_reset}.xorima.${local.domain_config.base_domain}"
    changelog_validator = "${var.app_hostname_prefix.changelog_validator}.xorima.${local.domain_config.base_domain}"
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
    hmac_secret_token  = var.github_hmac_secret_xorima
    github_token       = var.github_user_token
    github_admin_token = var.github_user_token
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


module "xorima-json-version-bumper" {
  source             = "./modules/json_version_bumper"
  kube_config        = local.kube_config
  namespace          = kubernetes_namespace.xorima-frontend.metadata[0].name
  app_version        = local.app_version.json_version_bumper
  github_secret_name = kubernetes_secret.webhook-github-xorima-frontend.metadata[0].name
  hostname           = local.xorima_hostnames.json_version_bumper
  target_repo        = "xorima/terraform-xorimabot"
  json_file_path     = "app_versions.json"
}

resource "cloudflare_record" "jsonversionbumper-xorima-frontend" {
  zone_id = local.cloudflare_dns_zone_id
  name    = local.xorima_hostnames.json_version_bumper
  value   = local.kubernetes_public_ip
  type    = "A"
  ttl     = 1
}


module "xorima-release-creator" {
  source             = "./modules/release_creator"
  kube_config        = local.kube_config
  namespace          = kubernetes_namespace.xorima-frontend.metadata[0].name
  app_version        = local.app_version.release_creator
  github_secret_name = kubernetes_secret.webhook-github-xorima-frontend.metadata[0].name
  hostname           = local.xorima_hostnames.release_creator
}

resource "cloudflare_record" "release-creator-xorima-frontend" {
  zone_id = local.cloudflare_dns_zone_id
  name    = local.xorima_hostnames.release_creator
  value   = local.kubernetes_public_ip
  type    = "A"
  ttl     = 1
}

module "xorima-changelog-reset" {
  source             = "./modules/changelog_reset"
  kube_config        = local.kube_config
  namespace          = kubernetes_namespace.xorima-frontend.metadata[0].name
  app_version        = local.app_version.changelog_reset
  github_secret_name = kubernetes_secret.webhook-github-xorima-frontend.metadata[0].name
  hostname           = local.xorima_hostnames.changelog_reset
}

resource "cloudflare_record" "changelog-reset-xorima-frontend" {
  zone_id = local.cloudflare_dns_zone_id
  name    = local.xorima_hostnames.changelog_reset
  value   = local.kubernetes_public_ip
  type    = "A"
  ttl     = 1
}

module "xorima-changelog-validator" {
  source             = "./modules/changelog_validator"
  kube_config        = local.kube_config
  namespace          = kubernetes_namespace.xorima-frontend.metadata[0].name
  app_version        = local.app_version.changelog_validator
  github_secret_name = kubernetes_secret.webhook-github-xorima-frontend.metadata[0].name
  hostname           = local.xorima_hostnames.changelog_validator
}

resource "cloudflare_record" "changelog-validator-xorima-frontend" {
  zone_id = local.cloudflare_dns_zone_id
  name    = local.xorima_hostnames.changelog_validator
  value   = local.kubernetes_public_ip
  type    = "A"
  ttl     = 1
}
