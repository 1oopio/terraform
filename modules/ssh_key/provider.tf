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
  }
}
