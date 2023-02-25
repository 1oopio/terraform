output "kubeconfig" {
  value     = ovh_cloud_project_kube.cluster.kubeconfig
  sensitive = true
}

output "id" {
  value = ovh_cloud_project_kube.cluster.id
}

output "name" {
  value = ovh_cloud_project_kube.cluster.name
}
