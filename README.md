# Aetherforge-Containerum
A cyber-arcane ritual that weaves Azure resources into existence—binding state, registry, and container into a living cloud construct.

## Terraform state backend model

This repository is configured to use an `azurerm` backend with OIDC + Azure AD auth, where:

- `AZURE_*` values are used for deploying resources.
- `TFSTATE_*` values are used only for Terraform backend (state storage).
- `TFSTATE_SUBSCRIPTION_ID` must be different from `AZURE_SUBSCRIPTION_ID`.

### Required GitHub secrets

Deployment secrets:

- `AZURE_CLIENT_ID`
- `AZURE_TENANT_ID`
- `AZURE_SUBSCRIPTION_ID`

Backend (state) secrets:

- `TFSTATE_CLIENT_ID`
- `TFSTATE_TENANT_ID`
- `TFSTATE_SUBSCRIPTION_ID`
- `TFSTATE_RESOURCE_GROUP_NAME`
- `TFSTATE_STORAGE_ACCOUNT_NAME`
- `TFSTATE_CONTAINER_NAME`

### Required GitHub environment variables

- `AZURE_ROOT_LOCATION`
- `AZURE_VNET_RESOURCE_GROUP_NAME`
- `AZURE_VNET_NAME`
- `AZURE_CONTAINER_APP_SUBNET_NAME`
- `AZURE_CONTAINER_REGISTRY_SUBNET_NAME`

### Required RBAC for backend identity (`TFSTATE_CLIENT_ID`)

At minimum, assign the following in the tfstate subscription:

- Data plane: `Storage Blob Data Contributor` on the tfstate container.
- Management plane: `Reader` on the tfstate storage account.

Without management-plane read access, backend initialization can fail even if blob data permissions are present.
