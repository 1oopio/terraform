variable "name" {
  type = string
}

variable "image_name" {
  type    = string
  default = "Ubuntu 22.04"
}

variable "flavor_name" {
  type = string
}

variable "key_pair" {
  type = string
}

variable "network" {
  type = string
}

variable "region" {
  type = string
}

/* variable "netbox_cluster_id" {
  type = number
}
 */
