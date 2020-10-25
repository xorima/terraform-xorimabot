variable "kube_config" {
  type = object({
    host                   = string
    token                  = string
    cluster_ca_certificate = string
  })
}

variable "namespace" {
  description = "Which namespace to deploy into, must be pre-created"
}

variable "app_version" {
  description = "The version of label manager to run"
}

variable "github_secret_name" {
  description = "The name of the secret which contains the github_token and hmac_secret"
}

variable "hostname" {
  description = "Hostname for this application"
}
