variable "name" {
  type = string
}

variable "region" {
  type = string
}

variable "private_network_id" {
  type = string
}

variable "update_policy" {
  type = string
}

variable "k8s_version" {
  type    = string
  default = "1.25"
}

