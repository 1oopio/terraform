locals {
  // all private networks with their associated vlan
  private_networks = {
    back = {
      vlan_id = 100
      subnet  = "10.200.0.0"
      cidr    = 16
    }
  }
}

// creates all private networks
module "private_networks" {
  source           = "../../modules/private_network"
  for_each         = local.private_networks
  name             = each.key
  vlan_id          = each.value.vlan_id
  netbox_tenant_id = module.netbox.tenant_id
  subnet           = each.value.subnet
  cidr             = each.value.cidr
}
