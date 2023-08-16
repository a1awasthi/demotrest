@minLength(5)
param adminusername string
@minLength(5)
@maxLength(15)
@secure()
param adminpassword string
param location string= resourceGroup().location
param publicip string= 'pubiptest'
param virtualnetworkname string= 'testvnet'
param subnetdemo string= 'Subnet-1'
param nsgnew string= 'testnsg'

resource pubip 'Microsoft.Network/publicIPAddresses@2023-04-01' = {
  name: publicip
  location: location
  sku: {
    name: 'Basic'
  }
  properties: {
    publicIPAllocationMethod: 'Dynamic'
  }
}
resource networkSecurityGroup 'Microsoft.Network/networkSecurityGroups@2019-11-01' = {
  name: nsgnew
  location: location
  properties: {
    securityRules: [
      {
        name: 'ALL_ALLOW_yesterday_today'
        properties: {
          description: 'description'
          protocol: '*'
          sourcePortRange: '*'
          destinationPortRange: '*'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 100
          direction: 'Inbound'
        }
      }
    ]
  }
}
resource virtualNetwork 'Microsoft.Network/virtualNetworks@2019-11-01' = {
  name: virtualnetworkname
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.0.0.0/16'
      ]
    }
    subnets: [
      {
        name: subnetdemo
        properties: {
          addressPrefix: '10.0.0.0/24'
          networkSecurityGroup: {
            id: networkSecurityGroup.id
          }
        }
      }
      
    ]
  }
}

resource networkInterface 'Microsoft.Network/networkInterfaces@2020-11-01' = {
  name: 'demonic'
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'pipnic'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: resourceId('Microsoft.Networks/Virtualnetworks/Subnets', virtualnetworkname, subnetdemo )
          }
        }
      }
    ]
  }
  dependsOn: [
    virtualNetwork
  ]
}

resource windowsVM 'Microsoft.Compute/virtualMachines@2020-12-01' = {
  name: 'testvm'
  location: location
  properties: {
    hardwareProfile: {
      vmSize: 'Standard_A2_v2'
    }
    osProfile: {
      computerName: 'testvm1'
      adminUsername: adminusername
      adminPassword: adminpassword
    }
    storageProfile: {
      imageReference: {
        publisher: 'MicrosoftWindowsServer'
        offer: 'WindowsServer'
        sku: '2012-R2-Datacenter'
        version: 'latest'
      }
      osDisk: {
        name: 'name'
        caching: 'ReadWrite'
        createOption: 'FromImage'
      }

            }
            networkProfile: {
              networkInterfaces: [
                {
                  id: networkInterface.id
                }
              ]
            }
    }
    
  }



