resource "openstack_compute_instance_v2" "vm" {
  name            = var.name
  image_name      = var.image_name
  flavor_name     = var.flavor_name
  key_pair        = var.key_pair
  region          = var.region
  security_groups = ["default"]
  user_data       = var.user_data
  power_state     = var.status == "offline" ? "shutoff" : var.status

  network {
    name = "Ext-Net"
  }
  network {
    name = var.network
  }

  metadata = {
    "ovh-monthly-instance" = monthly_billed ? 1 : 0
  }

  lifecycle {
    ignore_changes = [
      user_data,
      image_name
    ]
  }
}

locals {
  additional_disks_map = {
    for disk in var.additional_disks : disk.id => disk
  }
}

resource "openstack_blockstorage_volume_v3" "volume" {
  for_each    = local.additional_disks_map
  region      = var.region
  size        = each.value.size
  volume_type = each.value.disk_type
  multiattach = false
  description = "Created by Terraform"
}

resource "openstack_compute_volume_attach_v2" "volume_attach" {
  for_each    = local.additional_disks_map
  volume_id   = openstack_blockstorage_volume_v3.volume[each.key].id
  instance_id = openstack_compute_instance_v2.vm.id
  multiattach = false
}

data "openstack_compute_flavor_v2" "flavor" {
  name   = var.flavor_name
  region = var.region
}

resource "netbox_virtual_machine" "vm" {
  cluster_id = var.netbox_cluster_id
  role_id    = var.netbox_role_id
  name       = var.name
  status     = var.status
  tags       = var.ansible_roles
  tenant_id  = var.netbox_tenant_id
  site_id    = var.netbox_site_id

  vcpus        = data.openstack_compute_flavor_v2.flavor.vcpus
  memory_mb    = data.openstack_compute_flavor_v2.flavor.ram
  disk_size_gb = data.openstack_compute_flavor_v2.flavor.disk
}

locals {
  network_map = {
    for network in openstack_compute_instance_v2.vm.network : network.name => network
  }
}

resource "netbox_interface" "interface" {
  virtual_machine_id = netbox_virtual_machine.vm.id
  for_each           = local.network_map
  enabled            = true
  name               = each.value.name
  mac_address        = upper(each.value.mac)
  mode               = "access"
  untagged_vlan      = contains(keys(var.netbox_vlans), each.value.name) ? var.netbox_vlans[each.value.name] : null
}

resource "netbox_ip_address" "ip" {
  interface_id = netbox_interface.interface[each.key].id
  for_each     = local.network_map
  ip_address = format("%s/%d",
    each.value.fixed_ip_v4,
    contains(keys(var.private_networks), each.value.name) ? var.private_networks[each.value.name].cidr : 32,
  )
  status     = "active"
  tenant_id  = var.netbox_tenant_id
  depends_on = [netbox_interface.interface]
}

resource "netbox_primary_ip" "primary_ip" {
  virtual_machine_id = netbox_virtual_machine.vm.id
  ip_address_id      = netbox_ip_address.ip["Ext-Net"].id
}

resource "netbox_service" "ssh" {
  virtual_machine_id = netbox_virtual_machine.vm.id
  name               = "ssh"
  ports              = [31337]
  protocol           = "tcp"
}


resource "kubernetes_endpoints_v1" "k8s_endpoints" {
  // only create resource if server has an interface in the back network
  count = contains(keys(local.network_map), "back") ? 1 : 0

  metadata {
    name      = var.name
    namespace = "node-monitoring"
    labels = {
      app = var.name
    }
  }

  subset {
    address {
      ip = local.network_map["back"].fixed_ip_v4
    }

    port {
      name     = "metrics"
      port     = 9100
      protocol = "TCP"
    }
  }
}

resource "kubernetes_service_v1" "k8s_service" {
  // only create resource if server has an interface in the back network
  count = contains(keys(local.network_map), "back") ? 1 : 0

  metadata {
    name      = var.name
    namespace = "node-monitoring"
    labels = {
      app = var.name
    }
  }

  spec {
    type          = "ExternalName"
    external_name = local.network_map["back"].fixed_ip_v4
    port {
      name        = "metrics"
      port        = 9100
      protocol    = "TCP"
      target_port = 9100
    }
  }
}

resource "kubernetes_manifest" "service_monitor" {
  // only create resource if server has an interface in the back network
  count = contains(keys(local.network_map), "back") ? 1 : 0

  manifest = {
    apiVersion = "monitoring.coreos.com/v1"
    kind       = "ServiceMonitor"
    metadata = {
      name      = var.name
      namespace = "node-monitoring"
      labels = {
        app = var.name
      }
    }
    spec = {
      //jobLabel = "app"
      selector = {
        matchLabels = {
          app = var.name
        }
      }
      endpoints = [
        {
          port        = "metrics"
          interval    = "15s"
          honorLabels = true
        }
      ]
    }
  }
}
