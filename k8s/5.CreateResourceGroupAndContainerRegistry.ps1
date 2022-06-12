param(
    [Parameter()]
    [ValidateNotNullOrEmpty()]
    [string]$Region = 'australiaeast',

    [Parameter()]
    [ValidateNotNullOrEmpty()]
    [string]$ResourceGroup = 'deployscrg',

    [Parameter()]
    [ValidateNotNullOrEmpty()]
    [string]$MyRegistry = 'deployscacr1',

    [Parameter()]
    [ValidateNotNullOrEmpty()]
    [string]$SkuAcr = 'Standard'  
)

# Setup CLI & Parameters for AKS creation
Write-Host "--- Setting up CLI & Params ---" -ForegroundColor Blue

# Create resource group
Write-Host "--- Creating resource group ---" -ForegroundColor Blue
az group create --name $ResourceGroup --location $Region
Write-Host "--- Complete: resource group ---" -ForegroundColor Green

# Create Azure Container Registry
Write-Host "--- Creating ACR ---" -ForegroundColor Blue
az acr create -n $MyRegistry -g $ResourceGroup --sku $SkuAcr --location $Region
Write-Host "--- Complete: ACR ---" -ForegroundColor Green

