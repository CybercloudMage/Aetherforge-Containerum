variable "ENVIRONMENT" {
  description = "The environment to deploy to"
  type        = string
  validation {
    condition     = contains(["dev", "test", "prod"], var.ENVIRONMENT)
    error_message = "ENVIRONMENT must be one of: dev, test, prod."
  }
}

variable "ROOT_RG_NAME" {
  description = "The name of the root resource group"
  type        = string
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
    condition     = can(regex("^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[1-5][0-9a-fA-F]{3}-[89aAbB][0-9a-fA-F]{3}-[0-9a-fA-F]{12}$", var.SUBSCRIPTION_ID))
    error_message = "SUBSCRIPTION_ID must be a valid GUID."
  }
}

variable "AZURE_CLIENT_ID" {
  description = "The Azure Client ID for authentication"
  type        = string
}

variable "AZURE_CLIENT_SECRET" {
  description = "The Azure Client Secret for authentication"
  type        = string
}