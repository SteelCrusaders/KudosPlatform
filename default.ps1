properties {
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
  } # if

  if (-not [String]::IsNullOrEmpty($azureUsername) -and `
    -not [String]::IsNullOrEmpty($azurePassword)) {
    $azureCredential = New-Object `
      -TypeName System.Management.Automation.PSCredential `
      -ArgumentList @($azureUsername, $azurePassword)
  } # if

  $initMessage = 'Executed Init!'
  $cleanMessage = 'Executed Clean!'
  $testMessage = 'Executed Test!'
  $buildMessage = 'Executed Build!'
  $deployMessage = 'Executed Deploy!'
}

task default -depends Test

task Deploy -depends Init, Build, Clean, Test {
  if (-not $azureCredential) {
    Write-Error -Message 'Deployment failed because Azure credentials not provided.'
    return
  }

  Login-AzureRmAccount `
    -Credential $azureCredential

  $deployMessage
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
    Write-Host 'Microsoft Azure App Service Tools v2.9.6 - Visual Studio 2015 is already installed' -foregroundcolor Green
  } else {
    Write-Host 'Installing Microsoft Azure App Service Tools v2.9.6 - Visual Studio 2015...' -foregroundcolor Yellow
    $WebToolsAzurePath = Join-Path -Path $ENV:Temp -ChildPath 'WebToolsAzure2015.exe'
    Invoke-WebRequest -Uri https://aka.ms/azfunctiontools -OutFile $WebToolsAzurePath
    & $WebToolsAzurePath @('/install','/quiet','/norestart') | Out-Null
    Remove-Item -Path $WebToolsAzurePath -Force
  } # if

  # Install Azure PowerShell Module so that we can Deploy components to Azure
  if (Get-Module -Name Azure -ListAvailable) {
    Write-Host 'Microsoft Azure PowerShell Module is already installed' -foregroundcolor Green
  } else {
    Write-Host 'Installing Microsoft Azure PowerShell Module...' -foregroundcolor Yellow
    Install-Module -Name Azure -Force -AllowClobber
  } # if

  $initMessage
}

task ? -Description "Helper to display task info" {
  Write-Documentation
}
