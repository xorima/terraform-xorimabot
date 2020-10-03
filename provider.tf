
provider "digitalocean" {
  version           = "~> 1.0"
  spaces_access_id  = var.spaces_access_id
  spaces_secret_key = var.spaces_secret_key
}

provider "kubernetes" {
  version                = "~> 1.0"
  load_config_file       = false
  host                   = local.kube_config.host
  token                  = local.kube_config.token
  cluster_ca_certificate = local.kube_config.cluster_ca_certificate
}

provider "helm" {
  version = "~> 1.0"
  kubernetes {
    load_config_file       = false
    host                   = local.kube_config.host
    token                  = local.kube_config.token
    cluster_ca_certificate = local.kube_config.cluster_ca_certificate
  }
}

provider "cloudflare" {
  version   = "~> 2.0"
  api_token = var.cloudflare_api_token
}
