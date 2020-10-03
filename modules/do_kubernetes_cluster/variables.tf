
variable "environment" {
  type    = string
  default = "production"
}

variable "region" {
  type    = string
  default = "fra1"
}

variable "default_node_size" {
  type    = string
  default = "s-1vcpu-2gb"
}

variable "min_nodes" {
  type    = number
  default = 1
}

variable "max_nodes" {
  type    = number
  default = 2
}