# Azure Secure Network Infrastructure Lab

Hands-on Azure project I am building while preparing for AZ-104.

I have a networking and VoIP background, and I use this project to apply familiar concepts—network segmentation, access control, routing and troubleshooting—in Azure.

## Current stage

Repository setup is complete.

The first technical lab will create and document:

- a dedicated Resource Group;
- tags for ownership, environment and cost tracking;
- a Virtual Network with separate management, frontend and backend subnets;
- Network Security Groups with least-privilege rules.

## Working approach

I build each part in the Azure Portal first, validate it, document the result, then reproduce it with Azure CLI and Bicep.

To control costs, Azure resources are created only for lab sessions and deleted afterwards.

> Deploy → Test → Document → Destroy

## Planned areas

- Azure networking and NSGs
- Virtual machines and secure administration
- VNet peering
- Storage and Private Endpoints
- Microsoft Entra ID and RBAC
- Azure Monitor
- Azure CLI and Bicep
