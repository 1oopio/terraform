module "constants" {
  source = "../constants"
}

resource "ovh_cloud_project_network_private_subnet" "subnet" {
  service_name = module.constants.service_name
  network_id   = var.network_id
  region       = var.region
  start        = var.start
  end          = var.end
  network      = var.network
  dhcp         = var.dhcp
  no_gateway   = var.no_gateway
}

resource "netbox_ip_range" "ip_range" {
  tenant_id     = var.netbox_tenant_id
  start_address = format("%s/%d", var.start, var.cidr)
  end_address   = format("%s/%d", var.end, var.cidr)
}
