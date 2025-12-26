# https://github.com/xunholy/k8s-gitops/blob/9edd86f0ab8e15293daaf9121753da038daf1e6b/hack/cf-terraforming.sh#L41

terraform {
  required_version = ">= 1.2.0, < 2.0.0" # Example: Terraform version between 1.2.0 and 2.0.0 (exclusive)

  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      # NOTE: v5 doesn't work
      #  not true anymore
    }
  }
}

provider "cloudflare" {
  # token pulled from $CLOUDFLARE_API_TOKEN
}

locals {
  managed_zone_names = {
    "upidapi.com" = "upidapi.com"
    "upidapi.dev" = "upidapi.dev"
  }
}

data "cloudflare_zones" "zones" {
  for_each = local.managed_zone_names
  name = each.key
}

locals {
  zone_data = {
    for k,v in data.cloudflare_zones.zones: k => v.result[0]
  }
}

# Override zone settings to set SSL/TLS to Full (Strict)
resource "cloudflare_zone_setting" "strict_ssl_setting" {
  for_each = local.zone_data

  zone_id = each.value.id
  setting_id = "ssl"
  id         = "ssl"
  value      = "strict"
}

resource "cloudflare_dns_record" "root_a_record" {
  for_each = local.zone_data

  zone_id = each.value.id
  name    = "@"
  type    = "A"
  content = "192.0.2.1"
  ttl     = 1
  proxied = true

  # Ignore changes to the 'value' attribute after the resource is created.
  # This allows an external DDNS client to update the IP without Terraform
  # trying to reset it on every apply.
  lifecycle { ignore_changes = [content] }
}

# allow for ssh on "ssh.upidapi.dev"
resource "cloudflare_dns_record" "ssh_upidapi_dev_a_record" {
  zone_id = local.zone_data["upidapi.dev"].id
  name    = "ssh"
  type    = "A"
  content = "192.0.2.1"
  ttl     = 1
  proxied = false
  lifecycle { ignore_changes = [content] }
}

resource "cloudflare_dns_record" "mc_upidapi_dev_a_record" {
  zone_id = local.zone_data["upidapi.dev"].id
  name    = "mc"
  type    = "A"
  content = "192.0.2.1"
  ttl     = 1
  proxied = false
  lifecycle { ignore_changes = [content] }
}

resource "cloudflare_dns_record" "vpn_upidapi_dev_a_record" {
  zone_id = local.zone_data["upidapi.dev"].id
  name    = "vpn"
  type    = "A"
  content = "192.0.2.1"
  ttl     = 1
  proxied = false
  lifecycle { ignore_changes = [content] }
}


resource "cloudflare_dns_record" "wild_upidapi_dev_a_record" {
  zone_id = local.zone_data["upidapi.dev"].id
  name    = "*"
  type    = "A"
  content = "192.0.2.1"
  ttl     = 1
  proxied = true 
  lifecycle { ignore_changes = [content] }
}
