terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "2.95.0"
    }
  }
}
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "workshopgroup" {
  name     = "workshop-${var.user_identifier}"
  location = "West Europe"
}

resource "tls_private_key" "workshop-key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}
