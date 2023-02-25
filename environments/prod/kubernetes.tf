locals {
  // all kubernetes clusters with their nodepools
  clusters = [
    //
    // production
    //
    {
      name          = "prd-sbg5-1"
      region        = "SBG5"
      network       = "back"
      update_policy = "MINIMAL_DOWNTIME"
      nodepools = [
        {
          name           = "np-d2-4-f1"
          flavor_name    = "d2-4"
          max_nodes      = 1
          min_nodes      = 1
          monthly_billed = true
          autoscale      = false
          labels = {
            "nodepooltype" = "fixed"
          }
          taints = []
        },
        /* {
          name           = "np-b2-7-a1"
          flavor_name    = "b2-7"
          max_nodes      = 2
          min_nodes      = 0
          monthly_billed = false
          autoscale      = true
          labels = {
            "nodepooltype" = "autoscaled"
          }
          taints = []
        } */
      ]
    },
    //
    // development cluster
    //
    /* {
      name          = "dev-sbg5-1"
      region        = "SBG5"
      network       = "back"
      update_policy = "MINIMAL_DOWNTIME"
      nodepools = [
        {
          name           = "np-d2-4-f1"
          flavor_name    = "d2-4"
          max_nodes      = 1
          min_nodes      = 1
          monthly_billed = true
          autoscale      = false
          labels = {
            "nodepooltype" = "fixed"
          }
          taints = []
        },
      ]
    }, */
  ]
}

locals {
  // clusters kube_id by cluster name
  clusters_id = {
    for k, v in module.clusters : k => v.id
  }

  // creates a list with all nodepools from all clusters
  cluster_nodepools = merge([
    for k, v in { for _, v in local.clusters : v.name => v } : {
      for nodepool in v.nodepools : "${k}-${nodepool.name}" => {
        name           = nodepool.name
        kube_id        = local.clusters_id[k]
        flavor_name    = nodepool.flavor_name
        max_nodes      = nodepool.max_nodes
        min_nodes      = nodepool.min_nodes
        monthly_billed = nodepool.monthly_billed
        autoscale      = nodepool.autoscale
        labels         = nodepool.labels
        taints         = nodepool.taints
      }
    }
  ]...)
}

// creates all kubernetes clusters
module "clusters" {
  source             = "../../modules/cluster"
  for_each           = { for _, v in local.clusters : v.name => v }
  name               = each.value.name
  region             = each.value.region
  update_policy      = each.value.update_policy
  private_network_id = local.private_networks_regions_attributes[each.value.network][each.value.region].openstackid

  depends_on = [
    module.private_networks,
    module.subnets
  ]
}

// creates all kubernetes nodepools
module "nodepools" {
  source         = "../../modules/nodepool"
  for_each       = local.cluster_nodepools
  name           = each.value.name
  kube_id        = each.value.kube_id
  flavor_name    = each.value.flavor_name
  max_nodes      = each.value.max_nodes
  min_nodes      = each.value.min_nodes
  monthly_billed = each.value.monthly_billed
  autoscale      = each.value.autoscale
  labels         = each.value.labels
  taints         = each.value.taints

  depends_on = [module.clusters]
}
