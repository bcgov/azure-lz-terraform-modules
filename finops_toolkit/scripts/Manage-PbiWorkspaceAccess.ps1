<#
.SYNOPSIS
    Manages Entra ID group access for a Power BI workspace, supporting CI/CD and local use.

.DESCRIPTION
    Adds, removes, or updates Entra ID groups for a Power BI workspace based on a JSON list. Supports service principal or interactive login, dry run, structured logging, and robust error handling.

.PARAMETER WorkspaceId
    The GUID of the Power BI workspace.

.PARAMETER Action
    'Add' to add/update groups, 'Remove' to remove groups.

.PARAMETER AccessRight
    The access right to grant: Admin, Contributor, Member, or Viewer. Default is Viewer.

.PARAMETER BillingGroupsPath
    Path to the JSON file with billing group IDs. Default is 'billing_groups.json' in script directory.

.PARAMETER RemoveUnlistedGroups
    Remove any Entra ID group with access not in the JSON list.

.PARAMETER PromptRemoveUnlistedGroups
    Prompt before removing unlisted groups.

.PARAMETER DryRun
    Preview changes without making them.

.EXAMPLE
    pwsh ./Manage-PBIWorkspaceAccess.ps1 -WorkspaceId "<workspace-guid>" -Action Add -DryRun

.NOTES
    For CI/CD, set AZURE_CLIENT_ID, AZURE_TENANT_ID, AZURE_CLIENT_SECRET as environment variables for service principal auth.
#>

param(
    [Parameter(Mandatory=$true)]
    [string]$WorkspaceId,

    [Parameter(Mandatory=$true)]
    [ValidateSet('Add','Remove')]
    [string]$Action,

    [Parameter(Mandatory=$false)]
    [ValidateSet('Admin','Contributor','Member','Viewer')]
    [string]$AccessRight = 'Viewer',

    [Parameter(Mandatory=$false)]
    [string]$BillingGroupsPath = (Join-Path $PSScriptRoot 'billing_groups.json'),

    [Parameter(Mandatory=$false)]
    [switch]$RemoveUnlistedGroups,

    [Parameter(Mandatory=$false)]
    [switch]$PromptRemoveUnlistedGroups,

    [Parameter(Mandatory=$false)]
    [switch]$DryRun,

    [Parameter(Mandatory=$false)]
    [switch]$RemoveAllGroups,

    [Parameter(Mandatory=$false)]
    [switch]$RemoveAllListedGroups
)

function Write-Log {
    param([string]$Message, [string]$Level = 'notice')
    $prefix = ''
    switch ($Level) {
        'error' { $prefix = '::error::' }
        'warning' { $prefix = '::warning::' }
        'notice' { $prefix = '::notice::' }
        default { $prefix = '' }
    }
    Write-Host "$prefix$Message"
}

# Authenticate: Service principal for CI/CD, interactive for local
if ($env:AZURE_CLIENT_ID -and $env:AZURE_TENANT_ID -and $env:AZURE_CLIENT_SECRET) {
    Write-Log "Authenticating with service principal..." 'notice'
    az login --service-principal -u $env:AZURE_CLIENT_ID -p $env:AZURE_CLIENT_SECRET --tenant $env:AZURE_TENANT_ID | Out-Null
} else {
    Write-Log "Authenticating interactively..." 'notice'
    az login | Out-Null
}

# Read billing group IDs from JSON file
if (-Not (Test-Path $BillingGroupsPath)) {
    Write-Log "Billing groups file not found: $BillingGroupsPath" 'error'
    exit 1
}
$billingGroups = Get-Content $BillingGroupsPath | ConvertFrom-Json
$roleSuffixes = @('Owners', 'Readers', 'Contributors')

$Resource = "https://analysis.windows.net/powerbi/api"
$tokenResponse = az account get-access-token --resource $Resource | ConvertFrom-Json
$accessToken = $tokenResponse.accessToken
$headers = @{ Authorization = "Bearer $accessToken"; "Content-Type" = "application/json" }

function Get-EntraGroupObjectId {
    param([string]$GroupName)
    $groupInfo = az ad group show --group $GroupName --query id --output tsv 2>$null
    return $groupInfo
}

# Get current groups with access to the workspace
$uriList = "https://api.powerbi.com/v1.0/myorg/groups/$WorkspaceId/users"
try {
    $currentUsers = Invoke-RestMethod -Uri $uriList -Headers $headers -Method Get
} catch {
    Write-Log "Failed to get current workspace users." 'error'
    Write-Host $_
    exit 1
}
$currentGroupIds = @{}
foreach ($user in $currentUsers.value) {
    if ($user.principalType -eq 'Group') {
        $currentGroupIds[$user.identifier] = $user.groupUserAccessRight
    }
}

# Build the set of desired group object IDs and names
$desiredGroupIds = @{}
$desiredGroupNames = @{}
foreach ($groupId in $billingGroups) {
    foreach ($suffix in $roleSuffixes) {
        $entraGroup = "DO_PuC_Azure_Forge_${groupId}_$suffix"
        $objectId = Get-EntraGroupObjectId -GroupName $entraGroup
        if ($objectId) {
            $desiredGroupIds[$objectId] = $entraGroup
            $desiredGroupNames[$entraGroup] = $objectId
        } else {
            Write-Log "Group not found in Entra ID: $entraGroup" 'warning'
        }
    }
}

# Remove all Entra ID groups from the workspace if requested
if ($RemoveAllGroups) {
    Write-Log "RemoveAllGroups option selected. Removing all Entra ID groups from workspace $WorkspaceId..." 'warning'
    foreach ($existingId in $currentGroupIds.Keys) {
        $groupDisplay = $existingId
        $groupName = az ad group show --group $existingId --query displayName --output tsv 2>$null
        if ($groupName) { $groupDisplay = $groupName }
        if ($DryRun) {
            Write-Log "[DryRun] Would remove group: $groupDisplay (ObjectId: $existingId)" 'warning'
        } else {
            $uri = "https://api.powerbi.com/v1.0/myorg/groups/$WorkspaceId/users/$existingId"
            try {
                Invoke-RestMethod -Uri $uri -Headers $headers -Method Delete
                Write-Log "Removed group $groupDisplay from workspace." 'notice'
            } catch {
                Write-Log "Failed to remove group $groupDisplay : $_" 'error'
            }
        }
    }
    Write-Log "RemoveAllGroups operation complete." 'notice'
    exit 0
}

# Remove all listed Entra ID groups (from JSON + suffixes) if requested
if ($RemoveAllListedGroups) {
    Write-Log "RemoveAllListedGroups option selected. Removing only groups matching JSON + suffixes from workspace $WorkspaceId..." 'warning'
    foreach ($groupId in $billingGroups) {
        foreach ($suffix in $roleSuffixes) {
            $entraGroup = "DO_PuC_Azure_Forge_${groupId}_$suffix"
            $objectId = Get-EntraGroupObjectId -GroupName $entraGroup
            if ($objectId -and $currentGroupIds.ContainsKey($objectId)) {
                $groupDisplay = $entraGroup
                if ($DryRun) {
                    Write-Log "[DryRun] Would remove group: $groupDisplay (ObjectId: $objectId)" 'warning'
                } else {
                    $uri = "https://api.powerbi.com/v1.0/myorg/groups/$WorkspaceId/users/$objectId"
                    try {
                        Invoke-RestMethod -Uri $uri -Headers $headers -Method Delete
                        Write-Log "Removed group $groupDisplay from workspace." 'notice'
                    } catch {
                        Write-Log "Failed to remove group $groupDisplay : $_" 'error'
                    }
                }
            }
        }
    }
    Write-Log "RemoveAllListedGroups operation complete." 'notice'
    exit 0
}

# Optionally remove or display any group that has access but is not in the JSON file (regardless of naming pattern)
if ($RemoveUnlistedGroups -or $PromptRemoveUnlistedGroups) {
    foreach ($existingId in $currentGroupIds.Keys) {
        if (-not $desiredGroupIds.ContainsKey($existingId)) {
            $groupDisplay = $existingId
            $groupName = az ad group show --group $existingId --query displayName --output tsv 2>$null
            if ($groupName) { $groupDisplay = $groupName }
            $shouldRemove = $RemoveUnlistedGroups
            if ($PromptRemoveUnlistedGroups) {
                $answer = Read-Host "Unlisted Entra ID group has access: $groupDisplay (ObjectId: $existingId, Access: $($currentGroupIds[$existingId])). Remove? (y/n)"
                if ($answer -eq 'y' -or $answer -eq 'Y') { $shouldRemove = $true } else { $shouldRemove = $false }
            }
            if ($shouldRemove) {
                if ($DryRun) {
                    Write-Log "[DryRun] Would remove unlisted group: $groupDisplay (ObjectId: $existingId)" 'warning'
                } else {
                    Write-Log "Removing unlisted group: $groupDisplay (ObjectId: $existingId)" 'warning'
                    $uri = "https://api.powerbi.com/v1.0/myorg/groups/$WorkspaceId/users/$existingId"
                    try {
                        Invoke-RestMethod -Uri $uri -Headers $headers -Method Delete
                        Write-Log "Removed group $groupDisplay from workspace." 'notice'
                    } catch {
                        Write-Log "Failed to remove group $groupDisplay : $_" 'error'
                    }
                }
            } else {
                Write-Log "Skipped removal of unlisted group: $groupDisplay (ObjectId: $existingId)" 'notice'
            }
        }
    }
} else {
    foreach ($existingId in $currentGroupIds.Keys) {
        if (-not $desiredGroupIds.ContainsKey($existingId)) {
            $groupDisplay = $existingId
            $groupName = az ad group show --group $existingId --query displayName --output tsv 2>$null
            if ($groupName) { $groupDisplay = $groupName }
            Write-Log "Unlisted Entra ID group has access: $groupDisplay (ObjectId: $existingId, Access: $($currentGroupIds[$existingId]))" 'warning'
        }
    }
}

foreach ($groupId in $billingGroups) {
    foreach ($suffix in $roleSuffixes) {
        $entraGroup = "DO_PuC_Azure_Forge_${groupId}_$suffix"
        $objectId = Get-EntraGroupObjectId -GroupName $entraGroup
        if (-not $objectId) {
            continue
        }
        $alreadyHasAccess = $currentGroupIds.ContainsKey($objectId)
        $currentAccess = $currentGroupIds[$objectId]
        Write-Log "Processing group: $entraGroup (ObjectId: $objectId)" 'notice'
        if ($Action -eq 'Add') {
            if ($alreadyHasAccess) {
                Write-Log "$entraGroup already has access as $currentAccess." 'notice'
                if ($currentAccess -ne $AccessRight) {
                    Write-Log "Updating $entraGroup access from $currentAccess to $AccessRight (remove then add)." 'warning'
                    if ($DryRun) {
                        Write-Log "[DryRun] Would remove and re-add $entraGroup with $AccessRight." 'notice'
                    } else {
                        $removeUri = "https://api.powerbi.com/v1.0/myorg/groups/$WorkspaceId/users/$objectId"
                        try {
                            Invoke-RestMethod -Uri $removeUri -Headers $headers -Method Delete
                            Write-Log "Removed $entraGroup to update access." 'notice'
                        } catch {
                            Write-Log "Failed to remove $entraGroup for update : $_" 'error'
                            continue
                        }
                        $body = @{ 
                            identifier = $objectId
                            groupUserAccessRight = $AccessRight
                            principalType = "Group"
                        } | ConvertTo-Json
                        $addUri = "https://api.powerbi.com/v1.0/myorg/groups/$WorkspaceId/users"
                        try {
                            Invoke-RestMethod -Uri $addUri -Headers $headers -Method Post -Body $body
                            Write-Log "Updated $entraGroup to $AccessRight." 'notice'
                        } catch {
                            Write-Log "Failed to add $entraGroup after removal : $_" 'error'
                        }
                    }
                }
                Write-Host ""
                continue
            }
            if ($DryRun) {
                Write-Log "[DryRun] Would add $entraGroup as $AccessRight." 'notice'
            } else {
                $body = @{ 
                    identifier = $objectId
                    groupUserAccessRight = $AccessRight
                    principalType = "Group"
                } | ConvertTo-Json
                $uri = "https://api.powerbi.com/v1.0/myorg/groups/$WorkspaceId/users"
                try {
                    Invoke-RestMethod -Uri $uri -Headers $headers -Method Post -Body $body
                    Write-Log "Added $entraGroup as $AccessRight." 'notice'
                } catch {
                    Write-Log "Failed to add $entraGroup : $_" 'error'
                }
            }
        } elseif ($Action -eq 'Remove') {
            if ($alreadyHasAccess) {
                if ($DryRun) {
                    Write-Log "[DryRun] Would remove $entraGroup from workspace." 'notice'
                } else {
                    $uri = "https://api.powerbi.com/v1.0/myorg/groups/$WorkspaceId/users/$objectId"
                    try {
                        Invoke-RestMethod -Uri $uri -Headers $headers -Method Delete
                        Write-Log "Removed $entraGroup from workspace." 'notice'
                    } catch {
                        Write-Log "Failed to remove $entraGroup : $_" 'error'
                    }
                }
            } else {
                Write-Log "$entraGroup does not have access, skipping remove." 'notice'
            }
        }
        Write-Host ""
    }
}