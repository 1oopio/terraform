output "id" {
  value = ovh_cloud_project_network_private.network.id
}

output "regions_attributes" {
  value = ovh_cloud_project_network_private.network.regions_attributes
}

output "netbox_vlan_id" {
  value = netbox_vlan.vlan.id
}

output "netbox_vlan_name" {
  value = netbox_vlan.vlan.name
}
