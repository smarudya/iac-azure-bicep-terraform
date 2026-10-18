targetScope = 'subscription'

@description('Short workload name used in resource names.')
param applicationName string = 'cloudapp'

@allowed([
  'dev'
  'test'
  'prod'
])
param environment string

@description('Azure region for all resources.')
param location string

@description('Resource tags applied to every supported resource.')
param tags object = {}

var resourceGroupName = 'rg-${applicationName}-${environment}'
var uniqueSuffix = take(uniqueString(subscription().id, resourceGroupName), 8)
var commonTags = union(tags, {
  application: applicationName
  environment: environment
  managedBy: 'bicep'
})

// Module symbolic name must NOT be `resourceGroup` — that shadows az.resourceGroup().
module rgDeploy 'modules/resource-group.bicep' = {
  name: 'resource-group'
  params: {
    name: resourceGroupName
    location: location
    tags: commonTags
  }
}

module logAnalytics 'modules/log-analytics.bicep' = {
  name: 'log-analytics'
  scope: resourceGroup(resourceGroupName)
  params: {
    name: 'log-${applicationName}-${environment}'
    location: location
    tags: commonTags
  }
  dependsOn: [
    rgDeploy
  ]
}

module appInsights 'modules/application-insights.bicep' = {
  name: 'application-insights'
  scope: resourceGroup(resourceGroupName)
  params: {
    name: 'appi-${applicationName}-${environment}'
    location: location
    workspaceResourceId: logAnalytics.outputs.id
    tags: commonTags
  }
}

module appServicePlan 'modules/app-service-plan.bicep' = {
  name: 'app-service-plan'
  scope: resourceGroup(resourceGroupName)
  params: {
    name: 'asp-${applicationName}-${environment}'
    location: location
    environment: environment
    tags: commonTags
  }
  dependsOn: [
    rgDeploy
  ]
}

module keyVault 'modules/key-vault.bicep' = {
  name: 'key-vault'
  scope: resourceGroup(resourceGroupName)
  params: {
    name: 'kv-${applicationName}-${environment}-${uniqueSuffix}'
    location: location
    tags: commonTags
  }
  dependsOn: [
    rgDeploy
  ]
}

module webApp 'modules/web-app.bicep' = {
  name: 'web-app'
  scope: resourceGroup(resourceGroupName)
  params: {
    name: 'app-${applicationName}-${environment}-${uniqueSuffix}'
    location: location
    appServicePlanId: appServicePlan.outputs.id
    appInsightsConnectionString: appInsights.outputs.connectionString
    keyVaultUri: keyVault.outputs.uri
    tags: commonTags
  }
}

module keyVaultAccess 'modules/key-vault-access.bicep' = {
  name: 'key-vault-access'
  scope: resourceGroup(resourceGroupName)
  params: {
    keyVaultName: keyVault.outputs.name
    principalId: webApp.outputs.principalId
  }
}

output resourceGroupName string = resourceGroupName
output webAppHostname string = webApp.outputs.defaultHostname
output keyVaultName string = keyVault.outputs.name
output applicationInsightsName string = appInsights.outputs.name
