data "digitalocean_kubernetes_versions" "available_versions" {}

resource "digitalocean_kubernetes_cluster" "cluster" {
  name   = "xorimabot-${var.environment}"
  region = var.region
  # Grab the latest version slug from `doctl kubernetes options versions`
  # if this becomes painful to manage we can put it in the ignore_changes
  version = data.digitalocean_kubernetes_versions.available_versions.latest_version
  tags    = [var.environment, "xorimabot"]

  node_pool {
    name       = "default-pool"
    size       = var.default_node_size
    auto_scale = true
    min_nodes  = var.min_nodes
    max_nodes  = var.max_nodes
  }
}
