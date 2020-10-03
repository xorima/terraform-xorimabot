variable "namespace_ingress" {
  default = "ingress"
}

variable "namespace_dashboard" {
  default = "kubernetes-dashboard"
}

variable "namespace_cert_manager" {
  default = "cert-manager"
}

variable "cloudflare_config" {
  type = object({
    email       = string
    secret_name = string
    api_token   = string
  })
}

variable "kube_config" {
  type = object({
    host                   = string
    token                  = string
    cluster_ca_certificate = string
  })
}
