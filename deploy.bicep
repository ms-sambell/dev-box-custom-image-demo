var location = 'australiaeast'
var tags = {}
var imagePublisher = 'contoso'
var prefix = 'devbox'

// Scripts
var commonScript = split(loadTextContent('installScripts/common.ps1'), ['\r','\n'])
var developerScript = split(loadTextContent('installScripts/developers.ps1'), ['\r','\n'])

module developerImage 'modules/main.bicep' = {
  name: 'developer-custom-image'
  params: {
    prefix: prefix
    imageName: 'developers'
    location: location
    imagePublisher: imagePublisher
    tags: tags
    customize: [
      {
        type: 'PowerShell'
        name: 'Common Setup'
        inline: commonScript
      }
      {
        type: 'PowerShell'
        name: 'Developer Tooling'
        inline: developerScript
      }
    ]
  }
}

