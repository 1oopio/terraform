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
