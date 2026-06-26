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