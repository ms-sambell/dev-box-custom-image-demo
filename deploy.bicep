var location = 'australiaeast'
var tags = {}
var imagePublisher = 'valeriia'
var prefix = 'devbox'


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
        name: 'Install Choco and Vscode'
        inline: [
          'Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString(\'https://community.chocolatey.org/install.ps1\'))"'
          'choco install -y vscode'
          'choco install 7zip -y'
          'choco install adobereader -y'
          'choco install azcopy10 -y'
          'choco install azure-cli -y'
          'choco install azure-iot-installer -y'
          'choco install docker-desktop -y'
          'choco install Firefox -y'
          'choco install flux -y'
          'choco install gh -y'
          'choco install git -y'
          'choco install github-desktop -y'
          'choco install GoogleChrome -y'
          'choco install jq -y'
          'choco install kubernetes-cli -y'
          'choco install kubernetes-helm -y'
          'choco install pwsh -y'
          'choco install servicebusexplorer -y'
          'choco install terraform -y'
          'choco install git -y'
        ]
      }
    ]
  }
}

module dataScienceImage 'modules/main.bicep' = {
  name: 'datascience-custom-image'
  params: {
    prefix: prefix
    imageName: 'dataScience'
    location: location
    imagePublisher: imagePublisher
    tags: tags
    customize: [
      {
        type: 'PowerShell'
        name: 'Install Choco and Vscode'
        inline: [
          'Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString(\'https://community.chocolatey.org/install.ps1\'))"'
          'choco install -y vscode'
        ]
      }
    ]
  }
}
