<#
.SYNOPSIS
  Extract a PBIX offline, inject RLS roles into TMDL files, and rebuild the PBIX via pbi-tools.

.DESCRIPTION
  Uses pbi-tools’ default TMDL extraction to produce one .tmdl per role under Model/roles.
  This script overwrites or creates those .tmdl files based on three JSON arrays, then rebuilds.

.PARAMETER InputPbix
  Path to the source .pbix file.

.PARAMETER OutputPbix
  Path where the updated .pbix should be emitted.

.PARAMETER BillingGroupsFile
  JSON file containing billing group strings.

.PARAMETER AccountCodingsFile
  JSON file containing account coding strings.

.PARAMETER MinistryNamesFile
  JSON file containing ministry name strings.

.PARAMETER ProjectFolder
  Folder for the intermediate pbi-tools extract; defaults to “ProjectExtract” next to this script.
#>

param(
  [Parameter(Mandatory=$true)]
  [string] $InputPbix,

  [Parameter(Mandatory=$false)]
  [string] $OutputFolder = "$PSScriptRoot\UpdatedReports",

  [Parameter(Mandatory=$false)]
  [string] $OutputBaseName,

  [string] $BillingGroupsFile   = ".\billing_groups.json",
  [string] $AccountCodingsFile  = ".\account_codings.json",
  [string] $MinistryNamesFile   = ".\ministry_names.json",

  [string] $ProjectFolder       = "$PSScriptRoot\ProjectExtract"
)

# Ensure pbi-tools is on PATH
if (-not (Get-Command pbi-tools -ErrorAction SilentlyContinue)) {
    throw "pbi-tools CLI not found. Install with: dotnet tool install -g pbi-tools"
}

# Resolve full paths
$inputPath  = (Resolve-Path $InputPbix   ).Path
# $outputPath = (Resolve-Path $OutputPbix  ).Path
$bgPath     = (Resolve-Path $BillingGroupsFile  ).Path
$acPath     = (Resolve-Path $AccountCodingsFile ).Path
$mnPath     = (Resolve-Path $MinistryNamesFile  ).Path

# Determine the base name (no extension)
if (-not $OutputBaseName) {
  $OutputBaseName = [IO.Path]::GetFileNameWithoutExtension($inputPath)
}

# Create timestamp
$timeStamp = Get-Date -Format 'yyyyMMdd_HHmmss'

# Build output folder & file name
if (-not (Test-Path $OutputFolder)) {
  New-Item -ItemType Directory -Path $OutputFolder -Force | Out-Null
}

$outputName = "${OutputBaseName}_${timeStamp}.pbix"
$outputPath = Join-Path $OutputFolder $outputName

Write-Host "`n[INFO] Input PBIX: $inputPath"
Write-Host "[INFO] Output will be: $outputPath`n"

Write-Host "`n[STEP 1] Extracting PBIX offline to:`n  $ProjectFolder`n"
# Offline extract (default TMDL)
$pbiArgs = @(
  'extract'
  '-pbixPath'
  $inputPath
  '-extractFolder'
  $ProjectFolder
)

Write-Host "[CMD] pbi-tools $($pbiArgs -join ' ')`n"
& pbi-tools @pbiArgs
if ($LASTEXITCODE -ne 0) {
    throw "pbi-tools extract failed (exit code $LASTEXITCODE)."
}
Write-Host "[OK] Extraction complete.`n"

# Locate the roles folder
$rolesFolder = Join-Path $ProjectFolder 'Model\roles'
if (-not (Test-Path $rolesFolder)) {
    throw "Roles folder not found at: $rolesFolder"
}

Write-Host "[STEP 2] Patching TMDL role files in:`n  $rolesFolder`n"

# Load JSON arrays
$billingGroups  = Get-Content $bgPath  | ConvertFrom-Json
$accountCodings = Get-Content $acPath | ConvertFrom-Json
$ministryNames  = Get-Content $mnPath  | ConvertFrom-Json

# 1) Read existing .tmdl files and parse their 'name' values
$existingRoles = @()
Get-ChildItem $rolesFolder -Filter '*.tmdl' | ForEach-Object {
    try {
        $t = Get-Content $_.FullName -Raw | ConvertFrom-Json
        if ($t.name) { $existingRoles += $t.name }
    }
    catch {
        Write-Host "[WARN] Could not parse JSON in $($_.Name): $($_.Exception.Message)"
    }
}
# Deduplicate
$existingRoles = $existingRoles | Sort-Object -Unique

# 2) Define helper to write only if new
function Write-RoleIfNew {
    param(
        [string] $Prefix,
        [string] $Table,
        [string] $Column,
        [string] $Value
    )

    # Build safe names
    $safe     = ($Value -replace '[^A-Za-z0-9_]','_')
    $roleName = "$Prefix`_$safe"
    $fileName = [Uri]::EscapeDataString($roleName) + '.tmdl'
    $fullPath = Join-Path $rolesFolder $fileName

    if ($existingRoles -contains $roleName) {
        Write-Host "[SKIP] $roleName already exists."
        return
    }

    # Create the TMDL DSL block
    $dsl = @"
role '$roleName'
    modelPermission: read

    tablePermission $Table = [$Column] == "$Value"
"@

    # Write out as plain text
    $dsl | Set-Content -Path $fullPath -Encoding Utf8NoBOM

    Write-Host "[WROTE] $fileName"

    # Track it so we don’t duplicate
    $existingRoles += $roleName
}


# Overwrite/create each role .tmdl
foreach ($bg in $billingGroups)  { Write-RoleIfNew 'BG' 'Costs' 'tag_billing_group'  $bg }
foreach ($ac in $accountCodings) { Write-RoleIfNew 'AC' 'Costs' 'tag_account_coding' $ac }
foreach ($mn in $ministryNames)  { Write-RoleIfNew 'MN' 'Costs' 'tag_ministry_name'  $mn }

Write-Host "`n[OK] All .tmdl role files patched.`n"

# ----------------------------
# At top: compute paths
# ----------------------------
# $inputPath  = (Resolve-Path $InputPbix).Path
# For output, construct the full path, but don't Resolve-Path
$outputDir  = Split-Path $outputPath -Parent
$outputName = Split-Path $outputPath -Leaf
# Ensure output directory exists
if (-not (Test-Path $outputDir)) { New-Item -ItemType Directory -Path $outputDir -Force | Out-Null }
$outputPath = Join-Path $outputDir $outputName

# -----------------------------------------------
# STEP 3: Compile PBIX (preferring pbi-tools.core)
# -----------------------------------------------

Write-Host "`n[STEP 3] Compiling PBIX to:`n  $outputPath`n"

# Decide which CLI to call
# NOTE: Must ust pbi-tools.core for compile, per https://github.com/pbi-tools/pbi-tools/issues/388
# NOTE: Must be a PBIT format as a data model is not supported in PBIX format
if (Get-Command pbi-tools.core -ErrorAction SilentlyContinue) {
    $cli        = 'pbi-tools.core'
    $cliArgs    = @(
        'compile'      # subcommand
        $ProjectFolder # extracted folder
        $outputPath    # target PBIX path
        'PBIT'         # format
        'true'         # overwrite if exists
    )
}
elseif (Get-Command pbi-tools -ErrorAction SilentlyContinue) {
    $cli     = 'pbi-tools'
    $cliArgs = @(
        'compile'
        $ProjectFolder
        $outputPath
        'PBIT'
        'true'
    )
}
else {
    throw "Neither 'pbi-tools.core' nor 'pbi-tools' CLI was found. Install one of them and retry."
}

# Show & invoke
Write-Host "[CMD] $cli $($cliArgs -join ' ')`n"
& $cli @cliArgs

if ($LASTEXITCODE -ne 0) {
    throw "Compile failed (exit code $LASTEXITCODE)."
}

Write-Host "`n✅ Done! Updated PBIX written to:`n  $outputPath`n"