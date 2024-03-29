output "tenant_id" {
  value = netbox_tenant.oneoop.id
}

output "clusters" {
  value = {
    for i in netbox_cluster.cluster : i.name => i.id
  }
}

output "sites" {
  value = {
    for i in netbox_site.site : i.name => i.id
  }
}

output "device_roles" {
  value = {
    for i in netbox_device_role.role : i.name => i.id
  }
}
