terraform {
  required_providers {
    ovh = {
      source  = "ovh/ovh"
      version = "~> 0.24.0"
    }

    openstack = {
      source  = "terraform-provider-openstack/openstack"
      version = "~> 1.50.0"
    }

    netbox = {
      source  = "e-breuninger/netbox"
      version = "~> 3.1.0"
    }
  }
}
