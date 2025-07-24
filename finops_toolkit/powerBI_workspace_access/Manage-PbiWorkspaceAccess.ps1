<#
.SYNOPSIS
  Add, modify, or remove multiple Entra ID security groups’ access to a Power BI workspace,
  identified by either name or GUID.

.PARAMETER Action
  Valid values: Add, Remove, Modify.

.PARAMETER Environment
  The environment token (e.g. “Dev”, “Prod”).

.PARAMETER BillingGroup
  The billing group code (e.g. “e833c2”).

.PARAMETER WorkspaceName
  (Optional) Name of the workspace. Ignored if WorkspaceId is supplied.

.PARAMETER WorkspaceId
  (Optional) GUID of the workspace. If supplied, no lookup by name is performed.

.PARAMETER GroupSuffixes
  Array of suffixes to append (default @("Contributors","Owners")).

.PARAMETER GroupObjectIds
  Hashtable mapping suffix → ObjectId. If omitted, resolution via Microsoft Graph is used.

.EXAMPLE
  # Use workspace name
  .\Manage-PbiWorkspaceAccess.ps1 `
    -Action Add `
    -Environment Prod `
    -BillingGroup e833c2 `
    -WorkspaceName "FinOps Toolkit"

.EXAMPLE
  # Use workspace GUID in CI
  .\Manage-PbiWorkspaceAccess.ps1 `
    -Action Modify `
    -Environment Dev `
    -BillingGroup abc123 `
    -WorkspaceId 23FCBDBD-A979-45D8-B1C8-6D21E0F4BE50
#>

param(
    [Parameter(Mandatory)]
    [ValidateSet("Add","Remove","Modify")]
    [string]   $Action,

    [Parameter(Mandatory)]
    [string]   $Environment,

    [Parameter(Mandatory)]
    [string]   $BillingGroup,

    [Parameter()]
    [string]   $WorkspaceName,

    [Parameter()]
    [string]   $WorkspaceId,

    [Parameter()]
    [string[]] $GroupSuffixes  = @("Contributors","Owners"),

    [Parameter()]
    [hashtable] $GroupObjectIds
)

# Desired access level
$DesiredAccess = "Viewer"

#region Bootstrap Modules
if (-not (Get-Module -ListAvailable -Name MicrosoftPowerBIMgmt.Profile)) {
    Install-Module -Name MicrosoftPowerBIMgmt -Scope CurrentUser -Force
}
Import-Module MicrosoftPowerBIMgmt.Profile -ErrorAction Stop
Import-Module MicrosoftPowerBIMgmt.Workspaces -ErrorAction Stop

if (-not (Get-Module -ListAvailable -Name Microsoft.Graph.Groups)) {
    Install-Module -Name Microsoft.Graph -Scope CurrentUser -Force
}
Import-Module Microsoft.Graph.Groups -ErrorAction Stop
#endregion

#region Resolve AAD Group via Graph
function Get-GroupObjectId {
    param([string] $DisplayName)

    if (-not (Get-MgContext -ErrorAction SilentlyContinue)) {
        Connect-MgGraph -Scopes Group.Read.All -ErrorAction Stop
    }

    $grp = Get-MgGroup -Filter "displayName eq '$DisplayName'" -ConsistencyLevel eventual
    if (-not $grp) {
        throw "Azure AD group '$DisplayName' not found."
    }
    return $grp.Id
}
#endregion

#region Connect to Power BI
if ($env:AZURE_CLIENT_ID -and $env:AZURE_TENANT_ID -and $env:AZURE_CLIENT_SECRET) {
    Connect-PowerBIServiceAccount `
      -ServicePrincipal `
      -TenantId $env:AZURE_TENANT_ID `
      -ClientId $env:AZURE_CLIENT_ID `
      -ClientSecret $env:AZURE_CLIENT_SECRET `
      -ErrorAction Stop
}
else {
    Connect-PowerBIServiceAccount -ErrorAction Stop
}
#endregion

#region Determine WorkspaceId
if ($WorkspaceId) {
    Write-Host "Using supplied WorkspaceId: $WorkspaceId"
    $wsId = $WorkspaceId
}
elseif ($WorkspaceName) {
    Write-Host "Looking up workspace by name: '$WorkspaceName'"
    try {
        $ws = Get-PowerBIWorkspace -Scope Organization |
              Where-Object Name -eq $WorkspaceName
    }
    catch {
        throw "Failed to list workspaces. Check permissions or supply -WorkspaceId."
    }
    if (-not $ws) {
        throw "Workspace named '$WorkspaceName' not found."
    }
    $wsId = $ws.Id
    Write-Host "Resolved WorkspaceId: $wsId"
}
else {
    throw "You must supply either -WorkspaceName or -WorkspaceId."
}
#endregion

#region Retrieve Existing Users
$restUrl = "v1.0/myorg/groups/$wsId/users"
$users   = (Invoke-PowerBIRestMethod -Url $restUrl -Method Get).value
#endregion

#region Process Group Suffixes
foreach ($suffix in $GroupSuffixes) {
    $displayName = "DO_PuC_Azure_${Environment}_${BillingGroup}_${suffix}"
    Write-Host "`nProcessing group '$displayName'"

    if ($GroupObjectIds -and $GroupObjectIds.ContainsKey($suffix)) {
        $objectId = $GroupObjectIds[$suffix]
    }
    else {
        $objectId = Get-GroupObjectId -DisplayName $displayName
    }

    $existing = $users | Where-Object {
        $_.identifier -eq $objectId -and $_.principalType -eq "Group"
    }

    switch ($Action) {
        "Add" {
            if ($existing) {
                Write-Host "Already has access: $($existing.accessRight)"
            }
            else {
                Add-PowerBIWorkspaceUser `
                  -Scope Organization `
                  -Id $wsId `
                  -PrincipalType Group `
                  -Identifier $objectId `
                  -AccessRight $DesiredAccess
                Write-Host "Added as $DesiredAccess."
            }
        }
        "Remove" {
            if ($existing) {
                Remove-PowerBIWorkspaceUser `
                  -Scope Organization `
                  -Id $wsId `
                  -PrincipalType Group `
                  -Identifier $objectId
                Write-Host "Removed access."
            }
            else {
                Write-Host "No existing access; skipped."
            }
        }
        "Modify" {
            if ($existing) {
                if ($existing.accessRight -ne $DesiredAccess) {
                    Remove-PowerBIWorkspaceUser `
                      -Scope Organization `
                      -Id $wsId `
                      -PrincipalType Group `
                      -Identifier $objectId
                    Add-PowerBIWorkspaceUser `
                      -Scope Organization `
                      -Id $wsId `
                      -PrincipalType Group `
                      -Identifier $objectId `
                      -AccessRight $DesiredAccess
                    Write-Host "Updated to $DesiredAccess."
                }
                else {
                    Write-Host "Already at $DesiredAccess."
                }
            }
            else {
                Add-PowerBIWorkspaceUser `
                  -Scope Organization `
                  -Id $wsId `
                  -PrincipalType Group `
                  -Identifier $objectId `
                  -AccessRight $DesiredAccess
                Write-Host "Added as $DesiredAccess."
            }
        }
    }
}
#endregion

Write-Host "`nAll operations completed."