output "kubeconfigs" {
  value = {
    for i in module.clusters : i.name => i.kubeconfig
  }
  sensitive = true
}
