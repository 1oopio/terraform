output "cpu" {
  value = data.openstack_compute_flavor_v2.flavor.vcpus
}

output "name" {
  value = var.name
}
