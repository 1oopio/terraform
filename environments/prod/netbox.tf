locals {
  ansible_roles = [
    "base",
    "haproxy",
    "docker"
  ]
}

module "netbox" {
  source        = "../../modules/netbox"
  ansible_roles = local.ansible_roles
  sites         = local.regions
}
