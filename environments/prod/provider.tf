terraform {
  cloud {
    organization = "1oop"

    workspaces {
      name = "1oop"
    }
  }

  required_providers {
    ovh = {
      source  = "ovh/ovh"
      version = "~> 0.24.0"
    }

    openstack = {
      source  = "terraform-provider-openstack/openstack"
      version = "~> 1.48.0"
    }
  }
}

provider "ovh" {
  alias = "ovh"
}

provider "openstack" {
  auth_url    = "https://auth.cloud.ovh.net/v3/"
  domain_name = "default"
  alias       = "ovh"
}
