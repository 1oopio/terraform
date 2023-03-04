locals {
  vms = [
    /* {
      name        = "vm1"
      region      = "SBG5"
      network     = "back"
      flavor_name = "d2-2"
      image_name  = "Ubuntu 22.04"
      key_pair    = "ahsoka"
    } */
  ]
}

locals {
  vm_map = {
    for vm in local.vms : vm.name => vm
  }
}

// create all vms
module "vm" {
  for_each    = local.vm_map
  source      = "../../modules/vm"
  name        = each.value.name
  region      = each.value.region
  network     = each.value.network
  flavor_name = each.value.flavor_name
  image_name  = each.value.image_name
  key_pair    = each.value.key_pair

  depends_on = [
    module.private_networks,
    module.subnets,
    module.ssh_keys,
  ]
}
