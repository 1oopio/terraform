data "template_file" "setup" {
  template = <<SETUP
#!/bin/bash

FALLBACK_USER=ahsoka
SSH_PORT=31337

# create the new fallback user
useradd -m \
    -d /home/$FALLBACK_USER \
    -G sudo \
    -u 1001 \
    -s /bin/bash \
    -p '$6$/MDc6GNT67he48y9$6k9YQvZ1Xp68icb375VTOaJaH9.Hk9RlwbI9CANKm7qzgM3q9IWFXe4b.EWoWRFJ6Pi.6UcBsZacSRU3Qtc.V1' \
    $FALLBACK_USER

# deploy the fallback ssh key
mkdir /home/$FALLBACK_USER/.ssh
chown $FALLBACK_USER:$FALLBACK_USER /home/$FALLBACK_USER/.ssh
echo "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAO9HrahWftwj9UCML7L8eUJPiWQsPy1SaE4K/yC6ben ahsoka" >> /home/$FALLBACK_USER/.ssh/authorized_keys
chown $FALLBACK_USER:$FALLBACK_USER /home/$FALLBACK_USER/.ssh/authorized_keys

# remap ssh port to 31337
sed -i "s/#Port 22/Port $SSH_PORT/g" /etc/ssh/sshd_config
systemctl restart sshd

# remove the user ubuntu
deluser --remove-home ubuntu
SETUP
}

data "template_file" "userdata" {
  template = <<CLOUDCONFIG
#cloud-config
write_files:
  - path: /tmp/setup/run.sh
    permissions: '0755'
    content: |
      ${indent(6, data.template_file.setup.rendered)}
runcmd:
   - /tmp/setup/run.sh
CLOUDCONFIG
}


resource "openstack_compute_instance_v2" "vm" {
  name            = var.name
  image_name      = var.image_name
  flavor_name     = var.flavor_name
  key_pair        = var.key_pair
  region          = var.region
  security_groups = ["default"]
  user_data       = data.template_file.userdata.rendered

  network {
    name = "Ext-Net"
  }
  network {
    name = var.network
  }
}

data "openstack_compute_flavor_v2" "flavor" {
  name = var.flavor_name
}

resource "netbox_virtual_machine" "vm" {
  cluster_id = var.netbox_cluster_id
  role_id    = var.netbox_role_id
  name       = var.name
  status     = "active"
  tags       = var.ansible_roles
  tenant_id  = var.netbox_tenant_id
  site_id    = var.netbox_site_id

  vcpus        = data.openstack_compute_flavor_v2.flavor.vcpus
  memory_mb    = data.openstack_compute_flavor_v2.flavor.ram
  disk_size_gb = data.openstack_compute_flavor_v2.flavor.disk

  depends_on = [openstack_compute_instance_v2.vm]
}

locals {
  network_map = {
    for network in openstack_compute_instance_v2.vm.network : network.name => network
  }
}

resource "netbox_interface" "interface" {
  virtual_machine_id = netbox_virtual_machine.vm.id
  for_each           = local.network_map
  enabled            = true
  name               = each.value.name
  mac_address        = upper(each.value.mac)
  mode               = "access"
  untagged_vlan      = contains(keys(var.netbox_vlans), each.value.name) ? var.netbox_vlans[each.value.name] : null

  depends_on = [netbox_virtual_machine.vm]
}

resource "netbox_ip_address" "ip" {
  interface_id = netbox_interface.interface[each.key].id
  for_each     = local.network_map
  ip_address = format("%s/%d",
    each.value.fixed_ip_v4,
    contains(keys(var.private_networks), each.value.name) ? var.private_networks[each.value.name].cidr : 32,
  )
  status     = "active"
  tenant_id  = var.netbox_tenant_id
  depends_on = [netbox_interface.interface]
}

resource "netbox_primary_ip" "primary_ip" {
  virtual_machine_id = netbox_virtual_machine.vm.id
  ip_address_id      = netbox_ip_address.ip["Ext-Net"].id

  depends_on = [netbox_ip_address.ip]
}

resource "netbox_service" "ssh" {
  virtual_machine_id = netbox_virtual_machine.vm.id
  name               = "ssh"
  ports              = [31337]
  protocol           = "tcp"
}
