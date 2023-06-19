## Install Script for Developer Images

## Tooling List
$tools = @(
            "jq", "kubernetes-cli", "kubernetes-helm", "servicebusexplorer", 
            "terraform", "maven", "openjdk11"
        )

## Install Tools using Chocolatey from the list above
foreach ($tool in $tools) {
    choco install -y $tool
    Write-Host "Installed the tool: $tool"
}

## Chocolatey Logs
$chocolateyLogs = 'C:\ProgramData\chocolatey\logs\chocolatey.log'
Write-Output '## Chocolatey Installation Logs:'
Get-Content -Path $chocolateyLogs
