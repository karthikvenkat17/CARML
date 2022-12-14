@maxLength(24)
@description('Conditional. The name of the parent Storage Account. Required if the template is used in a standalone deployment.')
param storageAccountName string

@description('Required. The local user name to be used for SFTP Authentication.')
param name string

@description('Required. Indicates whether shared key exists. Set it to false to remove existing shared key.')
param hasSharedKey bool 

@description('Required. Indicates whether ssh key exists. Set it to false to remove existing SSH key.')
param hasSshKey bool

@description('Required. Indicates whether ssh password exists. Set it to false to remove existing SSH password.')
param hasSshPassword bool

@description('Optional. The local user home directory.')
param homeDirectory string = ''

@description('Required. The permission scopes of the local user.')
param permissionScopes array

@description('Optional. The local user ssh authorized keys for SFTP.')
param sshAuthorizedKeys array



@description('Optional. Enable telemetry via a Globally Unique Identifier (GUID).')
param enableDefaultTelemetry bool = true

resource defaultTelemetry 'Microsoft.Resources/deployments@2021-04-01' = if (enableDefaultTelemetry) {
  name: 'pid-47ed15a6-730a-4827-bcb4-0fd963ffbd82-${uniqueString(deployment().name)}'
  properties: {
    mode: 'Incremental'
    template: {
      '$schema': 'https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#'
      contentVersion: '1.0.0.0'
      resources: []
    }
  }
}


resource storageAccount 'Microsoft.Storage/storageAccounts@2021-09-01' existing = {
  name: storageAccountName
}

resource localUsers 'Microsoft.Storage/storageAccounts/localUsers@2021-09-01' = {
  name: name
  parent : storageAccount
  properties: {
    hasSharedKey: hasSharedKey
    hasSshKey: hasSshKey
    hasSshPassword: hasSshPassword
    homeDirectory: homeDirectory
    permissionScopes: permissionScopes
    sshAuthorizedKeys: sshAuthorizedKeys
  }
}

@description('The name of the local user created for SFTP Authentication.')
output localUser string = localUsers.name

@description('The permission scopes granted for the local user.')
output permissionScopes array = localUsers.properties.permissionScopes

@description('The resource group of the deployed management policy.')
output resourceGroupName string = resourceGroup().name

@description('The resource ID of the local user resource created.')
output resourceId string = localUsers.id
