param(
	[Parameter(Mandatory = $true)]
	[string]$TenantId,

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
$storageAccountName = "aetherforge" + (Get-Random -Minimum 1000 -Maximum 9999);
Write-Verbose -Message "Creating Storage Account '$storageAccountName'";
$storageAccount = New-AzStorageAccount -ResourceGroupName $ResourceGroupName -Name $storageAccountName -Location (Get-AzResourceGroup -Name $ResourceGroupName).Location -SkuName Standard_LRS -Kind StorageV2 -ErrorAction Stop;

# Create the Terraform state container in the Storage Account
$containerName = 'tfstates'
Write-Verbose -Message "Creating Storage Container '$containerName' in Storage Account '$($storageAccount.StorageAccountName)'";
New-AzStorageContainer -Name $containerName -Context $storageAccount.Context -Permission Off -ErrorAction Stop | Out-Null

# Confirmation that the Storage Account was created successfully
Write-Verbose -Message "Storage Account '$($storageAccount.StorageAccountName)' created successfully in Resource Group '$ResourceGroupName' with Location '$($storageAccount.Location)'."

# Emit GitHub Actions outputs for downstream workflow steps
if ($env:GITHUB_OUTPUT) {
    "storage_account_name=$($storageAccount.StorageAccountName)" | Out-File -FilePath $env:GITHUB_OUTPUT -Encoding utf8 -Append
    "storage_account_id=$($storageAccount.Id)" | Out-File -FilePath $env:GITHUB_OUTPUT -Encoding utf8 -Append
    "storage_container_name=$containerName" | Out-File -FilePath $env:GITHUB_OUTPUT -Encoding utf8 -Append
}