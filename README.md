# KudosPlatform

[![Stories in Ready](https://badge.waffle.io/IAG-NZ/KudosPlatform.png?label=ready&title=Ready)](https://waffle.io/IAG-NZ/KudosPlatform)
[![Join the chat at https://gitter.im/KudosPlatform/Lobby](https://badges.gitter.im/KudosPlatform/Lobby.svg)](https://gitter.im/KudosPlatform/Lobby?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)
[![Build status](https://ci.appveyor.com/api/projects/status/n234885s6cgmeb45/branch/master?svg=true)](https://ci.appveyor.com/project/IAG-NZ/kudosplatform/branch/master)

The IAG-NZ Dev Guild KudosPlatform for gamifying Yammer.

## Requirements

To work with this project you will need to have installed:

1. Windows Management Framework 5.0
   - Windows 10/Windows Server 2016 - already installed.
   - Earlier Windows versions - [from this location](https://www.microsoft.com/en-us/download/details.aspx?id=50395).
2. Visual Studio 2015 (Community, Pro or Enterpirse)
   - Community can be downloaded and installed free [from this location](https://www.visualstudio.com/vs/community/).
3. An Azure account with a valid subscription
   - If you have an MSDN account then you will be able to use this to get a free Azure subscription with a free monthly credit allowance.
4. Your Azure subscription must contain an Azure Active Directory
   - It will have a default one if you haven't deleted it.
   - This is required to create a service principal for the PowerShell automation to use to install this project.
   - See [this page](https://docs.microsoft.com/en-us/azure/azure-resource-manager/resource-group-authenticate-service-principal) for more information.

## PSake

This project includes a [PSake](https://github.com/psake/psake) file that defines tasks for initializing the development/build environment, building, installing and deploying the project.

To use the PSake file (default.ps1), you will need to install PSake.

> To install PSake:

1. At an Administrator Windows PowerShell console enter:

```PowerShell
Install-Module -Name PSake
```

### Init

The _Init_ task will initialize the build or development environment:

```PowerShell
Invoke-PSake Init
```

> Note: This task could take over 10 minutes to complete, but only needs to be performed once on a node.

### Clean

The _Clean_ task will clean the build environment:

```PowerShell
Invoke-PSake Clean
```

### Build

The _Build_ task will build the project:

```PowerShell
Invoke-PSake Build
```

### Install

The _Install_ task will build the project and then install it to Azure.
Azure credentials will need to be provided:

```PowerShell
Invoke-PSake Install -parameters @{ azureUSername = '03becdd7-3395-4bf2-8eff-528b7dcc9a07'; azurePassword ='P@ssword!1'; azureTenantId = 'fef06518-9f81-4cff-946a-083d33dd17db' }
```

### CreateAzureSP

The _CreateAzureSP_ task will create the service principal in Azure AD that will be used as the account to login to Azure to install this project.
This only needs to be done once for any Azure account that will have the KudosPlatform installed to.

```PowerShell
Invoke-PSake CreateAzureSP -parameters @{ azureADDomain = 'MyAzureAppDomain'; azurePassword = 'P@ssword!1' }
```

### GetAzureSP

The _GetAzureSP_ task will return service principal name in Azure AD that should be used as the username for an account to login to Azure to install this project.

```PowerShell
Invoke-PSake GetAzureSP
```


## Versions

### Unreleased

- Renamed PSake _Compile_ task to _Build_ to match usual name.
- Added Azure PowerShell Module installation to PSake init to allow deployment.
- Added initial _Deploy_ task to PSake.
