BeforeAll {
  $Script:rgName = "benchpress-rg-${env:ENVIRONMENT_SUFFIX}"
  $Script:webAppName = "benchpress-web-${env:ENVIRONMENT_SUFFIX}"
}

Describe 'Service Plan Tests' {
  it 'Should contain a service plan with the given name' {
    #arrange
    $svcPlanName = "benchpress-hosting-plan-${env:ENVIRONMENT_SUFFIX}"

    #act
    Confirm-AzBPAppServicePlan -ResourceGroupName $rgName -AppServicePlanName $svcPlanName | Should -BeSuccessful
  }
}

Describe 'Action Group Tests' {
  it 'Should contain an email action group with the given name' {
    #arrange
    $agName = "benchpress-email-action-group-${env:ENVIRONMENT_SUFFIX}"

    #act
    Confirm-AzBPActionGroup -ResourceGroupName $rgName -ActionGroupName $agName | Should -BeSuccessful
  }
}

Describe 'Web Apps Tests' {
  it 'Should contain a web app with the given name' {
    #act
    Confirm-AzBPWebApp -ResourceGroupName $rgName -WebAppName $webAppName | Should -BeSuccessful
  }

  it 'Should have the web app availability state as normal' {
    #act
    $result = Confirm-AzBPWebApp -ResourceGroupName $rgName -WebAppName $webAppName

    #assert
    $result.ResourceDetails.AvailabilityState | Should -Be "Normal"
  }

  it 'Should have the web app works https only' {
    #act
    $result = Confirm-AzBPWebApp -ResourceGroupName $rgName -WebAppName $webAppName

    #assert
    $result.ResourceDetails.HttpsOnly | Should -Be $True
  }

  it 'Should contain application insights configuration in the web app' {
    #act
    $result = Confirm-AzBPWebApp -ResourceGroupName $rgName -WebAppName $webAppName

    #assert
    $result.ResourceDetails.SiteConfig.AppSettings[1].Name | Should -Be "APPLICATIONINSIGHTS_CONNECTION_STRING"
  }
}
