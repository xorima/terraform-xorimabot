provider "kubernetes" {
  version                = "~> 1.0"
  load_config_file       = false
  host                   = var.kube_config.host
  token                  = var.kube_config.token
  cluster_ca_certificate = var.kube_config.cluster_ca_certificate
}

provider "helm" {
  version = "~> 1.0"
  kubernetes {
    load_config_file       = false
    host                   = var.kube_config.host
    token                  = var.kube_config.token
    cluster_ca_certificate = var.kube_config.cluster_ca_certificate
  }
}
