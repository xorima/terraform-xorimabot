# use var for spaces instead of just env var
# as we need to use it when doing the
# chart museum deployment
variable "environment" {
  type    = string
  default = "production"
}

variable "cloudflare_config" {
  type = object({
    email       = string
    secret_name = string
  })
}

variable "cloudflare_api_token" {
  type = string
}

locals {
  cloudflare_config = {
    email       = var.cloudflare_config.email
    secret_name = var.cloudflare_config.secret_name
    api_token   = var.cloudflare_api_token
  }
}

variable "domain_config" {
  type = object({
    domain = string
    system = string
  })
}

locals {
  domain_config = {
    domain      = var.domain_config.domain
    system      = var.domain_config.system
    env         = var.environment
    base_domain = "${var.environment}.${var.domain_config.system}.${var.domain_config.domain}"
  }
}

variable "github_user_config" {
  type = object({
    name     = string
    email    = string
    username = string
  })
}

variable "github_user_token" {
  type = string
}

variable "github_admin_sous_chefs_config" {
  type = object({
    name     = string
    email    = string
    username = string
  })
}

variable "github_admin_sous_chefs_token" {
  type = string
}

variable "github_hmac_secret_sous_chefs" {
  type = string
}
variable "github_hmac_secret_actions_hub" {
  type = string
}
variable "github_hmac_secret_xorima" {
  type = string
}

variable "app_hostname_prefix" {
  type = object({
    label_validator     = string
    json_version_bumper = string
  })
}

locals {
  app_version = jsondecode(file("${path.module}/app_versions.json"))
}
