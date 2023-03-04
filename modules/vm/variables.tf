variable "name" {
  type = string
}

variable "image_name" {
  type    = string
  default = "Ubuntu 22.04"
}

variable "flavor_name" {
  type    = string
  default = "s1-2"
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
