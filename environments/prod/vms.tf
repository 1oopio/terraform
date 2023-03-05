locals {
  vms = [
    {
      name          = "vm1"
      status        = "active"
      region        = "SBG5"
      network       = "back"
      flavor_name   = "d2-2"
      image_name    = "Ubuntu 22.04"
      key_pair      = "ahsoka"
      ansible_roles = ["base"]
      user_data     = data.template_file.userdata.rendered
    }
  ]
}

locals {
  vm_map = {
    for vm in local.vms : vm.name => vm
  }

  netbox_vlans = {
    for i in module.private_networks : i.netbox_vlan_name => i.netbox_vlan_id
  }
}

// create all vms
module "vms" {
  for_each          = local.vm_map
  source            = "../../modules/vm"
  status            = each.value.status
  name              = each.value.name
  region            = each.value.region
  network           = each.value.network
  flavor_name       = each.value.flavor_name
  image_name        = each.value.image_name
  key_pair          = each.value.key_pair
  netbox_cluster_id = module.netbox.clusters[each.value.region]
  netbox_role_id    = module.netbox.device_roles["Linux Server"]
  netbox_tenant_id  = module.netbox.tenant_id
  ansible_roles     = each.value.ansible_roles
  netbox_vlans      = local.netbox_vlans
  private_networks  = local.private_networks
  netbox_site_id    = module.netbox.sites[each.value.region]
  user_data         = data.template_file.userdata.rendered

  depends_on = [
    module.ssh_keys,
  ]
}

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
