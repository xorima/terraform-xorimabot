data "cloudflare_zones" "zone" {
  filter {
    name   = var.cloudflare_dns_zone_filer
    status = "active"
  }
}
