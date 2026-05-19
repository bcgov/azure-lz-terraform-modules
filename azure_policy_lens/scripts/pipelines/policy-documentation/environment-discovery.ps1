using module ../../../ps_modules/AzPolicyLens.Discovery/AzPolicyLens.Discovery.psd1
<#
====================================================================================
AUTHOR: Tao Yang
DATE: 20/10/2025
NAME: environment-discovery.ps1
VERSION: 1.0.0
COMMENT: Azure Policy automated documentation environment discovery pipeline script.
====================================================================================
#>
[CmdletBinding()]
[OutputType([hashtable])]
param (
  [parameter(Mandatory = $true, HelpMessage = 'The Top-level Management Group name.')]
  [ValidateNotNullOrEmpty()]
  [string]$TopLevelManagementGroupName,

  [parameter(Mandatory = $false, HelpMessage = 'Config File that contains additional builtin Policy Metadata from security control frameworks to include.')]
  [string]$AdditionalBuiltInPolicyMetadataConfigFilePath = "",

  [parameter(Mandatory = $true, HelpMessage = 'Zip Export file path')]
  [ValidateNotNullOrEmpty()]
  [string]$OutputFilePath
)

#functions

function isValidBuiltInPolicyMetadataConfig {
  [OutputType([bool])]
  param (
    [parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]$config
  )
  $schema = @'
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "type": "array",
  "items": {
    "type": "object",
    "properties": {
      "framework": {
        "type": "string"
      },
      "policyMetadataNameRegex": {
        "type": "string"
      }
    },
    "required": [
      "framework",
      "policyMetadataNameRegex"
    ]
  },
  "additionalItems": false
}
'@
  Test-Json -json $config -Schema $schema
}

#environment variables
$EncryptionKey = $env:EncryptionKey
$EncryptionIV = $env:EncryptionIV
#make sure the output folder exists
$OutputFolder = Split-Path -Path $OutputFilePath -Parent
$OutputFileName = Split-Path -Path $OutputFilePath -Leaf
$OutputFileExtension = [System.IO.Path]::GetExtension($OutputFileName)
if ($OutputFileExtension -ne '.zip') {
  Throw "The output file path must have a .zip extension."
} else {
  $discoveryFileBaseName = $OutputFileName.Substring(0, $OutputFileName.Length - $OutputFileExtension.Length)
}

#validate the additional built-in policy metadata config files
$additionalBuiltInPolicyMetadataConfigs = @()
if ($AdditionalBuiltInPolicyMetadataConfigFilePath.length -gt 0) {
if (-not [string]::IsNullOrWhiteSpace($AdditionalBuiltInPolicyMetadataConfigFilePath)) {
  Write-Output "Validating additional built-in policy metadata config file '$AdditionalBuiltInPolicyMetadataConfigFilePath'."
  if (-not (Test-Path -Path $AdditionalBuiltInPolicyMetadataConfigFilePath)) {
    Throw "The additional built-in policy metadata config file '$AdditionalBuiltInPolicyMetadataConfigFilePath' does not exist."
  }
  $configContent = Get-Content -Path $AdditionalBuiltInPolicyMetadataConfigFilePath -Raw
  if (-not (isValidBuiltInPolicyMetadataConfig -config $configContent)) {
    Throw "The additional built-in policy metadata config file '$AdditionalBuiltInPolicyMetadataConfigFilePath' is not valid."
  } else {
    $configObject = $configContent | ConvertFrom-Json
    foreach ($config in $configObject) {
      $additionalBuiltInPolicyMetadataConfigs += $config
    }
    Write-Output "The additional built-in policy metadata config file '$AdditionalBuiltInPolicyMetadataConfigFilePath' is valid and has been added."
  }

}

if (-not (Test-Path -Path $OutputFolder)) {
  Write-Output "Creating output folder '$OutputFolder'."
  New-Item -ItemType Directory -Path $OutputFolder -Force | Out-Null
} else {
  Write-Output "Output folder '$OutputFolder' already exists, make sure it does not contain any existing files."
  $existingFiles = Get-ChildItem -Path $OutputFolder -File
  if ($existingFiles) {
    Throw "The output folder contains $($existingFiles.count) existing files:. Please ensure it contains no existing files or choose a different output folder."
  }
}

#perform discovery and output the result to an encrypted file using the provided AES key and IV
Write-Verbose "Getting Azure oAuth token." -Verbose
$token = $null
$resourceUrl = 'https://management.azure.com/'

try {
  $accessToken = Get-AzAccessToken -ResourceUrl $resourceUrl -ErrorAction Stop
  if ($accessToken.Token -is [securestring]) {
    $token = ConvertFrom-SecureString $accessToken.Token -AsPlainText
  } elseif ($accessToken.Token -is [string]) {
    $token = $accessToken.Token
  }
} catch {
  Write-Warning "Get-AzAccessToken failed. Falling back to Azure CLI token retrieval. Error: $($_.Exception.Message)"
}

if ([string]::IsNullOrWhiteSpace($token)) {
  try {
    $token = (az account get-access-token --resource $resourceUrl --query accessToken -o tsv).Trim()
  } catch {
    Write-Warning "Azure CLI token retrieval failed. Error: $($_.Exception.Message)"
  }
}

if ([string]::IsNullOrWhiteSpace($token)) {
  Throw "Unable to acquire Azure access token from both Az PowerShell and Azure CLI contexts."
}

Write-Output "Starting environment discovery for top-level Management Group '$TopLevelManagementGroupName'."
$DiscoveryParams = @{
  TopLevelManagementGroupName = $TopLevelManagementGroupName
  Token                       = $token
  OutputFileDirectory         = $OutputFolder
  OutputFileBaseName          = $discoveryFileBaseName
  AdditionalBuiltInPolicyMetadataConfig = $additionalBuiltInPolicyMetadataConfigs
}
if ($EncryptionKey -and $EncryptionIV) {
  $DiscoveryParams.Add('EncryptionKey', $EncryptionKey)
  $DiscoveryParams.Add('EncryptionIV', $EncryptionIV)
}

$result = Invoke-AzplEnvironmentDiscovery @DiscoveryParams -verbose

Write-Output "Environment discovery completed. Output saved to '$OutputFilePath'."
