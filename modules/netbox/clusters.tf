resource "netbox_cluster_type" "openstack" {
  name = "Openstack"
}

resource "netbox_cluster" "cluster" {
  for_each        = local.sites_map
  name            = each.key
  cluster_type_id = netbox_cluster_type.openstack.id
  tags            = []
  tenant_id       = netbox_tenant.oneoop.id
  site_id         = netbox_site.site[each.key].id
}
