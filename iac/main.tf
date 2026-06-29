data "azurerm_resource_group" "rg" {
	name = var.ROOT_RG_NAME
}

module "vnet" {
	source  = "Azure/avm-res-network-virtualnetwork/azurerm"
	version = "0.6.0"

	name                = "aetherforge-vnet"
	location            = data.azurerm_resource_group.rg.location
	resource_group_name = data.azurerm_resource_group.rg.name
	address_space       = ["10.100.0.0/16"]

	subnets = {
		github_actions = {
			name             = "github-actions-snet"
			address_prefixes = ["10.100.1.0/24"]
			delegation = [{
				name = "github-actions-delegation"
				service_delegation = {
					name    = "GitHub.Network/networkSettings"
					actions = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
				}
			}]
		}

		container_apps = {
			name             = "container-apps-snet"
			address_prefixes = ["10.100.2.0/23"]
			delegation = [{
				name = "container-apps-delegation"
				service_delegation = {
					name = "Microsoft.App/environments"
					actions = [
						"Microsoft.Network/virtualNetworks/subnets/join/action",
					]
				}
			}]
		}

		azure_firewall = {
			name             = "AzureFirewallSubnet"
			address_prefixes = ["10.100.4.0/26"]
		}
	}
}

