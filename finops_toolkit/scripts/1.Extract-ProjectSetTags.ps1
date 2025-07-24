<#
.SYNOPSIS
  Extracts `tags.account_coding`, `tags.ministry_name`, and `tags.billing_group` from all
  project.json files under the /projects directory of a private GitHub repository,
  then emits three deduplicated JSON arrays.

.PARAMETER Token
  A GitHub Personal Access Token with `repo` scope. Defaults to $env:GITHUB_TOKEN.

.PARAMETER Owner
  GitHub organization or user. Defaults to `bcgov-c`.

.PARAMETER Repo
  GitHub repository name. Defaults to `azure-lz-vending-forge`.

.PARAMETER DirectoryPath
  Path inside the repo to scan. Defaults to `projects`.

.PARAMETER OutputDir
  Where to write the three JSON files. Defaults to current directory.

.EXAMPLE
  # Set your PAT in env var, then run:
  $env:GITHUB_TOKEN = 'ghp_xxx…'
  .\Extract-ProjectTags.ps1

.EXAMPLE
  # Explicit parameters
  .\Extract-ProjectTags.ps1 `
    -Token ghp_xxx… `
    -Owner bcgov-c `
    -Repo azure-lz-vending-forge `
    -DirectoryPath projects `
    -OutputDir .\output
#>

param(
    [string] $Token         = $env:GITHUB_TOKEN,
    [string] $Owner         = 'bcgov-c',
    [string] $Repo          = 'azure-lz-vending-forge',
    [string] $DirectoryPath = 'projects',
    [string] $OutputDir     = '.'
)

if (-not $Token) {
    Write-Error "GitHub token is required. Set \$env:GITHUB_TOKEN or pass -Token."
    exit 1
}

# Prepare
$baseApiUrl = "https://api.github.com/repos/$Owner/$Repo/contents/$DirectoryPath"
$headers    = @{
    Authorization = "token $Token"
    Accept        = 'application/vnd.github.v3+json'
    'User-Agent'  = "$Repo-extractor-script"
}

# Fetch the listing of folders under /projects
try {
    $entries = Invoke-RestMethod -Uri $baseApiUrl -Headers $headers -Method Get
}
catch {
    Write-Error "Failed to list directory '$DirectoryPath'. $_"
    exit 1
}

# Initialize collectors
$billingGroups     = [System.Collections.Generic.HashSet[string]]::new()
$accountCodings  = [System.Collections.Generic.HashSet[string]]::new()
$ministryNames   = [System.Collections.Generic.HashSet[string]]::new()

# Loop each subfolder
foreach ($entry in $entries) {
    if ($entry.type -ne 'dir') { continue }

    $projectJsonPath = "$DirectoryPath/$($entry.name)/project.json"
    $fileApiUrl = "https://api.github.com/repos/$Owner/$Repo/contents/$projectJsonPath"

    try {
        $file = Invoke-RestMethod -Uri $fileApiUrl -Headers $headers -Method Get
    }
    catch {
        Write-Warning "Could not fetch '$projectJsonPath'. Skipping."
        continue
    }

    # Decode base64 content
    $decoded = [System.Text.Encoding]::UTF8.GetString(
        [System.Convert]::FromBase64String($file.content)
    )

    # Parse JSON
    try {
        $json = $decoded | ConvertFrom-Json
    }
    catch {
        Write-Warning "Invalid JSON in '$projectJsonPath'. Skipping."
        continue
    }

    # Collect values
    if ($json.identifier) {
        $billingGroups.Add($json.identifier) | Out-Null
    }
    if ($json.tags.account_coding) {
        $accountCodings.Add($json.tags.account_coding) | Out-Null
    }
    if ($json.tags.ministry_name) {
        $ministryNames.Add($json.tags.ministry_name) | Out-Null
    }
}

# Calculate counts (HashSet.Count gives distinct count)
$billingGroupCount = $billingGroups.Count
$accountCount = $accountCodings.Count
$ministryCount = $ministryNames.Count

# Write counts to console
Write-Host "Deduplicated counts:"
Write-Host "  billing_groups : $billingGroupCount"
Write-Host "  account_codings: $accountCount"
Write-Host "  ministry_names : $ministryCount"

# Ensure output directory exists
if (-not (Test-Path $OutputDir)) {
    New-Item -ItemType Directory -Path $OutputDir | Out-Null
}

# force each to be an array, then convert to JSON
@($billingGroups   | Sort-Object) |
  ConvertTo-Json -Depth 1 |
    Out-File "$OutputDir\billing_groups.json"    -Encoding utf8

@($accountCodings  | Sort-Object) |
  ConvertTo-Json -Depth 1 |
    Out-File "$OutputDir\account_codings.json"  -Encoding utf8

@($ministryNames   | Sort-Object) |
  ConvertTo-Json -Depth 1 |
    Out-File "$OutputDir\ministry_names.json"   -Encoding utf8

Write-Host "Extraction complete. Files written to '$OutputDir':"
Write-Host "  - billing_groups.json"
Write-Host "  - account_codings.json"
Write-Host "  - ministry_names.json"