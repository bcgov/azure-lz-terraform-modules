<#
.SYNOPSIS
    Lists Row-Level Security (RLS) roles and members for a Power BI dataset using the Power BI REST API.

.DESCRIPTION
    Authenticates with Azure AD, retrieves an access token, and calls the Power BI REST API to list RLS roles and their members for the specified dataset.

.NOTES
    Requires AzureAD and Power BI Service permissions. You must be an admin or have sufficient rights on the workspace/dataset.
    Register an Azure AD app and grant it the necessary Power BI API permissions if using service principal.
#>

param(
    [Parameter(Mandatory=$false)]
    [string]$WorkspaceId = "1746f162-d47e-497c-a2a3-96ee37e5e2b6",

    [Parameter(Mandatory=$false)]
    [string]$DatasetId = "0083a179-9812-4f52-b104-a7d6128d4d07"
)

$TenantId = "common" # Use your tenant ID if needed
$Resource = "https://analysis.windows.net/powerbi/api"
$Authority = "https://login.microsoftonline.com/$TenantId/oauth2/v2.0/authorize"

# Prompt for login and get token
$tokenResponse = az account get-access-token --resource $Resource | ConvertFrom-Json
$accessToken = $tokenResponse.accessToken

# Get dataset RLS roles (groups)
$uri = "https://api.powerbi.com/v1.0/myorg/groups/$WorkspaceId/datasets/$DatasetId/roles"
$headers = @{ Authorization = "Bearer $accessToken" }

$response = Invoke-RestMethod -Uri $uri -Headers $headers -Method Get

if ($response.value) {
    foreach ($role in $response.value) {
        Write-Host "Role: $($role.name)" -ForegroundColor Cyan
        if ($role.members) {
            $role.members | Format-Table
        } else {
            Write-Host "  No members assigned." -ForegroundColor Yellow
        }
        Write-Host ""
    }
} else {
    Write-Host "No RLS roles found for this dataset." -ForegroundColor Yellow
}
