module "constants" {
  source = "../constants"
}

resource "openstack_compute_keypair_v2" "ssh_key" {
  name       = var.name
  region     = var.region
  public_key = file(var.path)
}
