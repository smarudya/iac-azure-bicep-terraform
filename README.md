# Azure IaC: Bicep and Terraform

An interview-ready, dual-stack implementation of a small Azure application platform. Bicep and Terraform describe equivalent infrastructure; deploy **one stack per environment**, not both.

## Architecture

| Resource | Purpose |
| --- | --- |
| Resource Group | Lifecycle and access boundary for the workload |
| App Service Plan | Linux compute; B1 outside production and P0v3 in production |
| Linux Web App | Hosts a .NET 8 application with HTTPS, TLS 1.2+, and managed identity |
| Key Vault | Stores application secrets; access uses Azure RBAC instead of credentials |
| Application Insights | Collects application performance and request telemetry |
| Log Analytics | Centralizes Application Insights logs with 30-day retention |

See [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) for the diagram, decisions, and production-hardening recommendations.

## Prerequisites

- Azure CLI with the Bicep CLI installed
- Terraform 1.7 or newer
- An Azure account authorized to create resources and role assignments

Authenticate manually:

```console
az login
az account set --subscription "<subscription-id>"
```

## Deploy with Bicep

Review the placeholder tags and region in `bicep/parameters.dev.json`, then run:

```console
az deployment sub what-if \
  --location eastus \
  --template-file bicep/main.bicep \
  --parameters bicep/parameters.dev.json

az deployment sub create \
  --name cloudapp-dev \
  --location eastus \
  --template-file bicep/main.bicep \
  --parameters bicep/parameters.dev.json
```

The subscription-scope deployment creates the resource group and deploys scoped modules into it.

## Deploy with Terraform

Copy the examples, replace placeholders, and review the plan:

```console
cd terraform
cp terraform.tfvars.example terraform.tfvars
# Optional for team use: copy backend.tf.example to backend.tf and configure Azure Storage.
terraform init
terraform fmt -check
terraform validate
terraform plan -out=tfplan
terraform apply tfplan
```

Do not commit `terraform.tfvars`, backend configuration, plans, or state. For team use, store state in a versioned Azure Storage account with locking controls and tightly scoped access.

## Validation

Run `scripts/validate.ps1` on PowerShell or `scripts/validate.sh` on Bash. The scripts compile Bicep and run Terraform formatting and validation. GitHub Actions performs the same static checks without Azure credentials and never runs `apply`.

## Security and cost

- No real secrets, credentials, subscription IDs, or state files belong in this repository.
- The Web App uses managed identity and receives only the `Key Vault Secrets User` role.
- Key Vault purge protection prevents immediate destructive deletion.
- Public endpoints are retained for demo deployability. Use private endpoints, access restrictions, and private DNS for production.
- **Cost warning:** App Service, Application Insights, and Log Analytics can incur ongoing charges. Review current Azure pricing, telemetry volume, and the selected SKU; destroy demonstration resources when finished.

## Deloitte Senior Cloud Software Engineer — JD 48802 mapping

- **Azure engineering:** App Service, Key Vault, Azure Monitor, and identity-first security.
- **Infrastructure as Code:** equivalent modular Bicep and declarative Terraform implementations.
- **DevOps:** pull-request validation, deterministic configuration, environment parameters, and no production apply from CI.
- **Operational excellence:** centralized observability, resource tagging, documented trade-offs, outputs, and production-hardening guidance.
- **Security:** least-privilege RBAC, managed identity, TLS enforcement, secret-free examples, and protected infrastructure state.
