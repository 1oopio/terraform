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
      version = "~> 1.50.0"
    }

    netbox = {
      source  = "e-breuninger/netbox"
      version = "~> 3.1.0"
    }

    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.18.1"
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

provider "netbox" {
  server_url = "https://netbox.tarnished.ch"
}

provider "kubernetes" {
  host = var.K8S_TERRAFORM_HOST

  client_certificate     = base64decode(var.K8S_TERRAFORM_CLIENT_CERTIFICATE)
  client_key             = base64decode(var.K8S_TERRAFORM_CLIENT_KEY)
  cluster_ca_certificate = base64decode(var.K8S_TERRAFORM_CLUSTER_CA_CERTIFICATE)
}
