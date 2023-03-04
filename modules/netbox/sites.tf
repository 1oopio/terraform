locals {
  sites_map = {
    for i in var.sites : i => i
  }
}

resource "netbox_site" "site" {
  for_each  = local.sites_map
  name      = each.key
  slug      = each.key
  tenant_id = netbox_tenant.oneoop.id
}

