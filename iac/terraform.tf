terraform {
  required_version = ">= 1.15.0"
  
  backend "azurerm" {
    use_azuread_auth = true
    use_oidc_auth = true
  }
  
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 4.77.0"
    }
    azapi = {
      source  = "azure/azapi"
      version = ">= 2.1.0"
    }
  }
}

provider "azurerm" {
  tenant_id       = var.TENANT_ID
  subscription_id = var.SUBSCRIPTION_ID
  client_id       = var.AZURE_CLIENT_ID
  client_secret   = var.AZURE_CLIENT_SECRET
  features {}
}

provider "azapi" {
  subscription_id = var.SUBSCRIPTION_ID
  tenant_id       = var.TENANT_ID
  client_id       = var.AZURE_CLIENT_ID
  client_secret   = var.AZURE_CLIENT_SECRET
}