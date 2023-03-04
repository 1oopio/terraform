locals {
  device_roles_map = {
    for i in var.device_roles : i => i
  }
}

resource "random_id" "hex_color_device_role" {
  byte_length = 3
  count       = length(local.device_roles_map)
}

locals {
  device_role_colors = {
    for i, v in var.device_roles : v => random_id.hex_color_device_role[i].hex
  }
}

resource "netbox_device_role" "role" {
  for_each  = local.device_roles_map
  name      = each.key
  slug      = lower(replace(each.key, " ", "_"))
  color_hex = local.device_role_colors[each.key]
  tags      = []
}

