variable "ENVIRONMENT" {
  description = "The environment to deploy to"
  type        = string
  validation {
    condition     = contains(["dev", "test", "prod"], var.ENVIRONMENT)
    error_message = "ENVIRONMENT must be one of: dev, test, prod."
  }
}

variable "ROOT_RG_LOCATION" {
  description = "The location for the root resource group"
  type        = string
  validation {
    condition = contains([
      "australiacentral", "australiacentral2", "australiaeast", "australiasoutheast",
      "brazilsouth", "brazilsoutheast", "canadacentral", "canadaeast",
      "centralindia", "centralus", "eastasia", "eastus", "eastus2",
      "francecentral", "francesouth", "germanynorth", "germanywestcentral",
      "israelcentral", "italynorth", "japaneast", "japanwest",
      "koreacentral", "koreasouth", "mexicocentral", "newzealandnorth",
      "northcentralus", "northeurope", "norwayeast", "norwaywest",
      "polandcentral", "qatarcentral", "southafricanorth", "southafricawest",
      "southcentralus", "southeastasia", "southindia", "spaincentral",
      "swedencentral", "swedensouth", "switzerlandnorth", "switzerlandwest",
      "uaecentral", "uaenorth", "uksouth", "ukwest",
      "westcentralus", "westeurope", "westindia", "westus", "westus2", "westus3"
    ], lower(var.ROOT_RG_LOCATION))
    error_message = "ROOT_RG_LOCATION must be a valid Azure region short name (for example: eastus, westeurope, westus2)."
  }
}

variable "TENANT_ID" {
  description = "The Azure Tenant ID"
  type        = string
  validation {
    condition     = can(regex("^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[1-5][0-9a-fA-F]{3}-[89aAbB][0-9a-fA-F]{3}-[0-9a-fA-F]{12}$", var.TENANT_ID))
    error_message = "TENANT_ID must be a valid GUID."
  }
}

variable "SUBSCRIPTION_ID" {
  description = "The Azure Subscription ID"
  type        = string
  validation {
    condition     = can(regex("^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[1-5][0-9a-fA-F]{3}-[89aAbB][0-9a-fA-F]{3}-[0-9a-fA-F]{12}$", var.TENANT_ID))
    error_message = "TENANT_ID must be a valid GUID."
  }
}