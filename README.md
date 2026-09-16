# Azure Secure Network Infrastructure Lab

A cost-conscious, hands-on Azure AZ-104 portfolio project focused on secure networking, governance, identity, monitoring, and Infrastructure as Code.

## Project goal

Build a secure and reproducible Azure environment incrementally, document each decision, validate the configuration, and remove Azure resources after testing to control costs.

This project is designed to demonstrate practical Azure Administrator skills and networking knowledge.

## Planned technologies

- Azure Resource Groups, tags, and Cost Management
- Azure Virtual Networks, subnets, and Network Security Groups
- Linux virtual machines
- VNet peering
- Azure Storage and Private Endpoints
- Microsoft Entra ID and Azure RBAC
- Azure Monitor, Log Analytics, and alerts
- Azure CLI
- Bicep
- GitHub Actions

## Cost safety policy

This project follows a strict cost-control workflow:

> Deploy → Learn / Test → Capture evidence → Destroy

No virtual machines, public IP addresses, Bastion hosts, or other billable resources will be left running after a lab session.

Azure infrastructure will be deployed into a dedicated Resource Group and deleted when the session is complete. Source code, documentation, architecture diagrams, and screenshots remain available in this repository.

## Project status

| Lab | Scope | Status |
|---|---|---|
| Lab 0 | Cost safety and GitHub repository | In progress |
| Lab 1 | Resource Group, tags, and governance | Planned |
| Lab 2 | VNet, subnets, and NSGs | Planned |
| Lab 3 | Linux VM and secure administration | Planned |
| Lab 4 | VNet peering | Planned |
| Lab 5 | Storage and Private Endpoint | Planned |
| Lab 6 | Entra ID and RBAC | Planned |
| Lab 7 | Monitoring and alerts | Planned |
| Lab 8 | Azure CLI, Bicep, and GitHub Actions | Planned |

## Repository structure

```text
azure-secure-network-lab/
├── architecture/       # Architecture diagrams
├── bicep/              # Infrastructure as Code
├── docs/               # Lab notes and decisions
├── scripts/            # Deployment and cleanup scripts
└── screenshots/        # Azure Portal validation evidence
