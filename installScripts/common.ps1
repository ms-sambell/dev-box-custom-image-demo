## Install Script for common organisation tooling

## Chocolatey Install
Set-ExecutionPolicy Bypass -Scope Process -Force; 
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; 
iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))


## Tooling List
$tools = @(
            "vscode", "7zip", "adobereader", "azcopy10", "azure-cli", 
            "flux", "gh", "git", "github-desktop", 'pwsh'
        )

## Install Tools using Chocolatey from the list above
foreach ($tool in $tools) {
    choco install -y $tool
    Write-Host "Installed the tool: $tool"
}

## VsCode Extensions
## https://community.chocolatey.org/packages?q=vscode