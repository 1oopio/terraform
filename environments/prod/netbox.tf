locals {
  ansible_roles = [
    "base",
    "haproxy_stratum",
    "docker",
    "test"
  ]

  device_roles = [
    "Linux Server",
  ]
}

module "netbox" {
  source        = "../../modules/netbox"
  ansible_roles = local.ansible_roles
  sites         = local.regions
  device_roles  = local.device_roles
}
