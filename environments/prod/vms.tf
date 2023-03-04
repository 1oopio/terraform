locals {
  vms = [
    {
      name          = "vm1"
      region        = "SBG5"
      network       = "back"
      flavor_name   = "d2-2"
      image_name    = "Ubuntu 22.04"
      key_pair      = "ahsoka"
      ansible_roles = ["base"]
    }
  ]
}

locals {
  vm_map = {
    for vm in local.vms : vm.name => vm
  }

  netbox_vlans = {
    for i in module.private_networks : i.netbox_vlan_name => i.netbox_vlan_id
  }
}

// create all vms
module "vm" {
  for_each          = local.vm_map
  source            = "../../modules/vm"
  name              = each.value.name
  region            = each.value.region
  network           = each.value.network
  flavor_name       = each.value.flavor_name
  image_name        = each.value.image_name
  key_pair          = each.value.key_pair
  netbox_cluster_id = module.netbox.clusters[each.value.region]
  netbox_role_id    = module.netbox.device_roles["Linux Server"]
  netbox_tenant_id  = module.netbox.tenant_id
  ansible_roles     = each.value.ansible_roles
  netbox_vlans      = local.netbox_vlans
  private_networks  = local.private_networks
  netbox_site_id    = module.netbox.sites[each.value.region]

  depends_on = [
    module.private_networks,
    module.subnets,
    module.ssh_keys,
    module.netbox
  ]
}
