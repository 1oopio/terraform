resource "netbox_tenant" "oneoop" {
  name = "1oop"
}

resource "netbox_device_role" "linuxserver" {
  name      = "Linux Server"
  slug      = "linux_server"
  color_hex = "ff5722"
}

