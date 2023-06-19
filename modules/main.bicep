@description('The location all resources will be deployed to')
param location string = resourceGroup().location

@description('An array of additional regions to replicate images to')
param additionalLocations array = []

@description('A prefix to add to the start of all resource names. Note: A "unique" suffix will also be added')
param prefix string = 'devboxcustom'

@description('The name of the image to be created')
param imageName string = 'devboxCustImageDef'

@description('The name of the image publisher')
param imagePublisher string = 'microsoft-demo'

@description('Tags to be applied to all deployed resources')
param tags object = {
  'Demo-Name': 'DevBoxCustomImage'
}


@description('Tasks to install on the vm')
param customize array
param guid string = newGuid()
var uniqueName = take('${prefix}_${imageName}_${guid}',64)

// Todo: make params
var imageOffer = prefix
var imageSku = '1-0-0'
var imageBuilderSku = 'Standard_D8ds_v4'
var imageBuilderDiskSize = 256
var runOutputName = '${imageName}_output'

resource aibIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' = {
  name: take('${prefix}_${imagePublisher}',64)
  location: location
  tags: tags
}

// Todo: Make custom role not full contributor
resource contributorRoleDefinition 'Microsoft.Authorization/roleDefinitions@2018-01-01-preview' existing = {
  scope: subscription()
  name: 'b24988ac-6180-42a0-ab88-20f7382dd24c'
}

resource roleAssignment 'Microsoft.Authorization/roleAssignments@2020-10-01-preview' = {
  scope: resourceGroup()
  name: sys.guid(aibIdentity.id, contributorRoleDefinition.id)
  properties: {
    roleDefinitionId: contributorRoleDefinition.id
    principalId: aibIdentity.properties.principalId
    principalType: 'ServicePrincipal'
  }
}

resource computeGallery 'Microsoft.Compute/galleries@2022-03-03' = {
  name: take('${prefix}_${imagePublisher}',64)
  location: location
  properties: {}
  tags: tags

resource image 'images@2022-03-03' = {
  name: imageName
  location: location
  properties: {
    features: [
      {
        name: 'SecurityType'
        value: 'TrustedLaunch'
      }
    ]
    identifier: {
      offer: imageOffer
      publisher: imagePublisher
      sku: imageSku
    }
    osState: 'Generalized'
    osType: 'Windows'
    hyperVGeneration: 'V2'
  }
  tags: tags
}
}

resource imageTemplate 'Microsoft.VirtualMachineImages/imageTemplates@2022-02-14' = {
  name: uniqueName
  location: location
  properties: {
    buildTimeoutInMinutes: 100
    vmProfile: {
      vmSize: imageBuilderSku
      osDiskSizeGB: imageBuilderDiskSize
    }
    source: {
      type: 'PlatformImage'
      publisher: 'MicrosoftWindowsDesktop'
      offer: 'Windows-11'
      sku: 'win11-21h2-avd'
      version: 'latest'
    }
    // This is where we customise the image
    customize: customize
    distribute: [
      {
        galleryImageId: computeGallery::image.id
        replicationRegions: concat([location], additionalLocations)
        runOutputName: runOutputName
        artifactTags: {
          source: 'azureVmImageBuilder'
          baseosimg: 'win11multi'
        }
        type: 'SharedImage'
      }
    ]
  }
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${aibIdentity.id}': {}
    }
  }
  tags: tags
}

var pwshBuildCommand = 'Invoke-AzResourceAction -ResourceName "${uniqueName}" -ResourceGroupName "${resourceGroup().name}" -ResourceType "Microsoft.VirtualMachineImages/imageTemplates" -ApiVersion "2020-02-14" -Action Run -Force'

@description('This resource invokes a command to start the AIB build')
resource imageTemplate_build 'Microsoft.Resources/deploymentScripts@2020-10-01' =  {
  name: '${uniqueName}-build-trigger'
  location: location
  kind: 'AzurePowerShell'
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${aibIdentity.id}': {}
    }
  }
  dependsOn: [
    imageTemplate
    roleAssignment
  ]
  properties: {
    forceUpdateTag: guid
    azPowerShellVersion: '6.2'
    scriptContent: pwshBuildCommand
    timeout: 'PT1H'
    cleanupPreference: 'OnSuccess'
    retentionInterval: 'P1D'
  }
}
