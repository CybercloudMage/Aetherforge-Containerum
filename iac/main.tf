# Gather the pre-provisioned resource group information
data "azurerm_resource_group" "root_rg" {
  name = var.RESOURCE_GROUP_NAME
}

# VNet that provides the backbone for the resources and services in this repo
module "backbone_vnet" {
  source  = "Azure/avm-res-network-virtualnetwork/azurerm"
  parent_id = data.azurerm_resource_group.root_rg.id
  version = "~> 0.8"

  name                = "${var.RESOURCE_GROUP_NAME}-vnet"
  location            = data.azurerm_resource_group.root_rg.location
  address_space       = ["10.0.0.0/22"]

  subnets = {
    azure_bastion = {
      name             = "AzureBastionSubnet"
      address_prefixes = ["10.0.0.0/26"]
    }
    azure_firewall = {
      name             = "AzureFirewallSubnet"
      address_prefixes = ["10.0.0.64/26"]
    }
    workstations = {
      name             = "workstations-subnet"
      address_prefixes = ["10.0.1.0/24"]
    }
    container_apps = {
      name             = "container-apps-subnet"
      address_prefixes = ["10.0.2.0/24"]
    }
  }
}

module "no_internet_route_table" {
  source  = "Azure/avm-res-network-routetable/azurerm"
  version = "~> 0.4"

  name                = "${var.RESOURCE_GROUP_NAME}-no-internet-rt"
  location            = data.azurerm_resource_group.root_rg.location
  resource_group_name = data.azurerm_resource_group.root_rg.name

  routes = {
    block_internet = {
      name           = "block-internet"
      address_prefix = "0.0.0.0/0"
      next_hop_type  = "None"
    }
  }
}

resource "azurerm_subnet_route_table_association" "azure_bastion" {
  subnet_id      = module.backbone_vnet.subnets["azure_bastion"].resource_id
  route_table_id = module.no_internet_route_table.resource_id
}

resource "azurerm_subnet_route_table_association" "azure_firewall" {
  subnet_id      = module.backbone_vnet.subnets["azure_firewall"].resource_id
  route_table_id = module.no_internet_route_table.resource_id
}

resource "azurerm_subnet_route_table_association" "workstations" {
  subnet_id      = module.backbone_vnet.subnets["workstations"].resource_id
  route_table_id = module.no_internet_route_table.resource_id
}

resource "azurerm_subnet_route_table_association" "container_apps" {
  subnet_id      = module.backbone_vnet.subnets["container_apps"].resource_id
  route_table_id = module.no_internet_route_table.resource_id
}