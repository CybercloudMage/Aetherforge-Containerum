# Root Resource Group for the resources to reside within
module "root_rg" {
	source  = "Azure/avm-res-resources-resourcegroup/azurerm"
	version = "~> 0.4"

	name     = "rg-aetherforge-${var.ENVIRONMENT}"
	location = var.ROOT_RG_LOCATION
}

data "azurerm_client_config" "current" {}

resource "azapi_resource_action" "register_microsoft_app" {
	action      = "/providers/Microsoft.App/register"
	method      = "POST"
	resource_id = "/subscriptions/${data.azurerm_client_config.current.subscription_id}"
	type        = "Microsoft.Resources/subscriptions@2021-04-01"
}

resource "azurerm_log_analytics_workspace" "container_apps" {
	name                = "law-aetherforge-${var.ENVIRONMENT}"
	location            = var.ROOT_RG_LOCATION
	resource_group_name = module.root_rg.name
	sku                 = "PerGB2018"
	retention_in_days   = 30
}

# Data for the subnet the container app will reside on.
data "azurerm_subnet" "container" {
	name                 = var.CONTAINER_APP_SUBNET_NAME
	virtual_network_name = var.VNET_NAME
	resource_group_name  = var.VNET_RESOURCE_GROUP_NAME
}

# Data for the Azure VNet subnet that the container registry will reside on.
data "azurerm_subnet" "container_registry" {
	name                 = var.CONTAINER_REGISTRY_SUBNET_NAME
	virtual_network_name = var.VNET_NAME
	resource_group_name  = var.VNET_RESOURCE_GROUP_NAME
}

# Data connection to the different private DNS zones for container registry. 
data "azurerm_private_dns_zone" "container_registry" {
	name                = "privatelink.azurecr.io"
	resource_group_name = var.VNET_RESOURCE_GROUP_NAME
}

# Definition of the container registry to be created.
module "container_registry" {
	source  = "Azure/avm-res-containerregistry-registry/azurerm"
	version = "~> 0.4"

	name                = "acraetherforge${var.ENVIRONMENT}"
	location            = var.ROOT_RG_LOCATION
	resource_group_name = module.root_rg.name
	sku                 = "Premium"
	admin_enabled       = false
	public_network_access_enabled = false
	network_rule_bypass_option    = "None"
	private_endpoints             = {
		primary = {
			subnet_resource_id            = data.azurerm_subnet.container_registry.id
			private_dns_zone_resource_ids = [data.azurerm_private_dns_zone.container_registry.id]
		}
	}
}

module "container_app_env" {
	source  = "Azure/avm-res-app-managedenvironment/azurerm"
	version = "~> 0.4"

	name                    = "cae-aetherforge-${var.ENVIRONMENT}"
	location                = var.ROOT_RG_LOCATION
	resource_group_name     = module.root_rg.name
	infrastructure_subnet_id = data.azurerm_subnet.container.id
	log_analytics_workspace = {
		resource_id = azurerm_log_analytics_workspace.container_apps.id
	}
	zone_redundant = false

	depends_on = [azapi_resource_action.register_microsoft_app]
}

# Definition of the container app to be created.
module "container_app" {
	source  = "Azure/avm-res-app-containerapp/azurerm"
	version = "~> 0.4"

	name                                  = "ca-aetherforge-${var.ENVIRONMENT}"
	location                              = var.ROOT_RG_LOCATION
	resource_group_name                   = module.root_rg.name
	container_app_environment_resource_id = module.container_app_env.resource_id
	revision_mode                         = "Single"
	managed_identities = {
		system_assigned = true
	}
	template = {
		containers = [
			{
				name   = "aetherforge-web"
				image  = "mcr.microsoft.com/azuredocs/containerapps-helloworld:latest"
				cpu    = 0.25
				memory = "0.5Gi"
			}
		]
		min_replicas = 1
		max_replicas = 1
	}
	ingress = {
		allow_insecure_connections = false
		external_enabled           = true
		target_port                = 80
		transport                  = "auto"
		traffic_weight = [
			{
				latest_revision = true
				percentage      = 100
			}
		]
	}
}