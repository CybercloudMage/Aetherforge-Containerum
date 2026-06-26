module "root_rg" {
	source  = "Azure/avm-res-resources-resourcegroup/azurerm"
	version = "~> 0.4"

	name     = "rg-aetherforge-${var.ENVIRONMENT}"
	location = var.AZURE_ROOT_REGION_NAME
}

