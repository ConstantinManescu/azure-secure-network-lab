targetScope = 'resourceGroup'

param location string = resourceGroup().location

@description('Administrator username for the Linux virtual machines.')
param adminUsername string = 'azureuser'

var tags = {
  Project: 'azure-secure-network-lab'
  Environment: 'lab'
  Owner: 'ConstantinManescu'
}

var frontendCloudInit = '''
#cloud-config
package_update: true
packages:
  - nginx
runcmd:
  - systemctl enable nginx
  - systemctl restart nginx
  - echo '<h1>Azure Secure Network Lab</h1><p>Frontend VM is reachable through the subnet NSG.</p>' > /var/www/html/index.html
'''

var backendCloudInit = '''
#cloud-config
write_files:
  - path: /var/www/backend/index.html
    permissions: '0644'
    content: |
      <h1>Backend service</h1>
      <p>Accessible only from the frontend subnet on TCP 8080.</p>

  - path: /etc/systemd/system/backend-app.service
    permissions: '0644'
    content: |
      [Unit]
      Description=Simple backend service
      After=network.target

      [Service]
      ExecStart=/usr/bin/python3 -m http.server 8080 --directory /var/www/backend
      Restart=always

      [Install]
      WantedBy=multi-user.target

runcmd:
  - systemctl daemon-reload
  - systemctl enable backend-app
  - systemctl restart backend-app
'''

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

resource sshPublicKey 'Microsoft.Compute/sshPublicKeys@2024-03-01' existing = {
  name: 'ssh-key-vm-web-01'
}

resource frontendPublicIp 'Microsoft.Network/publicIPAddresses@2024-05-01' = {
  name: 'pip-vm-web-01'
  location: location
  tags: tags
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
    publicIPAddressVersion: 'IPv4'
  }
}

resource frontendNic 'Microsoft.Network/networkInterfaces@2024-05-01' = {
  name: 'vm-web-01521'
  location: location
  tags: tags
  properties: {
    enableAcceleratedNetworking: false
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: resourceId('Microsoft.Network/virtualNetworks/subnets', vnet.name, 'snet-frontend')
          }
          publicIPAddress: {
            id: frontendPublicIp.id
          }
        }
      }
    ]
  }
}

resource backendNic 'Microsoft.Network/networkInterfaces@2024-05-01' = {
  name: 'vm-app-01157'
  location: location
  tags: tags
  properties: {
    enableAcceleratedNetworking: false
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: resourceId('Microsoft.Network/virtualNetworks/subnets', vnet.name, 'snet-backend')
          }
        }
      }
    ]
  }
}

resource frontendVm 'Microsoft.Compute/virtualMachines@2024-03-01' = {
  name: 'vm-web-01'
  location: location
  tags: tags
  properties: {
    hardwareProfile: {
      vmSize: 'Standard_D2s_v3'
    }
    securityProfile: {
      securityType: 'TrustedLaunch'
      uefiSettings: {
        secureBootEnabled: true
        vTpmEnabled: true
      }
    }
    storageProfile: {
      imageReference: {
        publisher: 'Canonical'
        offer: 'ubuntu-24_04-lts'
        sku: 'server'
        version: 'latest'
      }
      osDisk: {
        name: 'vm-web-01_OsDisk_1_a66c11dc5e6e498c97f49814c33a0ffc'
        osType: 'Linux'
        createOption: 'FromImage'
        caching: 'ReadWrite'
        deleteOption: 'Delete'
        managedDisk: {
          storageAccountType: 'StandardSSD_LRS'
        }
      }
    }
    osProfile: {
      computerName: 'vm-web-01'
      adminUsername: adminUsername
      customData: base64(frontendCloudInit)
      linuxConfiguration: {
        disablePasswordAuthentication: true
        ssh: {
          publicKeys: [
            {
              path: '/home/azureuser/.ssh/authorized_keys'
              keyData: sshPublicKey.properties.publicKey
            }
          ]
        }
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: frontendNic.id
          properties: {
            primary: true
            deleteOption: 'Delete'
          }
        }
      ]
    }
  }
}

resource backendVm 'Microsoft.Compute/virtualMachines@2024-03-01' = {
  name: 'vm-app-01'
  location: location
  tags: tags
  properties: {
    hardwareProfile: {
      vmSize: 'Standard_D2s_v3'
    }
    securityProfile: {
      securityType: 'TrustedLaunch'
      uefiSettings: {
        secureBootEnabled: true
        vTpmEnabled: true
      }
    }
    storageProfile: {
      imageReference: {
        publisher: 'Canonical'
        offer: 'ubuntu-24_04-lts'
        sku: 'server'
        version: 'latest'
      }
      osDisk: {
        name: 'vm-app-01_OsDisk_1_8b40e843c1c34d73b91561196698a640'
        osType: 'Linux'
        createOption: 'FromImage'
        caching: 'ReadWrite'
        deleteOption: 'Delete'
        managedDisk: {
          storageAccountType: 'StandardSSD_LRS'
        }
      }
    }
    osProfile: {
      computerName: 'vm-app-01'
      adminUsername: adminUsername
      customData: base64(backendCloudInit)
      linuxConfiguration: {
        disablePasswordAuthentication: true
        ssh: {
          publicKeys: [
            {
              path: '/home/azureuser/.ssh/authorized_keys'
              keyData: sshPublicKey.properties.publicKey
            }
          ]
        }
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: backendNic.id
          properties: {
            primary: true
            deleteOption: 'Delete'
          }
        }
      ]
    }
  }
}
