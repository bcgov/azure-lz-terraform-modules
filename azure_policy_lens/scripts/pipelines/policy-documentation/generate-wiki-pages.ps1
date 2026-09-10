using module ../../../ps_modules/AzPolicyLens.Wiki/AzPolicyLens.Wiki.psd1
<#
=================================================================================================================
AUTHOR: Tao Yang
DATE: 14/01/2026
NAME: generate-wiki-pages.ps1
VERSION: 2.0.0
COMMENT: Generate ADO or GitHub Wiki pages for Azure Policy documentation based on environment discovery results.
=================================================================================================================
#>
[CmdletBinding()]
[OutputType([hashtable])]
param (
  [parameter(Mandatory = $true, HelpMessage = 'Json discovery data file path')]
  [ValidateScript({ Test-Path $_ -PathType 'leaf' })]
  [string]$DiscoveryFilePath,

  [parameter(Mandatory = $true, HelpMessage = 'Base Output Path')]
  [ValidateScript({ Test-Path $_ -PathType 'Container' })]
  [string]$BaseOutputPath,

  [parameter(Mandatory = $true, HelpMessage = 'Wiki alias')]
  [ValidateNotNullOrEmpty()]
  [string]$wikiAlias,

  [parameter(Mandatory = $true, HelpMessage = 'Page Style')]
  [ValidateSet("detailed", "basic")]
  [string]$pageStyle,

  [parameter(Mandatory = $true, HelpMessage = 'Git Platform')]
  [ValidateSet("ado", "github")]
  [string]$gitPlatform,

  [parameter(Mandatory = $true, HelpMessage = 'Git branch to push the wiki pages to.')]
  [ValidateNotNullOrEmpty()]
  [string]$gitBranch,

  [parameter(Mandatory = $false, HelpMessage = 'Path within the git repository where the wiki pages will be stored. Only Required for Azure DevOps Wiki.')]
  [ValidateNotNullOrEmpty()]
  [string]$gitRepoPath = "docs",

  [parameter(Mandatory = $false, HelpMessage = 'Git commit message.')]
  [string]$gitCommitMessage = '',

  [parameter(Mandatory = $false, HelpMessage = 'Subscription ID to filter the discovery data.')]
  [string]$SubscriptionIds,

  [parameter(Mandatory = $false, HelpMessage = 'Child management group ID to filter the discovery data.')]
  [string]$childManagementGroupId,

  [parameter(Mandatory = $true, HelpMessage = 'The warning days for the expiration of the policy exemption.')]
  [ValidateRange(7, 90)]
  [int]$ExemptionExpiresOnWarningDays,

  [parameter(Mandatory = $true, HelpMessage = 'The warning percentage threshold for policy compliance summary.')]
  [ValidateRange(1, 99)]
  [int]$ComplianceWarningPercentageThreshold,

  [parameter(Mandatory = $false, HelpMessage = 'The maximum number of concurrent wiki page writes to use during generation.')]
  [ValidateRange(1, 64)]
  [int]$WriteThrottleLimit = 8,

  [parameter(Mandatory = $false, HelpMessage = 'The directory contains custom security control definitions.')]
  [ValidateScript({ Test-Path $_ -PathType 'Container' })]
  [string]$CustomSecurityControlPath,

  [parameter(Mandatory = $true, HelpMessage = 'The title of the wiki.')]
  [ValidateNotNullOrEmpty()]
  [string]$Title
)

$ErrorActionPreference = 'Stop'

$normalizedSubscriptionIds = if ([string]::IsNullOrWhiteSpace($SubscriptionIds)) { '' } else { $SubscriptionIds.Trim() }
$normalizedChildManagementGroupId = if ([string]::IsNullOrWhiteSpace($childManagementGroupId)) { '' } else { $childManagementGroupId.Trim() }
$normalizedCustomSecurityControlPath = if ([string]::IsNullOrWhiteSpace($CustomSecurityControlPath)) { '' } else { $CustomSecurityControlPath.Trim() }

function Format-GenerateWikiElapsedTime {
  param (
    [Parameter(Mandatory = $true)]
    [TimeSpan]$Duration
  )

  if ($Duration.TotalHours -ge 1) {
    return [string]::Format('{0:hh\:mm\:ss\.fff}', $Duration)
  }

  return [string]::Format('{0:mm\:ss\.fff}', $Duration)
}

function Invoke-GenerateWikiTimedOperation {
  param (
    [Parameter(Mandatory = $true)]
    [string]$Name,

    [Parameter(Mandatory = $true)]
    [scriptblock]$Operation,

    [Parameter(Mandatory = $true)]
    [hashtable]$Metrics
  )

  $stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
  try {
    $result = & $Operation
  } finally {
    $stopwatch.Stop()
    $Metrics[$Name] = [ordered]@{
      Duration     = Format-GenerateWikiElapsedTime -Duration $stopwatch.Elapsed
      Seconds      = [Math]::Round($stopwatch.Elapsed.TotalSeconds, 2)
      Milliseconds = [Math]::Round($stopwatch.Elapsed.TotalMilliseconds, 2)
    }
    Write-Output "Phase '$Name' completed in $($Metrics[$Name].Duration)."
  }

  return $result
}

function Write-GenerateWikiTimingSummary {
  param (
    [Parameter(Mandatory = $true)]
    [hashtable]$Metrics
  )

  Write-Output 'Timing summary for Generate Wiki script:'
  foreach ($name in $Metrics.Keys) {
    Write-Output ("  - {0}: duration={1}" -f $name, $Metrics[$name].Duration)
  }
}

$scriptPhaseMetrics = [ordered]@{}
$scriptStopwatch = [System.Diagnostics.Stopwatch]::StartNew()

#region main
if ($gitPlatform -eq 'ado') {
  Write-Verbose "Git platform is set to 'ado'." -Verbose
  $gitToken = $env:SYSTEM_ACCESSTOKEN
  $tokenType = "bearer"
} else {
  Write-Verbose "Git platform is set to 'github'." -Verbose
  $githubToken = $env:githubToken
  $githubUserID = $env:githubUserID
  $tokenType = "basic"
  $gitTokenBytes = [System.Text.Encoding]::ASCII.GetBytes("$githubUserID`:$githubToken")
  $gitToken = [Convert]::ToBase64String($gitTokenBytes)
}

$EncryptionKey = $env:EncryptionKey
$EncryptionIV = $env:EncryptionIV
$gitRepository = $env:gitRepository
$gitUserName = $env:gitUserName
$gitUserEmail = $env:gitUserEmail
$gitNetworkArgs = @(
  '-c', 'credential.helper=',
  '-c', 'credential.interactive=never',
  '-c', 'http.lowSpeedLimit=1000',
  '-c', 'http.lowSpeedTime=30'
)
Write-Output "Starting the wiki page generation script."
Write-Output "The following parameters were provided:"
Write-Output "  - DiscoveryFilePath: $DiscoveryFilePath"
Write-Output "  - BaseOutputPath: $BaseOutputPath"
Write-Output "  - wikiAlias: $wikiAlias"
Write-Output "  - gitRepository: $gitRepository"
Write-Output "  - gitBranch: $gitBranch"
if ($gitPlatform -eq 'ado') {
  Write-Output "  - gitRepoPath: $gitRepoPath"
}
Write-Output "  - WriteThrottleLimit: $WriteThrottleLimit"
Write-Output "  - GitHub User ID: $githubUserID"
if (-not [string]::IsNullOrWhiteSpace($normalizedSubscriptionIds)) {
  Write-Output "  - SubscriptionIds: $normalizedSubscriptionIds"
} else {
  Write-Output "  - SubscriptionIds: None"
}
if (-not [string]::IsNullOrWhiteSpace($normalizedChildManagementGroupId)) {
  Write-Output "  - childManagementGroupId: $normalizedChildManagementGroupId"
} else {
  Write-Output "  - childManagementGroupId not specified."
}
Write-Output "  - Title: $Title"
Write-Output "  - EncryptionKey: $($EncryptionKey -replace '.', '*')"
Write-Output "  - EncryptionIV: $($EncryptionIV -replace '.', '*')"
if ($gitCommitMessage) {
  Write-Output "  - gitCommitMessage: $gitCommitMessage"
} else {
  $strNow = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
  $gitCommitMessage = "Update wiki pages with latest Azure Policy documentation - '$strNow'"
  Write-Output "  - gitCommitMessage: $gitCommitMessage"
}
#Construct the path where the wiki pages will be created.
$OutputPath = Join-Path -Path $BaseOutputPath -ChildPath $wikiAlias

#Ensure the output path exists.
if (-not (Test-Path -Path $OutputPath -PathType 'Container')) {
  Write-Verbose "Creating output path '$OutputPath'." -Verbose
  New-Item -Path $OutputPath -ItemType Directory | Out-Null
} else {
  Write-Verbose "The output path '$OutputPath' already exists." -Verbose
}


#clone the git repository if provided
$gitRepoRootPath = Join-Path -Path $OutputPath -ChildPath 'repo'
if (-not (Test-Path -Path $gitRepoRootPath -PathType 'Container')) {
  $resolvedGitBranch = $gitBranch
  if ($gitPlatform -ieq 'ado') {
    Write-Output "Cloning the Git repo using http.extraheader for authentication with $tokenType token."
    git @gitNetworkArgs -c http.extraheader="AUTHORIZATION: $tokenType $gitToken" clone $gitRepository $gitRepoRootPath --branch $resolvedGitBranch --single-branch --depth 1
    if ($LASTEXITCODE -ne 0) {
      Throw "Failed to clone repository '$gitRepository' using branch '$resolvedGitBranch'."
    }
  } else {
    $branchExists = git @gitNetworkArgs -c http.extraheader="AUTHORIZATION: basic $gitToken" ls-remote --heads $gitRepository $resolvedGitBranch
    if ($LASTEXITCODE -ne 0) {
      Throw "Failed to query repository '$gitRepository' for branch '$resolvedGitBranch'."
    }

    if ([string]::IsNullOrWhiteSpace($branchExists)) {
      $headSymref = git @gitNetworkArgs -c http.extraheader="AUTHORIZATION: basic $gitToken" ls-remote --symref $gitRepository HEAD
      if ($LASTEXITCODE -ne 0) {
        Throw "Failed to determine default branch for repository '$gitRepository'."
      }

      $headRefLine = $headSymref | Where-Object { $_ -match '^ref:\s+refs/heads/' } | Select-Object -First 1
      if ($headRefLine) {
        $resolvedGitBranch = (($headRefLine -split '\s+')[1] -replace '^refs/heads/', '')
        Write-Warning "Configured branch '$gitBranch' was not found in '$gitRepository'. Falling back to default branch '$resolvedGitBranch'."
      } else {
        Throw "Configured branch '$gitBranch' was not found and default branch could not be determined for '$gitRepository'."
      }
    }

    Write-Output "Cloning the Git repo using http.extraheader for authentication."
    git @gitNetworkArgs -c http.extraheader="AUTHORIZATION: basic $gitToken" clone $gitRepository $gitRepoRootPath --branch $resolvedGitBranch --single-branch --depth 1
    if ($LASTEXITCODE -ne 0) {
      Throw "Failed to clone repository '$gitRepository' using branch '$resolvedGitBranch'."
    }
  }

  $gitBranch = $resolvedGitBranch
  if ($gitPlatform -ieq 'ado') {
    #make sure the child path $gitRepoPath exists
    $gitRepoFullPath = Join-Path -Path $gitRepoRootPath -ChildPath $gitRepoPath
    if (-not (Test-Path -Path $gitRepoFullPath -PathType 'Container')) {
      Write-Verbose "Creating the documentation sub directory '$gitRepoFullPath'." -Verbose
      New-Item -Path $gitRepoFullPath -ItemType Directory -Force | Out-Null
    } else {
      Write-Verbose "The the documentation sub directory '$gitRepoFullPath' already exists." -Verbose
    }
  } else {
    #Github wiki does not support sub directories. It has to use a flat structure where all files are stored in the root of the wiki repository.
    $gitRepoFullPath = $gitRepoRootPath
  }
} else {
  Write-Warning "Git repository path '$gitRepoRootPath' already exists. Reusing the existing clone."
  $resolvedGitBranch = $gitBranch
  if ($gitPlatform -ieq 'ado') {
    $gitRepoFullPath = Join-Path -Path $gitRepoRootPath -ChildPath $gitRepoPath
    if (-not (Test-Path -Path $gitRepoFullPath -PathType 'Container')) {
      Write-Verbose "Creating the documentation sub directory '$gitRepoFullPath'." -Verbose
      New-Item -Path $gitRepoFullPath -ItemType Directory -Force | Out-Null
    }
  } else {
    $gitRepoFullPath = $gitRepoRootPath
  }
}
#get the discovery data
$param = @{
  Title                                = $Title
  DiscoveryDataImportFilePath          = $DiscoveryFilePath
  BaseOutputPath                       = $gitRepoFullPath
  PageStyle                            = $pageStyle
  ExemptionExpiresOnWarningDays        = $ExemptionExpiresOnWarningDays
  ComplianceWarningPercentageThreshold = $ComplianceWarningPercentageThreshold
  WriteThrottleLimit                   = $WriteThrottleLimit
  WikiStyle                            = $gitPlatform
}
if (-not [string]::IsNullOrEmpty($EncryptionKey) -and -not [string]::IsNullOrEmpty($EncryptionIV)) {
  $param['EncryptionKey'] = $EncryptionKey
  $param['EncryptionIV'] = $EncryptionIV
}
Write-Verbose "The discovery data file path is '$($DiscoveryFilePath)'." -Verbose
Write-Verbose "The output path is '$($OutputPath)'." -Verbose
Write-Verbose "The wiki title is '$($Title)'." -Verbose

if (-not [string]::IsNullOrWhiteSpace($normalizedSubscriptionIds)) {
  $arrSubscriptionIds = $normalizedSubscriptionIds.split(',')
  $param.add('SubscriptionIds', $arrSubscriptionIds)
  Write-Output "Creating $pageStyle style wiki pages for subscriptions '$normalizedSubscriptionIds'."
} elseif (-not [string]::IsNullOrWhiteSpace($normalizedChildManagementGroupId)) {
  $param.add('childManagementGroupId', $normalizedChildManagementGroupId)
  Write-Output "Creating $pageStyle style wiki pages for child management group '$normalizedChildManagementGroupId'."
} else {
  Write-Verbose "No SubscriptionIds or childManagementGroupId provided. The wiki pages will be generated based on the entire discovery data without filtering." -Verbose
  Write-Output "Creating $pageStyle style wiki pages for all subscriptions."
}

if (-not [string]::IsNullOrWhiteSpace($normalizedCustomSecurityControlPath)) {
  $param.add('CustomSecurityControlPath', $normalizedCustomSecurityControlPath)
  Write-Verbose "Custom security control path provided: '$normalizedCustomSecurityControlPath'." -Verbose
}
Write-Verbose "Generating wiki pages with the following parameters:" -Verbose
foreach ($key in $param.Keys) {
  if ($key -in @('EncryptionKey', 'EncryptionIV')) {
    Write-Verbose "  - $key`: $($param[$key] -replace '.', '*')" -Verbose
  } else {
    Write-Verbose "  - $key`: $($param[$key])" -Verbose
  }
}
Invoke-GenerateWikiTimedOperation -Name 'Generate wiki documentation' -Metrics $scriptPhaseMetrics -Operation {
  New-AzplDocumentation @param -ErrorAction Stop
} | Out-Null

#Push the changes to the git repository
Write-Verbose "Preparing to push changes to the git repository." -Verbose
#set the current location to the git repository root path
Write-Output "Setting current location to git repository root path '$gitRepoRootPath'."
Set-Location -Path $gitRepoRootPath
Write-Output "Files and folders contained in the '$gitRepoRootPath':"
Get-ChildItem $gitRepoRootPath -force | format-table Mode, LastWriteTIme, Length, Name
$gitStatus = git status --porcelain
if ($gitStatus) {
  Invoke-GenerateWikiTimedOperation -Name 'Commit and push wiki changes' -Metrics $scriptPhaseMetrics -Operation {
    Write-Verbose "Changes detected in the git repository. Preparing to commit and push." -Verbose
    Write-Verbose "Configure git user name using command 'git config user.name `"$gitUserName`"'" -Verbose
    git config user.name "$gitUserName"

    Write-Verbose "Configure git user email using command 'git config user.email `"$gitUserEmail`"'" -Verbose
    git config user.email "$gitUserEmail"

    Write-Verbose "Configure git rebase" -Verbose
    git config pull.rebase false

    Write-Verbose "Adding changes to git staging area." -Verbose
    git add .
    git commit -m "$gitCommitMessage"
    if ($gitPlatform -eq 'ado') {
      Write-Output "Pushing changes to the $gitBranch branch of the repository '$gitRepository' using http.extraheader for authentication with $tokenType token."
      git @gitNetworkArgs -c http.extraheader="AUTHORIZATION: bearer $gitToken" push origin $gitBranch --porcelain
    } else {
      Write-Output "Pushing changes to the $gitBranch branch of the repository '$gitRepository' using http.extraheader for authentication."
      git @gitNetworkArgs -c http.extraheader="AUTHORIZATION: basic $gitToken" push origin $gitBranch --porcelain
    }

    if ($LASTEXITCODE -ne 0) {
      Write-Error "Failed to push to the $gitBranch branch of the repository '$gitRepository'."
      exit 1
    }
  } | Out-Null
} else {
  Write-Verbose "No changes detected in the git repository. No commit or push needed." -Verbose
}

$scriptStopwatch.Stop()
Write-Output "Generate Wiki script completed in $(Format-GenerateWikiElapsedTime -Duration $scriptStopwatch.Elapsed)."
Write-GenerateWikiTimingSummary -Metrics $scriptPhaseMetrics

#endregion
