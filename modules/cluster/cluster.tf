module "constants" {
  source = "../constants"
}

resource "ovh_cloud_project_kube" "cluster" {
  service_name       = module.constants.service_name
  name               = var.name
  region             = var.region
  update_policy      = var.update_policy
  private_network_id = var.private_network_id
  version            = var.k8s_version
}
