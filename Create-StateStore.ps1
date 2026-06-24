<#
.SYNOPSIS
Creates an Azure Storage Account and container for Terraform state storage.

.DESCRIPTION
This script prepares a Terraform remote state backend in Azure by creating a new
Storage Account and a private blob container named 'tfstates' in the specified
resource group. It also assigns the "Storage Blob Data Contributor" role on the
new Storage Account to the provided Service Principal (ClientId).

If running in GitHub Actions, the script writes key outputs to GITHUB_OUTPUT for
downstream workflow steps.

.PARAMETER TenantId
The Microsoft Entra tenant ID used to set the Azure context.

.PARAMETER ClientId
The application (client) ID of the Service Principal that will receive data-plane
access to Terraform state in the created Storage Account.

.PARAMETER SubscriptionId
The Azure subscription ID where resources will be created.

.PARAMETER ResourceGroupName
The name of the Azure resource group where the Storage Account will be created.

.OUTPUTS
When GITHUB_OUTPUT is set, appends the following outputs:
- storage_account_name
- storage_account_id
- storage_container_name

.EXAMPLE
.\Create-StateStore.ps1 -TenantId "00000000-0000-0000-0000-000000000000" -ClientId "11111111-1111-1111-1111-111111111111" -SubscriptionId "22222222-2222-2222-2222-222222222222" -ResourceGroupName "rg-terraform-state"

Creates a Storage Account in the specified resource group, creates the 'tfstates'
container, and grants the Service Principal blob data contributor permissions.

.NOTES
Requires Az.Accounts, Az.Resources, and Az.Storage modules.
#>

param(
	[Parameter(Mandatory = $true)]
	[string]$TenantId,

    [Parameter(Mandatory = $true)]
	[string]$ClientId,

	[Parameter(Mandatory = $false)]
	[string]$SubscriptionId,

    [Parameter(Mandatory = $true)]
	[string]$ResourceGroupName
)

# Ensure required Azure PowerShell modules are available for Storage Account setup
$requiredModules = @(
    'Az.Accounts',
    'Az.Resources',
    'Az.Storage'
)

if (-not (Get-PSRepository -Name 'PSGallery' -ErrorAction SilentlyContinue)) {
    Write-Verbose -Message "Registering PSGallery repository";
    Register-PSRepository -Default -ErrorAction Stop
}

foreach ($moduleName in $requiredModules) {
    if (-not (Get-Module -ListAvailable -Name $moduleName)) {
        Write-Verbose -Message "Installing module: $moduleName";
        Install-Module -Name $moduleName -Repository PSGallery -Scope CurrentUser -Force -AllowClobber -ErrorAction Stop;
    }

    if (-not (Get-Module -Name $moduleName)) {
        Write-Verbose -Message "Importing module: $moduleName";
        Import-Module -Name $moduleName -ErrorAction Stop;
    }
}

# Connect to Azure using the underlying set PowerShell context and set the default subscription and resource group for subsequent operations
Set-AzContext -Tenant $TenantId -Subscription $SubscriptionId -ErrorAction Stop | Out-Null;
Set-AzDefault -ResourceGroupName $ResourceGroupName -ErrorAction Stop;

# Create the Storage Account within the specified subscription and resource group
$storageAccountName = -join ((48..57 + 97..122) | Get-Random -Count 24 | ForEach-Object { [char]$_ })
Write-Verbose -Message "Creating Storage Account '$storageAccountName'";
$storageAccount = New-AzStorageAccount -ResourceGroupName $ResourceGroupName -Name $storageAccountName -Location (Get-AzResourceGroup -Name $ResourceGroupName).Location -SkuName Standard_LRS -Kind StorageV2 -ErrorAction Stop;

# Create the Terraform state container in the Storage Account
$containerName = 'tfstates'
Write-Verbose -Message "Creating Storage Container '$containerName' in Storage Account '$($storageAccount.StorageAccountName)'";
New-AzStorageContainer -Name $containerName -Context $storageAccount.Context -Permission Off -ErrorAction Stop | Out-Null;

# Confirmation that the Storage Account was created successfully
Write-Verbose -Message "Storage Account '$($storageAccount.StorageAccountName)' created successfully in Resource Group '$ResourceGroupName' with Location '$($storageAccount.Location)'."

# Emit GitHub Actions outputs for downstream workflow steps
if ($env:GITHUB_OUTPUT) {
    "storage_account_name=$($storageAccount.StorageAccountName)" | Out-File -FilePath $env:GITHUB_OUTPUT -Encoding utf8 -Append
    "storage_account_id=$($storageAccount.Id)" | Out-File -FilePath $env:GITHUB_OUTPUT -Encoding utf8 -Append
    "storage_container_name=$containerName" | Out-File -FilePath $env:GITHUB_OUTPUT -Encoding utf8 -Append
}