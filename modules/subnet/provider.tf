terraform {
  required_providers {
    ovh = {
      source  = "ovh/ovh"
      version = "~> 0.24.0"
    }

    netbox = {
      source  = "e-breuninger/netbox"
      version = "~> 3.1.0"
    }
  }
}
