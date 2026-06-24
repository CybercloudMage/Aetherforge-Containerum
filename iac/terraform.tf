terraform {
  required_version = ">= 1.15.0"

  backend "azurerm" {
    use_azuread_auth = true
  }

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 4.78.0"
    }
  }
}

provider "azurerm" {
  features {}
}