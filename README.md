# BenchPress sample project

Sample project with BenchPress tests implemented.

## Requirements

BenchPress uses PowerShell and the Azure Az PowerShell module. Users should use Pester as their testing framework and runner. To use BenchPress, have the following installed:

- [Az PowerShell module](https://learn.microsoft.com/en-us/powershell/azure/install-az-ps?view=azps-9.3.0)
- [Pester](https://pester.dev/docs/introduction/installation)
- [Service Principal](https://learn.microsoft.com/en-us/azure/active-directory/develop/howto-create-service-principal-portal) created for your application.

## Authenticating to Azure

There are two primary mechanisms to authenticate to Azure using BenchPress, either by using an [Application Service Principal](https://learn.microsoft.com/en-us/azure/active-directory/develop/app-objects-and-service-principals?tabs=browser#service-principal-object) or a [Managed Identity](https://learn.microsoft.com/en-us/azure/active-directory/managed-identities-azure-resources/overview) for Azure environments.

- For Managed Identity:

  Set the following environment variables so that the BenchPress tools can deploy (if necessary), confirm, and destroy (if necessary) resources in the target subscription.

  - `AZ_USE_MANAGED_IDENTITY="true"` - A boolean flag that instructs BenchPress to authenticate using the Managed Identity
  - `AZ_SUBSCRIPTION_ID` - The Subscription ID of the Subscription within the Tenant to access

- For Application Service Principal:

  Set the following environment variables so that the BenchPress tools can deploy (if necessary), confirm, and destroy (if necessary) resources in the target subscription.

  - `AZ_APPLICATION_ID` - The Service Principal's application ID
  - `AZ_TENANT_ID` - The Tenant ID of the Azure Tenant to access
  - `AZ_SUBSCRIPTION_ID` - The Subscription ID of the Subscription within the Tenant to access
  - `AZ_ENCRYPTED_PASSWORD` - The **encrypted** password of the Service Principal. This value must be an encrypted string. It is the responsibility of the user to encrypt the Service Principal password. The following PowerShell code can be used to encrypt the Service Principal password before saving as an environment variable: `<raw password> | ConvertTo-SecureString -AsPlainText -Force | ConvertFrom-SecureString`. This takes the raw password and converts the password to a SecureString. This SecureString must then be converted to a String. `ConvertFrom-SecureString` will take the SecureString and convert it to an encrypted string. This value must then be saved as an environment variable. This ensures that the BenchPress code never uses the raw password at any point.

  Example command to create a Service Principal is;

  ```powershell
  $AZURE_RBAC = $(az ad sp create-for-rbac --name "BenchPress.Module.Contributor" --role contributor --scopes /subscriptions/$(az account show --query "id" --output "tsv"))
  ```

  You can either use a `.env` file and pass in the environment variables locally with a script, or you must load each variable through the command line using:

  ```PowerShell
  $env:AZ_APPLICATION_ID="<sample-application-id>"
  $env:AZ_TENANT_ID="<sample-tenant-id>"
  $env:AZ_SUBSCRIPTION_ID="<sample-subscription-id>"
  $env:AZ_ENCRYPTED_PASSWORD="<sample-encrypted-password>"
  ```

  Example command to set the environment variables locally is;

  ```powershell
  $env:AZ_SUBSCRIPTION_ID = "$(az account show --query 'id' --output tsv)"
  $env:AZ_TENANT_ID = "$(az account show --query 'tenantId' --output tsv)"
  $env:AZ_APPLICATION_ID = $($AZURE_RBAC | ConvertFrom-Json).appId
  $env:AZ_ENCRYPTED_PASSWORD = $($AZURE_RBAC | ConvertFrom-Json).password | ConvertTo-SecureString -AsPlainText -Force | ConvertFrom-SecureString
  ```

  You can confirm if these are set up right on your local powershell using:

  ```PowerShell
  [Environment]::GetEnvironmentVariables()
  ```

  > Afterwards, to clean up the Service Principal, you can run the following command:
  >
  > ```powershell
  > az ad sp delete --id $($AZURE_RBAC | ConvertFrom-Json).appId
  > ```

## Setting up the project

1. Clone the repository, open a PowerShell terminal.

1. Follow the [Authenticating to Azure](#authenticating-to-azure) section to set up your environment variables.

1. Run the [deploy.ps1](deploy.ps1) script to deploy the demo application infrastructure and the demo application.

  ```Powershell
  ./deploy-demoapp.ps1
  ```

## Running test files

1. Open a PowerShell terminal, navigate to `tests` folder.

1. Follow the [Authenticating to Azure](#authenticating-to-azure) section to set up your environment variables.

1. Invoke `./ResourceGroup.Tests.ps1` to run _Resource Group_ related tests

  ```PowerShell
  ./ResourceGroup.Tests.ps1

  Starting discovery in 1 files.
  Discovery found 1 tests in 2ms.
  Running tests.
  [+] /home/azureuser/p/asb_benchpress/tests/ResourceGroup.Tests.ps1 688ms (680ms|6ms)
  Tests completed in 688ms
  Tests Passed: 1, Failed: 0, Skipped: 0 NotRun: 0
  ```

1. Invoke `./StorageAccount.Tests.ps1` to run _Storage Account_ related tests

  ```PowerShell
  ./StorageAccount.Tests.ps1

  Starting discovery in 1 files.
  Discovery found 9 tests in 3ms.
  Running tests.
  [+] /home/azureuser/p/asb_benchpress/tests/StorageAccount.Tests.ps1 17.18s (17.16s|17ms)
  Tests completed in 17.18s
  Tests Passed: 9, Failed: 0, Skipped: 0 NotRun: 0
  ```

1. Invoke `./WebApp.Tests.ps1` to run _Web App_ related tests

  ```PowerShell
  ./WebApp.Tests.ps1

  Starting discovery in 1 files.
  Discovery found 6 tests in 3ms.
  Running tests.
  [+] /home/azureuser/p/asb_benchpress/tests/WebApp.Tests.ps1 16.07s (16.04s|26ms)
  Tests completed in 16.07s
  Tests Passed: 6, Failed: 0, Skipped: 0 NotRun: 0
  ```

1. Invoke `Invoke-Pester` to run _all_ tests

  ```PowerShell
  Invoke-Pester

  Starting discovery in 3 files.
  Discovery found 16 tests in 15ms.
  Running tests.
  [+] /home/azureuser/p/asb_benchpress/tests/ResourceGroup.Tests.ps1 312ms (305ms|6ms)
  [+] /home/azureuser/p/asb_benchpress/tests/StorageAccount.Tests.ps1 11.92s (11.88s|24ms)
  [+] /home/azureuser/p/asb_benchpress/tests/WebApp.Tests.ps1 15.7s (15.67s|26ms)
  Tests completed in 27.93s
  Tests Passed: 16, Failed: 0, Skipped: 0 NotRun: 0
  ```
