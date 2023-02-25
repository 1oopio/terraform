locals {
  regions = ["SBG5", "BHS5"]
  ssh_keys = [
    {
      name = "ahsoka"
      path = abspath("static/ahsoka.pub")
    }
  ]
}

locals {
  // map ssh keys and regions
  ssh_keys_regions = merge([
    for ssh_key in local.ssh_keys : {
      for region in local.regions : "${ssh_key.name}-${region}" => {
        name   = ssh_key.name
        region = region
        path   = ssh_key.path
      }
    }
  ]...)
}

module "ssh_keys" {
  source   = "../../modules/ssh_key"
  for_each = local.ssh_keys_regions
  name     = each.value.name
  region   = each.value.region
  path     = each.value.path
}
