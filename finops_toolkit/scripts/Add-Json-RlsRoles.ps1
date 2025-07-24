<#
.SYNOPSIS
  Upserts static RLS roles into an open, non-store Power BI Desktop model from JSON inputs.
#>

param(
  [string] $BillingGroupsFile  = "./billing_groups.json",
  [string] $AccountCodingsFile = "./account_codings.json",
  [string] $MinistryNamesFile  = "./ministry_names.json",
  [string] $ModelTable         = "Costs",
  [string] $TomDllPath         = "C:\Program Files (x86)\Microsoft SQL Server\130\SDK\Assemblies\Microsoft.AnalysisServices.Tabular.dll"
)

# 1) Windows guard
if (-not ([System.Environment]::OSVersion.Platform -eq [System.PlatformID]::Win32NT)) {
  Write-Error "This script must run on Windows PowerShell."
  exit 1
}

# 2) Ensure TOM is present (NuGet fallback)
function Ensure-TomDll {
  param([string] $Path)

  if (Test-Path $Path) {
    Write-Host "[OK] TOM DLL found at $Path"
    return
  }
  $folder = Split-Path $Path -Parent
  New-Item -ItemType Directory -Path $folder -Force | Out-Null

  Write-Host "[INFO] Downloading TOM from NuGet…"
  $url = "https://www.nuget.org/api/v2/package/Microsoft.AnalysisServices.Tabular/19.61.1"
  $nupkg = Join-Path $folder "TOM.nupkg"
  Invoke-WebRequest -Uri $url -OutFile $nupkg -UseBasicParsing

  Add-Type -AssemblyName System.IO.Compression.FileSystem
  [System.IO.Compression.ZipFile]::ExtractToDirectory($nupkg, "$folder\nupkg")

  $dll = Get-ChildItem "$folder\nupkg" -Recurse -Filter "Microsoft.AnalysisServices.Tabular.dll" |
         Sort LastWriteTime -Descending | Select-Object -First 1
  if (-not $dll) { throw "TOM DLL not found in NuGet package." }

  Copy-Item $dll.FullName -Destination $Path -Force
  Write-Host "[OK] Extracted TOM DLL to $Path"
}

# 3) Locate the classic msmdsrv.exe and pull its TCP port
function Get-ClassicPbiPort {
  # Find any msmdsrv.exe whose path includes Power BI Desktop but not WindowsApps
  $procs = Get-CimInstance Win32_Process -Filter "Name='msmdsrv.exe'"
  foreach ($p in $procs) {
    $path = $p.ExecutablePath
    if ($path -and $path -match 'Power BI Desktop' -and $path -notmatch 'WindowsApps') {
      # Pull the port=#### from its command line
      if ($p.CommandLine -match 'port=(\d+)') {
        Write-Host "[OK] Found classic PBI on port $($Matches[1]) (exe: $path)"
        return $Matches[1]
      }
    }
  }
  return $null
}


# 4) Role upsert helper
function Upsert-Role {
  param(
    [Microsoft.AnalysisServices.Tabular.Model] $Model,
    [string] $TableName,
    [string] $ColumnName,
    [string] $Value,
    [string] $Prefix
  )
  $safe     = $Value -replace '[^A-Za-z0-9_]','_'
  $roleName = "$Prefix`_$safe"
  $role     = $Model.Roles.Find($roleName)
  if (-not $role) {
    Write-Host "[ADD]    $roleName"
    $role = [Microsoft.AnalysisServices.Tabular.Role]::new($roleName)
    $Model.Roles.Add($role)
  } else {
    Write-Host "[UPD]    $roleName"
  }
  $expr = "[${ColumnName}] IN {`"$Value`"}"
  Write-Host "         filter: $expr"
  $role.TablePermissions[$TableName].FilterExpression = $expr
}

# 5) Bootstrap TOM
Ensure-TomDll -Path $TomDllPath
Add-Type -Path $TomDllPath

# 6) Connect via TCP port only
$port = Get-ClassicPbiPort
if (-not $port) {
  throw "Could not find a classic (non-store) PBI Desktop instance. Close the Store app version and open the MSI/EXE build."
}

$cs = "Provider=MSOLAP;Data Source=localhost:$port;Initial Catalog=Model;Integrated Security=SSPI;"
Write-Host "[INFO] Connecting:`n  $cs"
$server = [Microsoft.AnalysisServices.Tabular.Server]::new()
try {
  $server.Connect($cs)
  Write-Host "[OK] Connected on port $port."
} catch {
  throw "Connection failed: $($_.Exception.Message)"
}

$db    = $server.Databases["Model"]
$model = $db.Model
if (-not $model) { throw "In-memory model not found." }

# 7) Read JSON and upsert
Write-Host "`n➤ Applying RLS roles…"
$bgList = Get-Content $BillingGroupsFile  | ConvertFrom-Json
$acList = Get-Content $AccountCodingsFile | ConvertFrom-Json
$mnList = Get-Content $MinistryNamesFile  | ConvertFrom-Json

foreach ($bg in $bgList) { Upsert-Role -Model $model -TableName $ModelTable -ColumnName "tag_billing_group"  -Value $bg -Prefix "BG" }
foreach ($ac in $acList) { Upsert-Role -Model $model -TableName $ModelTable -ColumnName "tag_account_coding" -Value $ac -Prefix "AC" }
foreach ($mn in $mnList) { Upsert-Role -Model $model -TableName $ModelTable -ColumnName "tag_ministry_name"  -Value $mn -Prefix "MN" }

# 8) Save & exit
$model.SaveChanges()
$server.Disconnect()
Write-Host "`n[DONE] RLS roles applied successfully."