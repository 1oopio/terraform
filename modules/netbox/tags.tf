locals {
  ansible_roles_map = {
    for i in var.ansible_roles : i => i
  }
}

resource "random_id" "hex_color_tag" {
  byte_length = 3
  count       = length(local.ansible_roles_map)
}

locals {
  tag_colors = {
    for i, v in var.ansible_roles : v => random_id.hex_color_tag[i].hex
  }
}

resource "netbox_tag" "ansible_role" {
  for_each  = local.ansible_roles_map
  name      = each.key
  slug      = format("role_%s", each.key)
  color_hex = local.tag_colors[each.key]
}
