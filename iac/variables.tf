variable "ENVIRONMENT" {
  description = "The deployment environment (e.g., dev, staging, prod)."
  type        = string
  validation {
    condition     = contains(["dev", "test", "prod"], var.ENVIRONMENT)
    error_message = "ENVIRONMENT must be one of: dev, test, prod."
  }
}

variable "AZURE_ROOT_REGION_NAME" {
  description = "The name of the Azure region where the root resources will be deployed."
  type        = string
  validation {
    condition = contains([
      "eastus",
      "eastus2",
      "westus",
      "westus2",
      "westus3",
      "centralus",
      "northcentralus",
      "southcentralus",
      "canadacentral",
      "canadaeast",
      "westeurope",
      "northeurope",
      "uksouth",
      "ukwest",
      "francecentral",
      "germanywestcentral",
      "swedencentral",
      "norwayeast",
      "switzerlandnorth",
      "italynorth",
      "polandcentral",
      "spaincentral",
      "japaneast",
      "japanwest",
      "koreacentral",
      "southeastasia",
      "eastasia",
      "australiaeast",
      "australiasoutheast",
      "australiacentral",
      "centralindia",
      "southindia",
      "westindia",
      "uaenorth",
      "southafricanorth",
      "brazilsouth"
    ], var.AZURE_ROOT_REGION_NAME)
    error_message = "AZURE_ROOT_REGION_NAME must be a valid supported Azure region short name."
  }
}

variable "AZURE_SUBSCRIPTION_ID" {
  description = "The Azure subscription ID where the resources will be deployed."
  type        = string
  validation {
    condition     = can(regex("^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[1-5][0-9a-fA-F]{3}-[89abAB][0-9a-fA-F]{3}-[0-9a-fA-F]{12}$", var.AZURE_SUBSCRIPTION_ID))
    error_message = "AZURE_SUBSCRIPTION_ID must be a valid GUID in Azure subscription ID format (e.g., xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx)."
  }
}