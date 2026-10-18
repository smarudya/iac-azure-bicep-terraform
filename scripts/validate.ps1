$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot

Write-Host 'Building Bicep template...'
az bicep build --file (Join-Path $root 'bicep/main.bicep')

Write-Host 'Formatting and validating Terraform...'
Push-Location (Join-Path $root 'terraform')
try {
    terraform fmt -check -recursive
    terraform init -backend=false
    terraform validate
}
finally {
    Pop-Location
}
