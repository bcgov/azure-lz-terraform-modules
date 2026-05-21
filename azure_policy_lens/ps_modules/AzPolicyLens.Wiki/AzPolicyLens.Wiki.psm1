using module ./AzPolicyLens.Wiki.Azure.Helper.psm1
using module ./AzPolicyLens.Wiki.Encryption.Helper.psm1
using module ./AzPolicyLens.Wiki.Generic.Helper.psm1
using module ./AzPolicyLens.Wiki.Markdown.Helper.psm1
using module ./AzPolicyLens.Wiki.Pages.Helper.psm1
using module ./AzPolicyLens.Wiki.Platform.Helper.psm1
using module ./AzPolicyLens.Wiki.Utility.Helper.psm1

#region function to import previously exported environment details
Function Import-AzplEnvironmentDiscovery {
  [CmdletBinding()]
  [OutputType([System.Collections.Specialized.OrderedDictionary])]
  param (
    [parameter(Mandatory = $true, ParameterSetName = 'EncryptionViaKeyFile', HelpMessage = 'File path for the Environment Data to import')]
    [parameter(Mandatory = $true, ParameterSetName = 'EncryptionViaKeyText', HelpMessage = 'File path for the Environment Data to import')]
    [parameter(Mandatory = $true, ParameterSetName = 'NoEncryption', HelpMessage = 'File path for the Environment Data to import')]
    [ValidateScript({ Test-Path -Path $_ -PathType 'Leaf' })]
    [string]$FilePath,

    [parameter(Mandatory = $true, ParameterSetName = 'EncryptionViaKeyFile', HelpMessage = 'AES Encryption key file path. Use the same key to decrypt the file if it is encrypted.')]
    [ValidateNotNullOrEmpty()]
    [string]$EncryptionKeyFilePath,

    [parameter(Mandatory = $true, ParameterSetName = 'EncryptionViaKeyText', HelpMessage = 'AES Encryption Key Content.')]
    [ValidateNotNullOrEmpty()]
    [string]$EncryptionKey,

    [parameter(Mandatory = $true, ParameterSetName = 'EncryptionViaKeyText', HelpMessage = 'AES Encryption Initialization Vector (IV) Content.')]
    [ValidateNotNullOrEmpty()]
    [string]$EncryptionIV
  )
  #Discovery Data File names
  $hierarchyFileName = 'managementGroupHierarchy.json'
  $policyAssignmentFileName = 'policyAssignments.json'
  $policyInitiativeFileName = 'policyInitiatives.json'
  $policyDefinitionFileName = 'policyDefinitions.json'
  $policyExemptionFileName = 'policyExemptions.json'
  $policyMetadataFileName = 'policyMetadata.json'
  $complianceDataFileName = 'complianceData.json'

  $objFile = Get-Item $FilePath
  if ($objFile.Extension -ieq '.zip') {
    Write-Verbose "[$(getCurrentUTCString)]: Expanding the ZIP archive '$($objFile.FullName)'."
    Expand-Archive -Path $objFile.FullName -DestinationPath (Split-Path -Path $objFile.FullName -Parent) -Force
    $hierarchyFileFullPath = (Join-Path -Path (Split-Path -Path $objFile.FullName -Parent) -ChildPath $hierarchyFileName)
    $policyAssignmentFileFullPath = (Join-Path -Path (Split-Path -Path $objFile.FullName -Parent) -ChildPath $policyAssignmentFileName)
    $policyInitiativeFileFullPath = (Join-Path -Path (Split-Path -Path $objFile.FullName -Parent) -ChildPath $policyInitiativeFileName)
    $policyDefinitionFileFullPath = (Join-Path -Path (Split-Path -Path $objFile.FullName -Parent) -ChildPath $policyDefinitionFileName)
    $policyExemptionFileFullPath = (Join-Path -Path (Split-Path -Path $objFile.FullName -Parent) -ChildPath $policyExemptionFileName)
    $policyMetadataFileFullPath = (Join-Path -Path (Split-Path -Path $objFile.FullName -Parent) -ChildPath $policyMetadataFileName)
    $complianceDataFileFullPath = (Join-Path -Path (Split-Path -Path $objFile.FullName -Parent) -ChildPath $complianceDataFileName)
    $removeExtractedFile = $true
  } else {
    Throw "Unsupported file format '$($objFile.Extension)'. Only .zip files are supported for environment details import."
  }

  try {
    if ($($PSCmdlet.ParameterSetName) -eq 'EncryptionViaKeyFile') {
      Write-Verbose "[$(getCurrentUTCString)]: Decrypting the environment details using the encryption key file '$EncryptionKeyFilePath'." -Verbose
      $hierarchyDetails = decryptStuff -InputFilePath $hierarchyFileFullPath -KeyFilePath $EncryptionKeyFilePath | ConvertFrom-Json -depth 100
      $policyAssignmentDetails = decryptStuff -InputFilePath $policyAssignmentFileFullPath -KeyFilePath $EncryptionKeyFilePath | ConvertFrom-Json -depth 100
      $policyInitiativeDetails = decryptStuff -InputFilePath $policyInitiativeFileFullPath -KeyFilePath $EncryptionKeyFilePath | ConvertFrom-Json -depth 100
      $policyDefinitionDetails = decryptStuff -InputFilePath $policyDefinitionFileFullPath -KeyFilePath $EncryptionKeyFilePath | ConvertFrom-Json -depth 100
      $policyExemptionDetails = decryptStuff -InputFilePath $policyExemptionFileFullPath -KeyFilePath $EncryptionKeyFilePath | ConvertFrom-Json -depth 100
      $policyMetadataDetails = decryptStuff -InputFilePath $policyMetadataFileFullPath -KeyFilePath $EncryptionKeyFilePath | ConvertFrom-Json -depth 100
      $complianceDataDetails = decryptStuff -InputFilePath $complianceDataFileFullPath -KeyFilePath $EncryptionKeyFilePath | ConvertFrom-Json -depth 100

    } elseif ($($PSCmdlet.ParameterSetName) -ieq 'EncryptionViaKeyText') {
      Write-Verbose "[$(getCurrentUTCString)]: Decrypting the environment details using the encryption key and IV text." -Verbose
      $hierarchyDetails = decryptStuff -InputFilePath $hierarchyFileFullPath -AESKey $EncryptionKey -AESIV $EncryptionIV | ConvertFrom-Json -depth 100
      $policyAssignmentDetails = decryptStuff -InputFilePath $policyAssignmentFileFullPath -AESKey $EncryptionKey -AESIV $EncryptionIV | ConvertFrom-Json -depth 100
      $policyInitiativeDetails = decryptStuff -InputFilePath $policyInitiativeFileFullPath -AESKey $EncryptionKey -AESIV $EncryptionIV | ConvertFrom-Json -depth 100
      $policyDefinitionDetails = decryptStuff -InputFilePath $policyDefinitionFileFullPath -AESKey $EncryptionKey -AESIV $EncryptionIV | ConvertFrom-Json -depth 100
      $policyExemptionDetails = decryptStuff -InputFilePath $policyExemptionFileFullPath -AESKey $EncryptionKey -AESIV $EncryptionIV | ConvertFrom-Json -depth 100
      $policyMetadataDetails = decryptStuff -InputFilePath $policyMetadataFileFullPath -AESKey $EncryptionKey -AESIV $EncryptionIV | ConvertFrom-Json -depth 100
      $complianceDataDetails = decryptStuff -InputFilePath $complianceDataFileFullPath -AESKey $EncryptionKey -AESIV $EncryptionIV | ConvertFrom-Json -depth 100
    } else {
      Write-Verbose "[$(getCurrentUTCString)]: Importing the environment details from the file '$FilePath' as plain-text." -Verbose
      $hierarchyDetails = Get-Content $hierarchyFileFullPath -Raw | ConvertFrom-Json -depth 100
      $policyAssignmentDetails = Get-Content $policyAssignmentFileFullPath -Raw | ConvertFrom-Json -depth 100
      $policyInitiativeDetails = Get-Content $policyInitiativeFileFullPath -Raw | ConvertFrom-Json -depth 100
      $policyDefinitionDetails = Get-Content $policyDefinitionFileFullPath -Raw | ConvertFrom-Json -depth 100
      $policyExemptionDetails = Get-Content $policyExemptionFileFullPath -Raw | ConvertFrom-Json -depth 100
      $policyMetadataDetails = Get-Content $policyMetadataFileFullPath -Raw | ConvertFrom-Json -depth 100
      $complianceDataDetails = Get-Content $complianceDataFileFullPath -Raw | ConvertFrom-Json -depth 100
    }

    # Extract the data from the output
    $hierarchyData = $hierarchyDetails
    $policyAssignmentData = $policyAssignmentDetails
    $policyInitiativeData = $policyInitiativeDetails
    $policyDefinitionData = $policyDefinitionDetails
    $policyExemptionData = $policyExemptionDetails
    $policyMetadataData = $policyMetadataDetails
    $complianceData = $complianceDataDetails

    Write-Verbose "[$(getCurrentUTCString)]: Environment Discovery Data Import." -verbose
    $AzplEnvironmentDetails = [ordered]@{
      timeStamp                                     = $hierarchyData.timeStamp
      topLevelManagementGroupName                   = $hierarchyData.topLevelManagementGroupName
      managementGroups                              = $hierarchyData.managementGroups
      subscriptions                                 = $hierarchyData.subscriptions
      assignments                                   = $policyAssignmentData.assignments
      initiatives                                   = $policyInitiativeData.initiatives
      definitions                                   = $policyDefinitionData.definitions
      exemptions                                    = $policyExemptionData.exemptions
      policyMetadata                                = $policyMetadataData.policyMetadata
      builtInDefinitionInUnAssignedCustomInitiative = $policyDefinitionData.builtInDefinitionInUnAssignedCustomInitiative
      assignmentCompliance                          = $complianceData.assignmentCompliance
      subscriptionComplianceSummary                 = $complianceData.subscriptionComplianceSummary
      complianceSummaryByPolicyDefinitionGroup      = $complianceData.complianceSummaryByPolicyDefinitionGroup
      additionalBuiltInPolicyMetadataConfig         = $policyMetadataData.additionalBuiltInPolicyMetadataConfig
      roleAssignments                               = $policyAssignmentData.roleAssignments
      roleDefinitions                               = $policyAssignmentData.roleDefinitions
    }


    Write-Verbose "[$(getCurrentUTCString)]: Imported environment details summary:" -Verbose
    Write-Verbose "  - Time Stamp (UTC): $($AzplEnvironmentDetails.timeStamp)" -Verbose
    Write-Verbose "  - Top Level Management Group Name: $($AzplEnvironmentDetails.topLevelManagementGroupName)" -Verbose
    Write-Verbose "  - Management Groups Count: $($AzplEnvironmentDetails.managementGroups.Count)" -Verbose
    Write-Verbose "  - Subscriptions Count: $($AzplEnvironmentDetails.subscriptions.Count)" -Verbose
    Write-Verbose "  - Assignments Count: $($AzplEnvironmentDetails.assignments.Count)" -Verbose
    Write-Verbose "  - Initiatives Count: $($AzplEnvironmentDetails.initiatives.Count)" -Verbose
    Write-Verbose "  - Definitions Count: $($AzplEnvironmentDetails.definitions.Count)" -Verbose
    Write-Verbose "  - Exemptions Count: $($AzplEnvironmentDetails.exemptions.Count)" -Verbose
    Write-Verbose "  - Policy Metadata Count: $($AzplEnvironmentDetails.policyMetadata.Count)" -Verbose
    Write-Verbose "  - Built-in Definition in Unassigned Custom Initiative Count: $($AzplEnvironmentDetails.builtInDefinitionInUnAssignedCustomInitiative.Count)" -Verbose
    Write-Verbose "  - Role Assignments Count: $($AzplEnvironmentDetails.roleAssignments.Count)" -Verbose
    Write-Verbose "  - Role Definitions Count: $($AzplEnvironmentDetails.roleDefinitions.Count)" -Verbose

  } catch {
    $ExceptionDetails = $_.Exception.Response.GetResponseStream()
    $reader = New-Object System.IO.StreamReader($ExceptionDetails)
    $ExceptionResponse = $reader.ReadToEnd();
    Write-Error $ExceptionResponse
    Write-Error $_.ErrorDetails
    throw $_.Exception
    $AzplEnvironmentDetails = [ordered]@{}
  }
  if ($removeExtractedFile) {
    Write-Verbose "[$(getCurrentUTCString)]: Removing the extracted file '$($hierarchyFileFullPath)'." -Verbose
    Remove-Item -Path $hierarchyFileFullPath -Force
    Write-Verbose "[$(getCurrentUTCString)]: Removing the extracted file '$($policyAssignmentFileFullPath)'." -Verbose
    Remove-Item -Path $policyAssignmentFileFullPath -Force
    Write-Verbose "[$(getCurrentUTCString)]: Removing the extracted file '$($policyInitiativeFileFullPath)'." -Verbose
    Remove-Item -Path $policyInitiativeFileFullPath -Force
    Write-Verbose "[$(getCurrentUTCString)]: Removing the extracted file '$($policyDefinitionFileFullPath)'." -Verbose
    Remove-Item -Path $policyDefinitionFileFullPath -Force
    Write-Verbose "[$(getCurrentUTCString)]: Removing the extracted file '$($policyExemptionFileFullPath)'." -Verbose
    Remove-Item -Path $policyExemptionFileFullPath -Force
    Write-Verbose "[$(getCurrentUTCString)]: Removing the extracted file '$($policyMetadataFileFullPath)'." -Verbose
    Remove-Item -Path $policyMetadataFileFullPath -Force
    Write-Verbose "[$(getCurrentUTCString)]: Removing the extracted file '$($complianceDataFileFullPath)'." -Verbose
    Remove-Item -Path $complianceDataFileFullPath -Force
  }

  $AzplEnvironmentDetails
}
#endregion

function Invoke-AzplConcurrentPageGeneration {
  [CmdletBinding()]
  [OutputType([hashtable])]
  param (
    [Parameter(Mandatory = $true)]
    [array]$Tasks,

    [Parameter(Mandatory = $true)]
    [string]$ModuleManifestPath
  )

  $results = [ordered]@{}
  $taskList = @($Tasks)
  if ($taskList.Count -eq 0) {
    return $results
  }

  $normalizedTasks = [System.Collections.Generic.List[object]]::new()
  $taskPosition = 0
  foreach ($task in $taskList) {
    $taskPosition++

    if ($null -eq $task) {
      throw "Concurrent task at index $taskPosition is null."
    }

    $taskName = [string]$task.Name
    if ([string]::IsNullOrWhiteSpace($taskName)) {
      throw "Concurrent task at index $taskPosition is missing Name."
    }

    $functionName = [string]$task.FunctionName
    if ([string]::IsNullOrWhiteSpace($functionName)) {
      throw "Concurrent task '$taskName' is missing FunctionName."
    }

    $parameters = $task.Parameters
    if ($null -eq $parameters) {
      $parameters = @{}
    }

    if ($parameters -is [System.Collections.Specialized.OrderedDictionary]) {
      $orderedParameters = @{}
      foreach ($key in $parameters.Keys) {
        $orderedParameters[$key] = $parameters[$key]
      }
      $parameters = $orderedParameters
    }

    if ($parameters -isnot [hashtable]) {
      throw "Concurrent task '$taskName' has invalid Parameters type '$($parameters.GetType().FullName)'. Expected Hashtable."
    }

    $normalizedTasks.Add([pscustomobject]@{
      Name         = $taskName
      FunctionName = $functionName
      Parameters   = $parameters
      Metadata     = $task.Metadata
    })
  }

  $taskList = @($normalizedTasks)

  if ($PSVersionTable.PSVersion.Major -lt 7 -or $taskList.Count -eq 1) {
    $module = Import-Module $ModuleManifestPath -Force -PassThru -ErrorAction Stop
    foreach ($task in $taskList) {
      $stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
      $functionName = $task.FunctionName
      $functionParameters = $task.Parameters
      $result = & $module {
        param($resolvedFunctionName, $resolvedParameters)

        if (-not (Get-Command -Name $resolvedFunctionName -ErrorAction SilentlyContinue)) {
          throw "Function '$resolvedFunctionName' is not available in module scope."
        }

        & $resolvedFunctionName @resolvedParameters
      } $functionName $functionParameters
      $stopwatch.Stop()
      $results[$task.Name] = [ordered]@{
        Result       = $result
        Duration     = Format-AzplElapsedTime -Duration $stopwatch.Elapsed
        Seconds      = [Math]::Round($stopwatch.Elapsed.TotalSeconds, 2)
        Milliseconds = [Math]::Round($stopwatch.Elapsed.TotalMilliseconds, 2)
        Metadata     = $task.Metadata
      }
    }

    return $results
  }

  $jobs = @()
  try {
    foreach ($task in $taskList) {
      $jobs += Start-ThreadJob -Name $task.Name -ArgumentList $ModuleManifestPath, $task.FunctionName, $task.Parameters, $task.Metadata -ScriptBlock {
        param($resolvedModuleManifestPath, $functionName, $parameters, $metadata)

        $module = Import-Module $resolvedModuleManifestPath -Force -PassThru -ErrorAction Stop

        $stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
        try {
          $result = & $module {
            param($resolvedFunctionName, $resolvedParameters)

            if (-not (Get-Command -Name $resolvedFunctionName -ErrorAction SilentlyContinue)) {
              throw "Function '$resolvedFunctionName' is not available in module scope."
            }

            & $resolvedFunctionName @resolvedParameters
          } $functionName $parameters
        } finally {
          $stopwatch.Stop()
        }

        [pscustomobject]@{
          Result       = $result
          Duration     = [string]::Format(($stopwatch.Elapsed.TotalHours -ge 1 ? '{0:hh\:mm\:ss\.fff}' : '{0:mm\:ss\.fff}'), $stopwatch.Elapsed)
          Seconds      = [Math]::Round($stopwatch.Elapsed.TotalSeconds, 2)
          Milliseconds = [Math]::Round($stopwatch.Elapsed.TotalMilliseconds, 2)
          Metadata     = $metadata
        }
      }
    }

    Wait-Job -Job $jobs | Out-Null

    foreach ($job in $jobs) {
      if ($job.State -ne 'Completed') {
        $failure = Receive-Job -Job $job -ErrorAction SilentlyContinue
        throw "Concurrent page generation task '$($job.Name)' failed. $failure"
      }

      $results[$job.Name] = Receive-Job -Job $job -ErrorAction Stop
    }
  } finally {
    if ($jobs.Count -gt 0) {
      Remove-Job -Job $jobs -Force -ErrorAction SilentlyContinue
    }
  }

  return $results
}

#region function to generate either basic or detailed documentation for the entire environment or a subset of subscriptions
Function New-AzplDocumentation {
  [CmdletBinding(SupportsShouldProcess, DefaultParameterSetName = 'ImportNoEncryption')]
  [OutputType([array])]
  param (
    [parameter(Mandatory = $true, HelpMessage = 'The page style (detailed for engineers or basic for customers).')]
    [ValidateSet('detailed', 'basic')]
    [string]$PageStyle,

    [parameter(Mandatory = $true, ParameterSetName = 'ImportNoEncryption_Subscription', HelpMessage = 'Optional. The subset of subscription Ids (GUID) to generate the documentation for.')]
    [parameter(Mandatory = $true, ParameterSetName = 'ImportEncryptionWithKeyFile_Subscription', HelpMessage = 'Optional. The subset of subscription Ids (GUID) to generate the documentation for.')]
    [parameter(Mandatory = $true, ParameterSetName = 'ImportEncryptionWithKeyText_Subscription', HelpMessage = 'Optional. The subset of subscription Ids (GUID) to generate the documentation for.')]
    [ValidateScript({ $_ -match '(?im)^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$' })]
    [string[]]$SubscriptionIds,

    [parameter(Mandatory = $true, ParameterSetName = 'ImportNoEncryption_ManagementGroup', HelpMessage = 'The Id of a child management group to generate the documentation for.')]
    [parameter(Mandatory = $true, ParameterSetName = 'ImportEncryptionWithKeyFile_ManagementGroup', HelpMessage = 'The Id of a child management group to generate the documentation for.')]
    [parameter(Mandatory = $true, ParameterSetName = 'ImportEncryptionWithKeyText_ManagementGroup', HelpMessage = 'The Id of a child management group to generate the documentation for.')]
    [ValidateNotNullOrEmpty()]
    [string]$childManagementGroupId,

    [parameter(Mandatory = $false, ParameterSetName = 'ImportNoEncryption', DontShow = $true, HelpMessage = 'Internal switch to represent no subscription or management group filter.')]
    [switch]$NoFilter,

    [parameter(Mandatory = $true, HelpMessage = 'The output base directory.')]
    [ValidateScript({ Test-Path $_ -PathType 'Container' })]
    [string]$BaseOutputPath,

    [parameter(Mandatory = $true, HelpMessage = 'The title of the wiki.')]
    [ValidateNotNullOrEmpty()]
    [string]$Title,

    [parameter(Mandatory = $true, HelpMessage = 'The wiki style. Supported values are "ado" and "github".')]
    [ValidateSet('ado', 'github')]
    [string]$WikiStyle,

    [parameter(Mandatory = $false, HelpMessage = 'The warning days for the expiration of the policy exemption.')]
    [ValidateRange(7, 90)]
    [int]$ExemptionExpiresOnWarningDays = 30,

    [parameter(Mandatory = $false, HelpMessage = 'The warning percentage threshold for policy compliance summary.')]
    [ValidateRange(1, 99)]
    [int]$ComplianceWarningPercentageThreshold = 80,

    [parameter(Mandatory = $false, HelpMessage = 'The maximum number of concurrent wiki page writes to use during generation.')]
    [ValidateRange(1, 64)]
    [int]$WriteThrottleLimit = 8,

    [parameter(Mandatory = $false, HelpMessage = 'The directory contains custom security control definitions.')]
    [ValidateScript({ Test-Path $_ -PathType 'Container' })]
    [string]$CustomSecurityControlPath,

    [parameter(Mandatory = $true, HelpMessage = 'File path for the Environment Data to import')]
    [ValidateScript({ Test-Path -Path $_ -PathType 'Leaf' })]
    [string]$DiscoveryDataImportFilePath,

    [parameter(Mandatory = $true, ParameterSetName = 'ImportEncryptionWithKeyFile', HelpMessage = 'AES Encryption key file path. This key is used to encrypt the new discovery json export file or decrypt the existing environment discovery file.')]
    [parameter(Mandatory = $true, ParameterSetName = 'ImportEncryptionWithKeyFile_Subscription', HelpMessage = 'AES Encryption key file path. This key is used to encrypt the new discovery json export file or decrypt the existing environment discovery file.')]
    [parameter(Mandatory = $true, ParameterSetName = 'ImportEncryptionWithKeyFile_ManagementGroup', HelpMessage = 'AES Encryption key file path. This key is used to encrypt the new discovery json export file or decrypt the existing environment discovery file.')]
    [ValidateNotNullOrEmpty()]
    [string]$EncryptionKeyFilePath,

    [parameter(Mandatory = $true, ParameterSetName = 'ImportEncryptionWithKeyText', HelpMessage = 'AES Encryption Key Content.')]
    [parameter(Mandatory = $true, ParameterSetName = 'ImportEncryptionWithKeyText_Subscription', HelpMessage = 'AES Encryption Key Content.')]
    [parameter(Mandatory = $true, ParameterSetName = 'ImportEncryptionWithKeyText_ManagementGroup', HelpMessage = 'AES Encryption Key Content.')]
    [ValidateNotNullOrEmpty()]
    [string]$EncryptionKey,

    [parameter(Mandatory = $true, ParameterSetName = 'ImportEncryptionWithKeyText', HelpMessage = 'AES Encryption Initialization Vector (IV) Content.')]
    [parameter(Mandatory = $true, ParameterSetName = 'ImportEncryptionWithKeyText_Subscription', HelpMessage = 'AES Encryption Initialization Vector (IV) Content.')]
    [parameter(Mandatory = $true, ParameterSetName = 'ImportEncryptionWithKeyText_ManagementGroup', HelpMessage = 'AES Encryption Initialization Vector (IV) Content.')]
    [ValidateNotNullOrEmpty()]
    [string]$EncryptionIV
  )

  $documentationStopwatch = [System.Diagnostics.Stopwatch]::StartNew()
  $phaseMetrics = [ordered]@{}

  Write-Verbose "Environment Data will be imported from '$DiscoveryDataImportFilePath'."
  $importParams = @{
    FilePath = $DiscoveryDataImportFilePath
  }
  if ($PSCmdlet.ParameterSetName -ilike 'ImportEncryptionWithKeyFile*') {
    $importParams.Add('EncryptionKeyFilePath', $EncryptionKeyFilePath)
  } elseif ($PSCmdlet.ParameterSetName -ilike 'ImportEncryptionWithKeyText*') {
    $importParams.Add('EncryptionKey', $EncryptionKey)
    $importParams.Add('EncryptionIV', $EncryptionIV)
  }
  $AzplEnvironmentDetails = Invoke-AzplTimedOperation -Name 'Import environment discovery data' -Metrics $phaseMetrics -Operation {
    Import-AzplEnvironmentDiscovery @importParams
  }

  #Make sure all policy resources are retrieved previously in a script scoped variable $AzplEnvironmentDetails
  if (!$AzplEnvironmentDetails) {
    Throw "[$(getCurrentUTCString)]: No environment discovery data found."
  }
  #create script scoped variables for Policy Definition and initiative syntax validation failures
  $global:failedSyntaxValidationDefinitions = @()
  $global:failedSyntaxValidationInitiatives = @()

  if ($subscriptionIds.count -gt 0) {
    Write-Verbose "[$(getCurrentUTCString)]: subscription Ids are provided. Filtering documentation for the specified subscriptions only." -Verbose
    $EnvironmentDiscoveryData = Invoke-AzplTimedOperation -Name 'Filter discovery data by subscriptions' -Metrics $phaseMetrics -Metadata @{ SubscriptionCount = $subscriptionIds.Count } -Operation {
      filterDiscoveryData -SubscriptionIds $subscriptionIds -environmentDetails $AzplEnvironmentDetails
    }
  } elseif ($childManagementGroupId.length -gt 0) {
    Write-Verbose "[$(getCurrentUTCString)]: Child management group ID is provided. Filtering documentation for the specified child management group and its descendants." -Verbose
    $EnvironmentDiscoveryData = Invoke-AzplTimedOperation -Name 'Filter discovery data by child management group' -Metrics $phaseMetrics -Metadata @{ ManagementGroupId = $childManagementGroupId } -Operation {
      filterDiscoveryData -ChildManagementGroupId $childManagementGroupId -environmentDetails $AzplEnvironmentDetails
    }
  } else {
    Write-Verbose "[$(getCurrentUTCString)]: No subscription Ids or child management group ID provided. Generating documentation for all subscriptions in the environment." -Verbose
    $EnvironmentDiscoveryData = $AzplEnvironmentDetails
    $phaseMetrics['Use unfiltered discovery data'] = [ordered]@{
      Duration     = '00:00.000'
      Seconds      = 0
      Milliseconds = 0
      SubscriptionCount = @($AzplEnvironmentDetails.subscriptions).Count
    }
  }


  # generate wiki page file names
  $wikiFileMapping = Invoke-AzplTimedOperation -Name 'Generate wiki file mapping' -Metrics $phaseMetrics -Operation {
    newWikiPageMapping -discoveryData $EnvironmentDiscoveryData -BaseOutputPath $BaseOutputPath -WikiStyle $WikiStyle -Title $Title -PageStyle $PageStyle -Verbose:($PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent -eq $true)
  }

  #Delete existing wiki content (so there are no orphaned pages for resources no longer exist)
  Write-Verbose "[$(getCurrentUTCString)]: Deleting existing wiki content in '$BaseOutputPath'." -Verbose
  Invoke-AzplTimedOperation -Name 'Remove existing wiki files' -Metrics $phaseMetrics -Operation {
    removeExistingWikiFiles -WikiDirectory $BaseOutputPath -Verbose:($PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent -eq $true)
  } | Out-Null

  $detailedPagesCommonParams = @{
    WikiFileMapping          = $wikiFileMapping
    EnvironmentDiscoveryData = $EnvironmentDiscoveryData
    PageStyle                = $PageStyle
    WriteThrottleLimit       = $WriteThrottleLimit
    Verbose                  = ($PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent -eq $true)
  }

  #Get unique policy categories from assigned initiatives
  $uniqueAssignedPolicyInitiativeCategories = Invoke-AzplTimedOperation -Name 'Build assigned policy categories' -Metrics $phaseMetrics -Operation {
    getUniqueCategoriesFromAssignedInitiatives -EnvironmentDiscoveryData $EnvironmentDiscoveryData
  }

  #Get list of custom security control files (if provided)
  if ($PSBoundParameters.ContainsKey('CustomSecurityControlPath')) {
    $CustomSecurityControlFileSchemaFilePath = Join-Path -Path $PSScriptRoot -ChildPath 'AzPolicyLens.Wiki.Custom.Security.Control.schema.json'
    $CustomSecurityControlFileConfig = Invoke-AzplTimedOperation -Name 'Load custom security controls' -Metrics $phaseMetrics -Operation {
      getCustomSecurityControlFileConfig -FilePath $CustomSecurityControlPath -schemaFilePath $CustomSecurityControlFileSchemaFilePath
    }
  }

  $moduleManifestPath = Join-Path -Path $PSScriptRoot -ChildPath 'AzPolicyLens.Wiki.psd1'
  $independentPageTasks = @()

  Write-Verbose "[$(getCurrentUTCString)]: Start Generating Markdown files for the $($EnvironmentDiscoveryData.policyMetadata.count) built-in security controls (policy metadata) that have been discovered." -Verbose
  $independentPageTasks += [pscustomobject]@{
    Name         = 'Generate policy metadata pages'
    FunctionName = 'newPolicyMetadataPage'
    Parameters   = @{
      WikiFileMapping                      = $wikiFileMapping
      EnvironmentDiscoveryData             = $EnvironmentDiscoveryData
      ComplianceWarningPercentageThreshold = $ComplianceWarningPercentageThreshold
    }
    Metadata     = @{ ItemCount = @($EnvironmentDiscoveryData.policyMetadata).Count }
  }

  Write-Verbose "[$(getCurrentUTCString)]: Start Generating Markdown files for the $($EnvironmentDiscoveryData.definitions.count) policy definitions that have been discovered." -Verbose
  $independentPageTasks += [pscustomobject]@{
    Name         = 'Generate policy definition pages'
    FunctionName = 'newPolicyDefinitionPage'
    Parameters   = @{
      WikiFileMapping          = $wikiFileMapping
      EnvironmentDiscoveryData = $EnvironmentDiscoveryData
      PageStyle                = $PageStyle
      WriteThrottleLimit       = $WriteThrottleLimit
    }
    Metadata     = @{ ItemCount = @($EnvironmentDiscoveryData.definitions).Count }
  }

  Write-Verbose "[$(getCurrentUTCString)]: Start Generating Markdown files for the $($EnvironmentDiscoveryData.initiatives.count) policy initiatives that have been discovered." -Verbose
  $initiativeTaskParameters = @{
    WikiFileMapping          = $wikiFileMapping
    EnvironmentDiscoveryData = $EnvironmentDiscoveryData
    PageStyle                = $PageStyle
    WriteThrottleLimit       = $WriteThrottleLimit
  }
  if ($PSBoundParameters.ContainsKey('CustomSecurityControlPath')) {
    $initiativeTaskParameters.CustomSecurityControlFileConfig = $CustomSecurityControlFileConfig
  }
  $independentPageTasks += [pscustomobject]@{
    Name         = 'Generate policy initiative pages'
    FunctionName = 'newPolicyInitiativePage'
    Parameters   = $initiativeTaskParameters
    Metadata     = @{ ItemCount = @($EnvironmentDiscoveryData.initiatives).Count }
  }

  if ($PSBoundParameters.ContainsKey('CustomSecurityControlPath')) {
    Write-Verbose "[$(getCurrentUTCString)]: Start Generating Markdown files for the custom security controls defined in '$CustomSecurityControlPath'." -Verbose
    $independentPageTasks += [pscustomobject]@{
      Name         = 'Generate custom security control pages'
      FunctionName = 'newCustomSecurityControlPage'
      Parameters   = @{
        WikiFileMapping                      = $wikiFileMapping
        EnvironmentDiscoveryData             = $EnvironmentDiscoveryData
        PageStyle                            = $PageStyle
        CustomSecurityControlFileConfig      = $CustomSecurityControlFileConfig
        ComplianceWarningPercentageThreshold = $ComplianceWarningPercentageThreshold
      }
      Metadata     = @{ ItemCount = @($CustomSecurityControlFileConfig).Count }
    }
  } else {
    $customSecurityControlPages = @()
  }

  Write-Verbose "[$(getCurrentUTCString)]: Start Generating Markdown files for the $($EnvironmentDiscoveryData.assignments.count) policy assignments that have been discovered." -Verbose
  $independentPageTasks += [pscustomobject]@{
    Name         = 'Generate policy assignment pages'
    FunctionName = 'newPolicyAssignmentPage'
    Parameters   = @{
      EnvironmentDiscoveryData                 = $EnvironmentDiscoveryData
      ComplianceWarningPercentageThreshold     = $ComplianceWarningPercentageThreshold
      WikiFileMapping                          = $wikiFileMapping
      PageStyle                                = $PageStyle
      WriteThrottleLimit                       = $WriteThrottleLimit
    }
    Metadata     = @{ ItemCount = @($EnvironmentDiscoveryData.assignments).Count }
  }

  if ($EnvironmentDiscoveryData.exemptions.Count -gt 0) {
    Write-Verbose "[$(getCurrentUTCString)]: Start Generating Markdown files for the $($EnvironmentDiscoveryData.exemptions.count) policy exemptions that have been discovered." -Verbose
    $independentPageTasks += [pscustomobject]@{
      Name         = 'Generate policy exemption pages'
      FunctionName = 'newPolicyExemptionPage'
      Parameters   = @{
        EnvironmentDiscoveryData = $EnvironmentDiscoveryData
        ExpiresOnWarningDays     = $ExemptionExpiresOnWarningDays
        WikiFileMapping          = $wikiFileMapping
        PageStyle                = $PageStyle
        WriteThrottleLimit       = $WriteThrottleLimit
      }
      Metadata     = @{ ItemCount = @($EnvironmentDiscoveryData.exemptions).Count }
    }
  } else {
    Write-Verbose "[$(getCurrentUTCString)]: No policy exemptions found in the environment. Skipping individual exemption page generation."
    $exemptionPages = @()
  }

  Write-Verbose "[$(getCurrentUTCString)]: Start Generating Markdown files for the $($EnvironmentDiscoveryData.subscriptions.count) subscriptions that have been discovered." -Verbose
  $independentPageTasks += [pscustomobject]@{
    Name         = 'Generate subscription pages'
    FunctionName = 'newSubscriptionPage'
    Parameters   = @{
      WikiFileMapping                          = $wikiFileMapping
      PageStyle                                = $PageStyle
      ExemptionExpiresOnWarningDays            = $ExemptionExpiresOnWarningDays
      ComplianceWarningPercentageThreshold     = $ComplianceWarningPercentageThreshold
      EnvironmentDiscoveryData                 = $EnvironmentDiscoveryData
      WriteThrottleLimit                       = $WriteThrottleLimit
    }
    Metadata     = @{ ItemCount = @($EnvironmentDiscoveryData.subscriptions).Count }
  }

  $independentPageResults = Invoke-AzplTimedOperation -Name 'Generate independent detailed page sets' -Metrics $phaseMetrics -Metadata @{ TaskCount = $independentPageTasks.Count } -Operation {
    Invoke-AzplConcurrentPageGeneration -Tasks $independentPageTasks -ModuleManifestPath $moduleManifestPath
  }

  $policyMetadataPages = @($independentPageResults['Generate policy metadata pages'].Result)
  $phaseMetrics['Generate policy metadata pages'] = [ordered]@{
    Duration     = $independentPageResults['Generate policy metadata pages'].Duration
    Seconds      = $independentPageResults['Generate policy metadata pages'].Seconds
    Milliseconds = $independentPageResults['Generate policy metadata pages'].Milliseconds
    ItemCount    = $independentPageResults['Generate policy metadata pages'].Metadata.ItemCount
  }

  $definitionPages = @($independentPageResults['Generate policy definition pages'].Result)
  $phaseMetrics['Generate policy definition pages'] = [ordered]@{
    Duration     = $independentPageResults['Generate policy definition pages'].Duration
    Seconds      = $independentPageResults['Generate policy definition pages'].Seconds
    Milliseconds = $independentPageResults['Generate policy definition pages'].Milliseconds
    ItemCount    = $independentPageResults['Generate policy definition pages'].Metadata.ItemCount
  }

  $initiativePages = @($independentPageResults['Generate policy initiative pages'].Result)
  $phaseMetrics['Generate policy initiative pages'] = [ordered]@{
    Duration     = $independentPageResults['Generate policy initiative pages'].Duration
    Seconds      = $independentPageResults['Generate policy initiative pages'].Seconds
    Milliseconds = $independentPageResults['Generate policy initiative pages'].Milliseconds
    ItemCount    = $independentPageResults['Generate policy initiative pages'].Metadata.ItemCount
  }

  if ($independentPageResults.Contains('Generate custom security control pages')) {
    $customSecurityControlPages = @($independentPageResults['Generate custom security control pages'].Result)
    $phaseMetrics['Generate custom security control pages'] = [ordered]@{
      Duration     = $independentPageResults['Generate custom security control pages'].Duration
      Seconds      = $independentPageResults['Generate custom security control pages'].Seconds
      Milliseconds = $independentPageResults['Generate custom security control pages'].Milliseconds
      ItemCount    = $independentPageResults['Generate custom security control pages'].Metadata.ItemCount
    }
  }

  $assignmentPages = @($independentPageResults['Generate policy assignment pages'].Result)
  $phaseMetrics['Generate policy assignment pages'] = [ordered]@{
    Duration     = $independentPageResults['Generate policy assignment pages'].Duration
    Seconds      = $independentPageResults['Generate policy assignment pages'].Seconds
    Milliseconds = $independentPageResults['Generate policy assignment pages'].Milliseconds
    ItemCount    = $independentPageResults['Generate policy assignment pages'].Metadata.ItemCount
  }

  if ($independentPageResults.Contains('Generate policy exemption pages')) {
    $exemptionPages = @($independentPageResults['Generate policy exemption pages'].Result)
    $phaseMetrics['Generate policy exemption pages'] = [ordered]@{
      Duration     = $independentPageResults['Generate policy exemption pages'].Duration
      Seconds      = $independentPageResults['Generate policy exemption pages'].Seconds
      Milliseconds = $independentPageResults['Generate policy exemption pages'].Milliseconds
      ItemCount    = $independentPageResults['Generate policy exemption pages'].Metadata.ItemCount
    }
  }

  $subscriptionPages = @($independentPageResults['Generate subscription pages'].Result)
  $phaseMetrics['Generate subscription pages'] = [ordered]@{
    Duration     = $independentPageResults['Generate subscription pages'].Duration
    Seconds      = $independentPageResults['Generate subscription pages'].Seconds
    Milliseconds = $independentPageResults['Generate subscription pages'].Milliseconds
    ItemCount    = $independentPageResults['Generate subscription pages'].Metadata.ItemCount
  }

  #Generate Markdown pages for policy categories
  Write-Verbose "[$(getCurrentUTCString)]: Start Generating Markdown files for the $($uniqueAssignedPolicyInitiativeCategories.count) unique policy categories from assigned initiatives." -Verbose
  $policyCategoryPageParams = @{
    WikiFileMapping                          = $wikiFileMapping
    EnvironmentDiscoveryData                 = $EnvironmentDiscoveryData
    uniqueAssignedPolicyInitiativeCategories = $uniqueAssignedPolicyInitiativeCategories
    ComplianceWarningPercentageThreshold     = $ComplianceWarningPercentageThreshold
    Verbose                                  = ($PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent -eq $true)
  }
  if ($PSBoundParameters.ContainsKey('CustomSecurityControlPath')) {
    $policyCategoryPageParams.Add('CustomSecurityControlFileConfig', $CustomSecurityControlFileConfig)
  }
  $policyCategoryPages = Invoke-AzplTimedOperation -Name 'Generate policy category pages' -Metrics $phaseMetrics -Metadata @{ ItemCount = @($uniqueAssignedPolicyInitiativeCategories.Keys).Count } -Operation {
    newPolicyCategoryPage @policyCategoryPageParams
  }

  $summaryPagesCommonParams = @{
    wikiFileMapping          = $wikiFileMapping
    EnvironmentDiscoveryData = $EnvironmentDiscoveryData
    Title                    = $Title
    PageStyle                = $PageStyle
    Verbose                  = ($PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent -eq $true)
  }

  #Generate detailed main summary Markdown page
  Write-Verbose "[$(getCurrentUTCString)]: Start Generating main $PageStyle summary Markdown file." -Verbose
  if ($SubscriptionIds.count -gt 0) {
    $mainSummaryPage = newMainSummaryPage @summaryPagesCommonParams -ComplianceWarningPercentageThreshold $ComplianceWarningPercentageThreshold -uniqueAssignedPolicyInitiativeCategories $uniqueAssignedPolicyInitiativeCategories -SubscriptionIds $SubscriptionIds
  } elseif ($null -ne $childManagementGroupId) {
    $mainSummaryPage = newMainSummaryPage @summaryPagesCommonParams -ComplianceWarningPercentageThreshold $ComplianceWarningPercentageThreshold -uniqueAssignedPolicyInitiativeCategories $uniqueAssignedPolicyInitiativeCategories -ChildManagementGroupId $childManagementGroupId
  } else {
    $mainSummaryPage = newMainSummaryPage @summaryPagesCommonParams -ComplianceWarningPercentageThreshold $ComplianceWarningPercentageThreshold -uniqueAssignedPolicyInitiativeCategories $uniqueAssignedPolicyInitiativeCategories
  }

  #Generate assignment summary Markdown page
  Write-Verbose "[$(getCurrentUTCString)]: Start Generating Policy Assignment summary Markdown file." -Verbose
  $assignmentSummaryPage = newAssignmentSummaryPage @summaryPagesCommonParams -ComplianceWarningPercentageThreshold $ComplianceWarningPercentageThreshold

  #Generate assignment initiative Markdown page
  Write-Verbose "[$(getCurrentUTCString)]: Start Generating Policy Initiative summary Markdown file." -Verbose
  $initiativeSummaryPage = newInitiativeSummaryPage @summaryPagesCommonParams

  #Generate assignment definition Markdown page
  Write-Verbose "[$(getCurrentUTCString)]: Start Generating Policy Definition summary Markdown file." -Verbose
  $definitionSummaryPage = newDefinitionSummaryPage @summaryPagesCommonParams

  if ($PageStyle -ieq 'detailed') {
    #Generate security control summary Markdown page
    Write-Verbose "[$(getCurrentUTCString)]: Start Generating Security Control summary Markdown file." -Verbose
    if ($PSBoundParameters.ContainsKey('CustomSecurityControlPath')) {
      $securityControlSummaryPage = newSecurityControlSummaryPage @summaryPagesCommonParams -CustomSecurityControlFileConfig $CustomSecurityControlFileConfig
    } else {
      $securityControlSummaryPage = newSecurityControlSummaryPage @summaryPagesCommonParams
    }
  }

  #Generate policy category summary Markdown page
  Write-Verbose "[$(getCurrentUTCString)]: Start Generating Policy Category summary Markdown file." -Verbose
  $policyCategorySummaryPage = newPolicyCategorySummaryPage @summaryPagesCommonParams -ComplianceWarningPercentageThreshold $ComplianceWarningPercentageThreshold -uniqueAssignedPolicyInitiativeCategories $uniqueAssignedPolicyInitiativeCategories

  #Generate subscription Markdown page
  Write-Verbose "[$(getCurrentUTCString)]: Start Generating Subscription summary Markdown file." -Verbose
  $subscriptionSummaryPage = newSubscriptionSummaryPage @summaryPagesCommonParams -ComplianceWarningPercentageThreshold $ComplianceWarningPercentageThreshold

  #Generate analysis Markdown page
  #This page must be generated after the policy definition and initiative detailed pages because it needs the summary data for definition and initiative syntax validation results.
  Write-Verbose "[$(getCurrentUTCString)]: Start Generating Policy Analysis summary Markdown file." -Verbose
  if ($PSBoundParameters.ContainsKey('CustomSecurityControlPath')) {
    $analysisSummaryPage = newAnalysisSummaryPage @summaryPagesCommonParams -ComplianceWarningPercentageThreshold $ComplianceWarningPercentageThreshold -CustomSecurityControlFileConfig $CustomSecurityControlFileConfig
  } else {
    $analysisSummaryPage = newAnalysisSummaryPage @summaryPagesCommonParams -ComplianceWarningPercentageThreshold $ComplianceWarningPercentageThreshold
  }

  if ($EnvironmentDiscoveryData.exemptions.Count -gt 0) {
    #Generate exemption Markdown page
    Write-Verbose "[$(getCurrentUTCString)]: Start Generating Policy Exemption summary Markdown file." -Verbose
    $exemptionSummaryPage = newExemptionSummaryPage @summaryPagesCommonParams -ExpiresOnWarningDays $ExemptionExpiresOnWarningDays
  } else {
    Write-Verbose "[$(getCurrentUTCString)]: No policy exemptions found in the environment. Skipping exemption summary page generation."
    $exemptionSummaryPage = @()
  }

  if ($WikiStyle -ieq 'github') {
    #Generate GitHub wiki sidebar
    Write-Verbose "[$(getCurrentUTCString)]: Start Generating GitHub wiki sidebar and footer Markdown files." -Verbose
    $githubSidebarParams = @{
      WikiFileMapping                 = $wikiFileMapping
      Title                           = $Title
      EnvironmentDiscoveryData        = $EnvironmentDiscoveryData
      CustomSecurityControlFileConfig = $customSecurityControlPages
      PageStyle                       = $PageStyle
      Verbose                         = ($PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent -eq $true)
    }
    $sidebarFilePath = newGitHubWikiSidebar @githubSidebarParams
    $footerFilePath = newGitHubWikiFooter -WikiFileMapping $wikiFileMapping -TimeStamp $EnvironmentDiscoveryData.TimeStamp
  } else {
    Write-Verbose "[$(getCurrentUTCString)]: Skipping GitHub wiki sidebar generation as WikiStyle is not 'github'." -Verbose
  }

  $documentationStopwatch.Stop()
  Write-Output "[$(getCurrentUTCString)]: Wiki documentation generation completed in $(Format-AzplElapsedTime -Duration $documentationStopwatch.Elapsed)."
  Write-AzplTimingSummary -Metrics $phaseMetrics -OperationName 'Wiki documentation generation'

  #Tidy up - Remove global variables
  Remove-Variable -Name failedSyntaxValidationDefinitions -Scope Global -ErrorAction SilentlyContinue
  Remove-Variable -Name failedSyntaxValidationInitiatives -Scope Global -ErrorAction SilentlyContinue

  Write-Output "[$(getCurrentUTCString)]: The following Markdown files for main summary page are generated."
  foreach ($p in $mainSummaryPage) {
    Write-Output "  - $p"
  }

  Write-Output "[$(getCurrentUTCString)]: The following Markdown files for policy assignment summary page are generated."
  foreach ($p in $assignmentSummaryPage) {
    Write-Output "  - $p"
  }

  Write-Output "[$(getCurrentUTCString)]: The following Markdown files for policy initiative summary page are generated."
  foreach ($p in $initiativeSummaryPage) {
    Write-Output "  - $p"
  }

  Write-Output "[$(getCurrentUTCString)]: The following Markdown files for policy definition summary page are generated."
  foreach ($p in $definitionSummaryPage) {
    Write-Output "  - $p"
  }

  if ($PageStyle -ieq 'detailed') {
    Write-Output "[$(getCurrentUTCString)]: The following Markdown files for security control summary page are generated."
    foreach ($p in $securityControlSummaryPage) {
      Write-Output "  - $p"
    }
  }

  Write-Output "[$(getCurrentUTCString)]: The following Markdown files for policy category summary page are generated."
  foreach ($p in $policyCategorySummaryPage) {
    Write-Output "  - $p"
  }

  Write-Output "[$(getCurrentUTCString)]: The following Markdown files for policy exemption summary page are generated."
  foreach ($p in $exemptionSummaryPage) {
    Write-Output "  - $p"
  }

  Write-Output "[$(getCurrentUTCString)]: The following Markdown files for policy subscription summary page are generated."
  foreach ($p in $subscriptionSummaryPage) {
    Write-Output "  - $p"
  }

  Write-Output "[$(getCurrentUTCString)]: The following Markdown files for policy analysis summary page are generated."
  foreach ($p in $analysisSummaryPage) {
    Write-Output "  - $p"
  }

  Write-Output "[$(getCurrentUTCString)]: The following Markdown files for Subscriptions are generated."
  foreach ($p in $subscriptionPages) {
    Write-Output "  - $p"
  }

  Write-Output "[$(getCurrentUTCString)]: The following Markdown files for Policy Assignments are generated."
  foreach ($p in $assignmentPages) {
    Write-Output "  - $p"
  }

  Write-Output "[$(getCurrentUTCString)]: The following Markdown files for Policy Initiatives are generated."
  foreach ($p in $initiativePages) {
    Write-Output "  - $p"
  }

  Write-Output "[$(getCurrentUTCString)]: The following Markdown files for Policy Definitions are generated."
  foreach ($p in $definitionPages) {
    Write-Output "  - $p"
  }

  Write-Output "[$(getCurrentUTCString)]: The following Markdown files for Policy Exemptions are generated."
  foreach ($p in $exemptionPages) {
    Write-Output "  - $p"
  }

  Write-Output "[$(getCurrentUTCString)]: The following Markdown files for Policy Metadata are generated."
  foreach ($p in $policyMetadataPages) {
    Write-Output "  - $p"
  }

  if ($customSecurityControlPages) {
    Write-Output "[$(getCurrentUTCString)]: The following Markdown files for Custom Security Controls are generated."
    foreach ($p in $customSecurityControlPages) {
      Write-Output "  - $p"
    }
  }

  if ($policyCategoryPages) {
    Write-Output "[$(getCurrentUTCString)]: The following Markdown files for Policy Categories are generated."
    foreach ($p in $policyCategoryPages) {
      Write-Output "  - $p"
    }
  }

  if ($WikiStyle -ieq 'github') {
    Write-Output "[$(getCurrentUTCString)]: The GitHub wiki sidebar and footer files have been successfully generated."
    Write-Output "  - $sidebarFilePath"
    Write-Output "  - $footerFilePath"
  }

  Write-Output "[$(getCurrentUTCString)]: The Policy documentation have been successfully generated for Management Group '$($AzplEnvironmentDetails.topLevelManagementGroupName)'."
}
#endregion
