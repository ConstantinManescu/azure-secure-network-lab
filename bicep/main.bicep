targetScope = 'resourceGroup'

param location string = resourceGroup().location

var tags = {
  Project: 'azure-secure-network-lab'
  Environment: 'lab'
  Owner: 'ConstantinManescu'
}

resource nsgManagement 'Microsoft.Network/networkSecurityGroups@2024-05-01' = {
  name: 'nsg-management'
  location: location
  tags: tags
}

resource nsgFrontend 'Microsoft.Network/networkSecurityGroups@2024-05-01' = {
  name: 'nsg-frontend'
  location: location
  tags: tags
}

resource allowHttpFromInternet 'Microsoft.Network/networkSecurityGroups/securityRules@2024-05-01' = {
  parent: nsgFrontend
  name: 'Allow-HTTP-From-Internet'
  properties: {
    priority: 100
    direction: 'Inbound'
    access: 'Allow'
    protocol: 'Tcp'
    sourcePortRange: '*'
    destinationPortRange: '80'
    sourceAddressPrefix: 'Internet'
    destinationAddressPrefix: '*'
  }
}

resource nsgBackend 'Microsoft.Network/networkSecurityGroups@2024-05-01' = {
  name: 'nsg-backend'
  location: location
  tags: tags
}

resource allowAppFromFrontend 'Microsoft.Network/networkSecurityGroups/securityRules@2024-05-01' = {
  parent: nsgBackend
  name: 'Allow-App-From-Frontend'
  properties: {
    priority: 100
    direction: 'Inbound'
    access: 'Allow'
    protocol: 'Tcp'
    sourcePortRange: '*'
    destinationPortRange: '8080'
    sourceAddressPrefix: '10.10.2.0/24'
    destinationAddressPrefix: '*'
  }
}

resource vnet 'Microsoft.Network/virtualNetworks@2024-05-01' = {
  name: 'vnet-lab-weu'
  location: location
  tags: tags
  properties: {
     addressSpace: {
      addressPrefixes: [
        '10.10.0.0/16'
      ]
    }
    encryption: {
      enabled: false
      enforcement: 'AllowUnencrypted'
    }
    privateEndpointVNetPolicies: 'Disabled'
    subnets: [
      {
        name: 'snet-backend'
        properties: {
          addressPrefixes: [
            '10.10.3.0/24'
          ]
          networkSecurityGroup: {
            id: nsgBackend.id
          }
        }
      }
      {
        name: 'snet-frontend'
        properties: {
          addressPrefixes: [
            '10.10.2.0/24'
          ]
          networkSecurityGroup: {
            id: nsgFrontend.id
          }
        }
      }
      {
        name: 'snet-management'
        properties: {
          addressPrefixes: [
            '10.10.1.0/24'
         ]
          networkSecurityGroup: {
            id: nsgManagement.id
          }
        }
      }
    ]
  }
}
