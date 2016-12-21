properties {
  $initMessage = 'Executed Init!'
  $testMessage = 'Executed Test!'
  $compileMessage = 'Executed Compile!'
  $cleanMessage = 'Executed Clean!'
}

task default -depends Test

task Test -depends Init, Compile, Clean { 
  $testMessage
}

task Compile -depends Init, Clean { 
  $compileMessage
}

task Clean { 
  $cleanMessage
}

task Init { 
	# Install Microsoft Azure App Service Tools v2.9.6 - Visual Studio 2015
  If (-not (Get-Package -ProviderName msi |
    Where-Object -Filter { $_.TagId -eq '4EB8A716-D680-3AF9-B117-BD568DD43B0D' })) {
      Write-Host 'Installing Microsoft Azure App Service Tools v2.9.6 - Visual Studio 2015...' -foregroundcolor Yellow
      $WebToolsAzurePath = Join-Path -Path $ENV:Temp -ChildPath 'WebToolsAzure2015.exe'
	    Invoke-WebRequest -Uri https://aka.ms/azfunctiontools -OutFile $WebToolsAzurePath
	    & $WebToolsAzurePath @('/install','/quiet','/norestart') | Out-Null
	    Remove-Item -Path $WebToolsAzurePath -Force
  } else {
    Write-Host 'Microsoft Azure App Service Tools v2.9.6 - Visual Studio 2015 is already installed' -foregroundcolor Green
  } # if

	$testMessage
}

task ? -Description "Helper to display task info" {
	Write-Documentation
}