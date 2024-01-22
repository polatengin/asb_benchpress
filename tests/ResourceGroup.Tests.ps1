BeforeAll {
  $Script:rgName = "benchpress-rg-${env:ENVIRONMENT_SUFFIX}"
}

Describe 'Resource Group Tests' {
  it 'Should contain a resource group with the given name' {
    Confirm-AzBPResourceGroup -ResourceGroupName $rgName | Should -BeSuccessful
  }
}
