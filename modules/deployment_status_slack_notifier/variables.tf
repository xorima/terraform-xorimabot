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
  description = "The name of the secret which contains the hmac_secret"
}

variable "success_webhooks" {
  description = "csv of webhooks for successes"
}

variable "failure_webhooks" {
  description = "csv of webhooks for failures"
}

variable "error_webhooks" {
  description = "csv of webhooks for errors"
}

variable "hostname" {
  description = "Hostname for this application"
}
