module "constants" {
  source = "../constants"
}


resource "ovh_cloud_project_network_private" "network" {
  service_name = module.constants.service_name
  name         = var.name
  vlan_id      = var.vlan_id
  regions      = ["BHS5", "DE1", "GRA9", "GRA11", "SBG5", "SBG7", "SGP1", "SYD1", "UK1", "WAW1"]
}

resource "netbox_vlan" "vlan" {
  name      = var.name
  vid       = var.vlan_id
  tenant_id = var.netbox_tenant_id
}

resource "netbox_prefix" "prefix" {
  tenant_id = var.netbox_tenant_id
  vlan_id   = netbox_vlan.vlan.id
  prefix    = format("%s/%d", var.subnet, var.cidr)
  status    = "active"
}
