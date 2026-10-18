param name string
param location string
param appServicePlanId string

@secure()
param appInsightsConnectionString string

param keyVaultUri string
param tags object

resource webApp 'Microsoft.Web/sites@2023-12-01' = {
  name: name
  location: location
  kind: 'app,linux'
  tags: tags
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    serverFarmId: appServicePlanId
    httpsOnly: true
    siteConfig: {
      alwaysOn: true
      ftpsState: 'Disabled'
      http20Enabled: true
      minTlsVersion: '1.2'
      netFrameworkVersion: 'v8.0'
      linuxFxVersion: 'DOTNETCORE|8.0'
      appSettings: [
        {
          name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
          value: appInsightsConnectionString
        }
        {
          name: 'KEY_VAULT_URI'
          value: keyVaultUri
        }
      ]
    }
  }
}

output id string = webApp.id
output name string = webApp.name
output defaultHostname string = webApp.properties.defaultHostName
output principalId string = webApp.identity.principalId
