param name string
param location string
param environment string
param tags object

var skuName = environment == 'prod' ? 'P1v3' : 'B1'

resource plan 'Microsoft.Web/serverfarms@2023-12-01' = {
  name: name
  location: location
  kind: 'linux'
  tags: tags
  sku: {
    name: skuName
    capacity: 1
  }
  properties: {
    reserved: true
  }
}

output id string = plan.id
output name string = plan.name
