variable "network_id" {
  type = string
}

variable "region" {
  type = string
}

variable "start" {
  type = string
}

variable "end" {
  type = string
}

variable "network" {
  type = string
}

variable "dhcp" {
  type    = bool
  default = false
}

variable "no_gateway" {
  type    = bool
  default = true
}
