properties {
  # General properties
  $projectName = 'KudosPlatform'

  # Get the properties/parameters for deploying to Azure
  if ([String]::IsNullOrEmpty($azureUsername)) {
    if (-not [String]::IsNullOrEmpty($ENV:azureUsername)) {
      $azureUsername = $ENV:azureUsername
    } # if
  } # if

  if ([String]::IsNullOrEmpty($azurePassword)) {
    if (-not [String]::IsNullOrEmpty($ENV:azurePassword)) {
      $azurePassword = ConvertTo-SecureString `
        -String $ENV:azurePassword `
        -AsPlainText `
        -Force
    } # if
  } else {
    if ($azurePassword -is [String]) {
        $azurePassword = ConvertTo-SecureString `
          -String $azurePassword `
          -AsPlainText `
          -Force
    } # if
  } # if

  if (-not [String]::IsNullOrEmpty($azureUsername) -and `
    -not [String]::IsNullOrEmpty($azurePassword)) {
    $azureCredential = New-Object `
      -TypeName System.Management.Automation.PSCredential `
      -ArgumentList @($azureUsername, $azurePassword)
  } # if

  if ([String]::IsNullOrEmpty($azureTenantId)) {
    if (-not [String]::IsNullOrEmpty($ENV:azureTenantId)) {
      $azureTenantId = $ENV:azureTenantId
    } # if
  } # if

  # Task messages
  $initMessage = 'Executed Init!'
  $cleanMessage = 'Executed Clean!'
  $testMessage = 'Executed Test!'
  $buildMessage = 'Executed Build!'
  $installMessage = 'Executed Install!'
}

task default -depends Test

task Install -depends Init, Build, Clean, Test {
  if (-not $azureCredential) {
    Write-Error -Message 'Installation failed because Azure credentials not provided.'
    return
  }

  Add-AzureRmAccount `
    -Credential $azureCredential `
    -TenantId $azureTenantId `
    -ServicePrincipal

  Write-SuccessfulTaskInfo -Message 'Successfully logged into Azure Account.'

  $installMessage
}

task Test -depends Init, Build, Clean {
  $testMessage
}

task Build -depends Init, Clean {
  $buildMessage
}

task Clean {
  $cleanMessage
}

task Init {
  # Install Microsoft Azure App Service Tools v2.9.6 - Visual Studio 2015
  if (Get-Package -ProviderName msi |
    Where-Object -Filter { $_.TagId -eq '4EB8A716-D680-3AF9-B117-BD568DD43B0D' }) {
    Write-SuccessfulTaskInfo -Message 'Microsoft Azure App Service Tools v2.9.6 - Visual Studio 2015 is already installed'
  } else {
    Write-ProgressTaskInfo -Message 'Installing Microsoft Azure App Service Tools v2.9.6 - Visual Studio 2015...'
    $WebToolsAzurePath = Join-Path -Path $ENV:Temp -ChildPath 'WebToolsAzure2015.exe'
    Invoke-WebRequest -Uri https://aka.ms/azfunctiontools -OutFile $WebToolsAzurePath
    & $WebToolsAzurePath @('/install','/quiet','/norestart') | Out-Null
    Remove-Item -Path $WebToolsAzurePath -Force
  } # if

  # Install Azure PowerShell Module so that we can Install components to Azure
  if (Get-Module -Name Azure -ListAvailable) {
    Write-SuccessfulTaskInfo -Message 'Microsoft Azure PowerShell Module is already installed'
  } else {
    Write-ProgressTaskInfo -Message 'Installing Microsoft Azure PowerShell Module...'
    Install-Module -Name Azure -Force -AllowClobber
  } # if

  # Install AzureRM PowerShell Module so that we can Install components to Azure
  if (Get-Module -Name AzureRM -ListAvailable) {
    Write-SuccessfulTaskInfo -Message 'Microsoft AzureRM PowerShell Module is already installed'
  } else {
    Write-ProgressTaskInfo -Message 'Installing Microsoft AzureRM PowerShell Module...'
    Install-Module -Name AzureRM -Force -AllowClobber
  } # if

  $initMessage
}

task CreateAzureSP {
  <#
    This task creates an Azure Service Principal in Azure AD that will be used for all installation automation.
    This can only be run interactively as the Login-AzureRmAccount will pop up an interactive window for the
    user to log in with.
  #>
  $account = Login-AzureRmAccount
  Write-Host -Object "Creating Application in Azure AD" -foregroundcolor Yellow
  $app = New-AzureRmADApplication `
    -DisplayName $projectName `
    -HomePage "https://$azureADDomain/$projectName" `
    -IdentifierUris "https://$azureADDomain/$projectName" `
    -Password $azurePassword
  Write-ProgressTaskInfo -Message "Creating Azure AD Service Principal for ApplicationId '$($app.ApplicationId)'"
  $null = New-AzureRmADServicePrincipal `
    -ApplicationId $app.ApplicationId
  Write-ProgressTaskInfo -Message "Assigning role Contributor to AD Service Principal for ApplicationId '$($app.ApplicationId)'"
  $roleAssignment = $null
  while (-not $roleAssignment) {
    $roleAssignment = New-AzureRmRoleAssignment `
      -RoleDefinitionName Contributor `
      -ServicePrincipalName $app.ApplicationId `
      -ErrorAction SilentlyContinue
  } # while
  Write-SuccessfulTaskInfo -Message "'$projectName' is registered with the Application Id '$($app.ApplicationId)'."
  Write-SuccessfulTaskInfo -Message "This should be used as the username when logging into Azure to deploy this project."
  Write-SuccessfulTaskInfo -Message "Use a Tenant Id of '$($account.Context.Tenant.TenantId)'."
}

task GetAzureSP {
  <#
    This task retrieves the existing Azure AD Service Principal for this application.
  #>
  $account = Login-AzureRmAccount
  Write-Host -Object "Getting Application from Azure AD" -foregroundcolor Yellow
  $app = Get-AzureRmADApplication -DisplayNameStartWith $projectName
  Write-SuccessfulTaskInfo -Message "'$projectName' is registered with the Application Id '$($app.ApplicationId)'."
  Write-SuccessfulTaskInfo -Message "This should be used as the username when logging into Azure to deploy this project."
  Write-SuccessfulTaskInfo -Message "Use a Tenant Id of '$($account.Context.Tenant.TenantId)'."
}

task ? -Description "Helper to display task info" {
  Write-Documentation
}

function Write-SuccessfulTaskInfo {
  [CmdLetBinding()]
  Param (
    [String] $Message
  )
  Write-Host -Object $Message -foregroundcolor Green
}

function Write-ProgressTaskInfo {
  [CmdLetBinding()]
  Param (
    [String] $Message
  )
  Write-Host -Object $Message -foregroundcolor White
}
