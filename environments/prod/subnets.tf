locals {
  subnets = {
    // the back subnet
    // all backend services are running here
    back = [
      {
        region = "SBG5",
        start  = "10.200.116.94"
        end    = "10.200.139.161"
        dhcp   = true
      },
      {
        region = "BHS5",
        start  = "10.200.0.2"
        end    = "10.200.23.70"
        dhcp   = true
      },
      {
        region = "SGP1",
        start  = "10.200.162.233"
        end    = "10.200.186.44"
        dhcp   = true
      }
    ],
  }
}

locals {
  // private networks id by private network name
  private_networks_id = {
    for k, v in module.private_networks : k => v.id
  }

  // private networks region attributes by private network name
  // the region attributes are a map of region name to region attributes
  private_networks_regions_attributes = {
    for k, v in module.private_networks : k => {
      for region in v.regions_attributes : region.region => region
    }
  }

  // creates a list with all subnets from all regions
  network_subnets = merge([
    for k, v in local.subnets : {
      for subnet in v : "${k}-${subnet.region}" => {
        name    = k
        region  = subnet.region
        start   = subnet.start
        end     = subnet.end
        network = format("%s/%d", local.private_networks[k].subnet, local.private_networks[k].cidr)
        dhcp    = subnet.dhcp
        cidr    = local.private_networks[k].cidr
        //routes  = subnet.routes
      }
    }
  ]...)
}

// creates all subnets
module "subnets" {
  source           = "../../modules/subnet"
  for_each         = local.network_subnets
  network_id       = local.private_networks_id[each.value.name]
  region           = each.value.region
  start            = each.value.start
  end              = each.value.end
  network          = each.value.network
  dhcp             = each.value.dhcp
  netbox_tenant_id = module.netbox.tenant_id
  cidr             = each.value.cidr
}
