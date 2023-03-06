variable "K8S_TERRAFORM_HOST" {
  type      = string
  sensitive = true
}

variable "K8S_TERRAFORM_CLIENT_CERTIFICATE" {
  type      = string
  sensitive = true
}

variable "K8S_TERRAFORM_CLIENT_KEY" {
  type      = string
  sensitive = true
}

variable "K8S_TERRAFORM_CLUSTER_CA_CERTIFICATE" {
  type      = string
  sensitive = true
}
