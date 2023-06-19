# Custom DevBox Image Demo

## Overview

This repository creates a Azure Image Builder template which will automatically trigger an Image build. This image can then be added to dev definition and used by DevBox to provision workstations. The image produced can then be used by Dev Box.

![architecture](.img/dev-box-arch.png)

## Requirements

- Install the AZ CLI tool
- Connect to your Azure tenant using `az login`
- Connect to the appropriate subscription `az account set --subscription $subscriptionID`
- An existing Resource Group
- Ensure that the correct resource providers are enabled on the subscription [resource provider docs](https://learn.microsoft.com/en-us/azure/dev-box/how-to-customize-devbox-azure-image-builder#create-a-windows-image-and-distribute-it-to-azure-compute-gallery)

## What's Included

The code in this repository will create the following resources in Azure:

- **Azure Compute Gallery:** A gallery for Virtual Machine images to be stored and distributed for consumption.
- **VM Image Definition:** The Image definitions that are versioned and publish to the Compute Gallery.
- **Image Template:** Azure Image Builder template to create a Virtual Machine image which can be consumed by DevBox.
- **Deployment Script:** Triggers the 'build' process a new image based on the Image Template.
- **Managed Identity:** This will be used by the VM Image definition to spin-up a VM and snapshot the image after the scripts are installed.

## Custom Image Changes

The scripts that Azure Image Builder will use to build the image template for DevBox are in the `installScripts` directory. The reason the scripts are split out of the Bicep module is to:

- Simplify developing, testing and improve readability.
- Allow linting on scripts and encourage the use of advanced Powershell.
- Reduces the error-rate of needing to write PowerShell within a Bicep module.
- Enables reusing and sharing scripts.

### Scripts

- **common.ps1:** Used for any mandatory or shared tooling that should be installed on any DevBox image. This saves needing to store and write the same install commands for different images. As well as providing an area for operation teams to define proxy or TLS inspection certificates.
- **developers.ps1:** An example of how to setup a install script for a specific persona. This script is passed through to the `deploy.bicep` script and used in the `developerImage` module.

To create a new profile, simply copy the existing `developerImage` module and update the appropriate fields.

## Installation Instructions

1. Create a resource group in Azure to store the custom image resources in.
1. Clone this repository and update the `deploy.bicep` file variables.
1. (Optional) - Update the PowerShell scripts in the `installScripts` directory.
1. Run the following command to deploy the resources: `az deployment group create --name devboxtest --resource-group $yourResourceGroup --template-file deploy.bicep`. <br> **Note:** The Image build process is slow and can take 30 minutes.
1. Assign the DevCenter instance access to the Resource Group used in the above steps.
1. Add the compute gallery to your DevBox instance.
1. Then add the new image to a dev box definition. <br> **Note:** The validation process can take 15 minutes.
1. Test the new custom image.

### Troubleshooting

To troubleshoot the Custom Image creation and installation of the scripts, follow the [troubleshooting guide](https://learn.microsoft.com/en-us/azure/virtual-machines/linux/image-builder-troubleshoot).

The code in the developer.ps1 file writes the chocolatey log file to the console so it can be picked up in the above troubleshooting guide.

## Documentation

- [What is Microsoft Dev Box?](https://learn.microsoft.com/en-us/azure/dev-box/overview-what-is-microsoft-dev-box)
- [DevBox QuickStart](https://github.com/luxu-ms/Devbox-ADE-Infra/tree/main)
