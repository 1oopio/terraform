terraform {
  required_providers {
    ovh = {
      source  = "ovh/ovh"
      version = "~> 0.24.0"
    }

    netbox = {
      source  = "e-breuninger/netbox"
      version = "~> 2.0.1"
    }
  }
}
