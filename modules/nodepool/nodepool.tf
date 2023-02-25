module "constants" {
  source = "../constants"
}

resource "ovh_cloud_project_kube_nodepool" "nodepool" {
  service_name   = module.constants.service_name
  kube_id        = var.kube_id
  name           = var.name
  flavor_name    = var.flavor_name
  max_nodes      = var.max_nodes
  min_nodes      = var.min_nodes
  monthly_billed = var.monthly_billed
  autoscale      = var.autoscale
  template {
    metadata {
      labels = var.labels
    }
    spec {
      taints = var.taints
    }
  }
}
