data "cloudflare_zones" "zone" {
  filter {
    name   = local.domain_config.domain
    status = "active"
  }
}
locals {
  cloudflare_dns_zone_id   = data.cloudflare_zones.zone.zones.id
  cloudflare_dns_zone_name = data.cloudflare_zones.zone.zones.name
}

data "kubernetes_service" "nginx-ingress" {
  metadata {
    name      = "nginx-ingress-nginx-ingress"
    namespace = "ingress"
  }
  depends_on = [
    module.kubernetes_core_cluster_services,
  ]
}

locals {
  kubernetes_public_ip = data.kubernetes_service.nginx-ingress.load_balancer_ingress.0.ip
}