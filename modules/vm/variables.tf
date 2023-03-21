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

variable "netbox_cluster_id" {
  type = number
}

variable "netbox_role_id" {
  type = number
}

variable "netbox_site_id" {
  type = number
}

variable "netbox_tenant_id" {
  type = number
}

variable "ansible_roles" {
  type = list(string)
}

variable "netbox_vlans" {
  type = map(number)
}

variable "private_networks" {
  type = map(object({
    vlan_id = number
    subnet  = string
    cidr    = number
  }))
}

variable "user_data" {
  type = string
}

variable "status" {
  type = string
  validation {
    condition     = can(regex("^(active|offline)$", var.status))
    error_message = "status must be active or offline"
  }
  description = "values: active, offline"
}

variable "additional_disks" {
  type = list(object({
    id        = number
    size      = number
    disk_type = string
  }))
  default = []
  validation {
    condition = alltrue([
      for disk in var.additional_disks : contains(["classic", "high-speed", "high-speed-gen2"], disk.disk_type)
    ])
    error_message = "additional disk type must be classic, high-speed or high-speed-gen2"
  }
}
