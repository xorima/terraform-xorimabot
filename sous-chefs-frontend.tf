locals {
  sous_chefs_hostnames = {
    label_validator                  = "${var.app_hostname_prefix.label_validator}.souschefs.${local.domain_config.base_domain}"
    changelog_reset                  = "${var.app_hostname_prefix.changelog_reset}.souschefs.${local.domain_config.base_domain}"
    changelog_validator              = "${var.app_hostname_prefix.changelog_validator}.souschefs.${local.domain_config.base_domain}"
    cookbook_release_creator         = "${var.app_hostname_prefix.cookbook_release_creator}.souschefs.${local.domain_config.base_domain}"
    cookbook_supermarket_uploader    = "${var.app_hostname_prefix.cookbook_supermarket_uploader}.souschefs.${local.domain_config.base_domain}"
    deployment_status_slack_notifier = "${var.app_hostname_prefix.deployment_status_slack_notifier}.souschefs.${local.domain_config.base_domain}"
    cookbook_release_validator       = "${var.app_hostname_prefix.cookbook_release_validator}.souschefs.${local.domain_config.base_domain}"
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
    hmac_secret_token     = var.github_hmac_secret_sous_chefs
    github_token          = var.github_user_token
    github_admin_token    = var.github_admin_sous_chefs_token
    github_admin_username = var.github_admin_sous_chefs_config.username
  }
}

resource "kubernetes_secret" "webhook-supermarket-sous-chefs-frontend" {
  metadata {
    name      = "chef-supermarket"
    namespace = kubernetes_namespace.sous-chefs-frontend.metadata[0].name
  }

  data = {
    node_name  = var.supermarket_node_name
    client_key = var.supermarket_client_key
  }
}


module "sous-chefs-label_validator" {
  source             = "./modules/label_validator"
  kube_config        = local.kube_config
  namespace          = kubernetes_namespace.sous-chefs-frontend.metadata[0].name
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


module "sous-chefs-cookbook-release-validator" {
  source             = "./modules/cookbook_release_validator"
  kube_config        = local.kube_config
  namespace          = kubernetes_namespace.sous-chefs-frontend.metadata[0].name
  app_version        = local.app_version.cookbook_release_validator
  github_secret_name = kubernetes_secret.webhook-github-sous-chef-frontend.metadata[0].name
  hostname           = local.sous_chefs_hostnames.cookbook_release_validator
}

resource "cloudflare_record" "cookbook-release-validator-sous-chefs-frontend" {
  zone_id = local.cloudflare_dns_zone_id
  name    = local.sous_chefs_hostnames.cookbook_release_validator
  value   = local.kubernetes_public_ip
  type    = "A"
  ttl     = 1
}

module "sous-chefs-deployment-status-slack-notifier" {
  source             = "./modules/deployment_status_slack_notifier"
  kube_config        = local.kube_config
  namespace          = kubernetes_namespace.sous-chefs-frontend.metadata[0].name
  app_version        = local.app_version.deployment_status_slack_notifier
  github_secret_name = kubernetes_secret.webhook-github-sous-chef-frontend.metadata[0].name
  hostname           = local.sous_chefs_hostnames.deployment_status_slack_notifier
  success_webhooks   = var.sous_chefs_slack_notifier.success_webhooks
  failure_webhooks   = var.sous_chefs_slack_notifier.failure_webhooks
  error_webhooks     = var.sous_chefs_slack_notifier.failure_webhooks
}


resource "cloudflare_record" "deployment-status-slack-notifier-sous-chefs-frontend" {
  zone_id = local.cloudflare_dns_zone_id
  name    = local.sous_chefs_hostnames.deployment_status_slack_notifier
  value   = local.kubernetes_public_ip
  type    = "A"
  ttl     = 1
}

module "sous-chefs-cookbook_release_creator" {
  source             = "./modules/cookbook_release_creator"
  kube_config        = local.kube_config
  namespace          = kubernetes_namespace.sous-chefs-frontend.metadata[0].name
  app_version        = local.app_version.cookbook_release_creator
  github_secret_name = kubernetes_secret.webhook-github-sous-chef-frontend.metadata[0].name
  hostname           = local.sous_chefs_hostnames.cookbook_release_creator
}


resource "cloudflare_record" "cookbook-release-creator-sous-chefs-frontend" {
  zone_id = local.cloudflare_dns_zone_id
  name    = local.sous_chefs_hostnames.cookbook_release_creator
  value   = local.kubernetes_public_ip
  type    = "A"
  ttl     = 1
}

module "sous-chefs-cookbook_supermarket_uploader" {
  source                  = "./modules/cookbook_supermarket_uploader"
  kube_config             = local.kube_config
  namespace               = kubernetes_namespace.sous-chefs-frontend.metadata[0].name
  app_version             = local.app_version.cookbook_supermarket_uploader
  github_secret_name      = kubernetes_secret.webhook-github-sous-chef-frontend.metadata[0].name
  supermarket_secret_name = kubernetes_secret.webhook-supermarket-sous-chefs-frontend.metadata[0].name
  hostname                = local.sous_chefs_hostnames.cookbook_supermarket_uploader
}


resource "cloudflare_record" "cookbook-supermarket-uploader-sous-chefs-frontend" {
  zone_id = local.cloudflare_dns_zone_id
  name    = local.sous_chefs_hostnames.cookbook_supermarket_uploader
  value   = local.kubernetes_public_ip
  type    = "A"
  ttl     = 1
}


module "sous-chefs-changelog-reset" {
  source             = "./modules/changelog_reset"
  kube_config        = local.kube_config
  namespace          = kubernetes_namespace.sous-chefs-frontend.metadata[0].name
  app_version        = local.app_version.changelog_reset
  github_secret_name = kubernetes_secret.webhook-github-sous-chef-frontend.metadata[0].name
  hostname           = local.sous_chefs_hostnames.changelog_reset
}

resource "cloudflare_record" "changelog-reset-sous-chefs-frontend" {
  zone_id = local.cloudflare_dns_zone_id
  name    = local.sous_chefs_hostnames.changelog_reset
  value   = local.kubernetes_public_ip
  type    = "A"
  ttl     = 1
}

module "sous-chefs-changelog-validator" {
  source             = "./modules/changelog_validator"
  kube_config        = local.kube_config
  namespace          = kubernetes_namespace.sous-chefs-frontend.metadata[0].name
  app_version        = local.app_version.changelog_validator
  github_secret_name = kubernetes_secret.webhook-github-sous-chef-frontend.metadata[0].name
  hostname           = local.sous_chefs_hostnames.changelog_validator
}

resource "cloudflare_record" "changelog-validator-sous-chefs-frontend" {
  zone_id = local.cloudflare_dns_zone_id
  name    = local.sous_chefs_hostnames.changelog_validator
  value   = local.kubernetes_public_ip
  type    = "A"
  ttl     = 1
}
