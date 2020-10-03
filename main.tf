terraform {
  backend "remote" {
    hostname     = "app.terraform.io"
    organization = "xorima"
    workspaces {
      name = "terraform-xorimabot"
    }
  }
}

resource "digitalocean_project" "xorimabot" {
  name        = "Xorimabot-${var.environment}"
  description = "A project to hold all resources related to the running and monitoring of xorimabot"
  purpose     = "Service or API"
  environment = var.environment
}

module "xorimabot_cluster" {
  source = "./modules/do_kubernetes_cluster"
}

locals {
  kube_config = {
    host  = module.xorimabot_cluster.kubernetes_cluster.endpoint
    token = module.xorimabot_cluster.kubernetes_cluster.kube_config[0].token
    cluster_ca_certificate = base64decode(
      module.xorimabot_cluster.kubernetes_cluster.kube_config[0].cluster_ca_certificate
    )
  }
}

module "kubernetes_core_cluster_services" {
  source            = "./modules/core_cluster_services"
  cloudflare_config = local.cloudflare_config
  kube_config       = local.kube_config
}
