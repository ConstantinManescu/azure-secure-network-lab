# Azure Secure Network Infrastructure Lab

Hands-on Azure project I am building while preparing for AZ-104.

I have a networking and VoIP background, and I use this project to apply familiar concepts—network segmentation, access control, routing and troubleshooting—in Azure.

## Current stage

The initial network and compute validation were built manually in Azure and then captured in Bicep.

Completed:

- Resource Group with Project, Environment and Owner tags;
- Virtual Network: `10.10.0.0/16`;
- Management, frontend and backend subnets;
- Network Security Groups associated with each subnet;
- HTTP access allowed to the frontend subnet;
- TCP 8080 access to the backend subnet only from the frontend subnet;
- Temporary Ubuntu frontend VM deployed with HTTP validated from the Internet;
- Private Ubuntu backend VM deployed without a public IP address;
- Frontend-to-backend connectivity validated on TCP port 8080;
- Bicep compiled locally and reviewed with Azure CLI What-If;
- Temporary compute resources deleted after validation to control costs.

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