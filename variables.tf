# use var for spaces instead of just env var
# as we need to use it when doing the
# chart museum deployment
variable "spaces_access_id" {
  type = string
}

variable "spaces_secret_key" {
  type = string
}

variable "environment" {
  type    = string
  default = "production"
}

variable "cloudflare_dns_zone_filer" {
  type = string
}

variable "cloudflare_api_token" {
  type = string
}
variable "cloudflare_email" {
  type = string
}
variable "cloudflare_api_secret_name" {
  type = string
}

locals {
  cloudflare_config = {
    email       = var.cloudflare_email
    secret_name = var.cloudflare_api_secret_name
    api_token   = var.cloudflare_api_token
  }
}

variable "github_xorimabot_token" {
  type = string
}

variable "github_xorimabot_name" {
  type = string
}
variable "github_xorimabot_email" {
  type = string
}
variable "github_xorimabot_username" {
  type = string
}

locals {
  # kubernetes_public_ip     = module.kubernetes_core_cluster_services.nginx-public-ip
  cloudflare_dns_zone_id   = data.cloudflare_zones.zone.zones.0.id
  cloudflare_dns_zone_name = data.cloudflare_zones.zone.zones.0.name
}

locals {
  app_version = jsondecode(file("${path.module}/app_versions.json"))
}
