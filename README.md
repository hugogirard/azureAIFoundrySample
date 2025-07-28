# 🚀 Azure AI Foundry Infrastructure Deployment Guide

This guide will walk you **step by step** through deploying a secure, network-isolated Azure AI Foundry environment using GitHub Actions and Bicep. You’ll learn which **secrets** to create, the **order of GitHub Actions** to run, and what each deployment does.

---

## 1️⃣ Prerequisites & Required Secrets

Before starting, you’ll need to create several **GitHub repository secrets**. These are used by the workflows to authenticate and configure your Azure resources.

### 🔑 **Secrets to Create**

| Secret Name                              | Description                                               | Example Value                        |
|------------------------------------------|-----------------------------------------------------------|--------------------------------------|
| `LOCATION`                              | Azure region for deployment                               | `eastus2`                            |
| `RESOURCE_GROUP_NAME`                    | Resource group for core resources                         | `rg-ai-foundry-resources`            |
| `VNET_RESOURCE_GROUP_NAME`               | Resource group for the VNet                               | `rg-vnet`                            |
| `SUBNET_AGENT_ADDRESS_PREFIX`            | Address prefix for agent subnet                           | `10.0.1.0/24`                        |
| `JUMPBOX_SUBNET_ADDRESS_PREFIX`          | Address prefix for jumpbox subnet                         | `10.0.2.0/24`                        |
| `SUBNET_PRIVATE_ENDPOINT_ADDRESS_PREFIX` | Address prefix for private endpoint subnet                | `10.0.3.0/24`                        |
| `VNET_ADDRESS_PREFIX`                    | Address prefix for the VNet                               | `10.0.0.0/16`                        |
| `SUBNET_APIM_ADDRESS_PREFIX`             | Address prefix for APIM subnet                            | `10.0.4.0/24`                        |
| `PUBLISHER_EMAIL`                        | Email for APIM publisher                                  | `admin@contoso.com`                  |
| `PUBLISHER_NAME`                         | Name for APIM publisher                                   | `Contoso`                            |
| `VM_PASSWORD`                            | Password for the Windows jumpbox                          | `YourSecurePassword123!`             |
| `VM_ADMIN`                               | Admin username for the Windows jumpbox                    | `azureadmin`                         |
| `PA_TOKEN`                               | GitHub Personal Access Token (for secret creation)        |                                      |
| `AZURE_CREDENTIALS`                      | Azure Service Principal credentials (JSON)                | `{...}`                              |
| `AZURE_SUBSCRIPTION`                     | Azure Subscription ID                                     | `xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx` |

> 💡 **Tip:** To create the Azure Service Principal for `AZURE_CREDENTIALS`, run:
> ```bash
> az ad sp create-for-rbac --name foundry-iac --role contributor --scopes /subscriptions/<your-subscription-id>
> ```

---

## 2️⃣ Step 1: Deploy Core Infrastructure (`core.yml`)

**First, run the `core.yml` GitHub Action.**

### 🏗️ What does it create?

The [`infra/base/main.bicep`](infra/base/main.bicep) file provisions the **core network and foundational resources**:

- **Resource Groups** for VNet and core resources
- **Virtual Network (VNet)** with subnets:
  - Agent subnet
  - Private endpoint subnet
  - Jumpbox subnet
  - APIM subnet
- **Network Security Groups** for subnets
- **Private DNS Zones** for Azure services
- **Windows Jumpbox VM** for debugging
- **Azure Storage Account**
- **Azure CosmosDB Account**
- **Azure AI Search Service**
- **API Management (APIM) Service**
- **Private Endpoints** for secure, private connectivity

### 🗺️ **Architecture Diagram**

```mermaid
flowchart TD
    subgraph RG["Resource Group"]
        VNET["Virtual Network"]
        SA["Storage Account"]
        COSMOS["CosmosDB Account"]
        SEARCH["AI Search Service"]
        APIM["API Management"]
        JUMPBOX["Jumpbox VM"]
        DNS1["Private DNS Zone - Blob"]
        DNS2["Private DNS Zone - Cognitive Services"]
        DNS3["Private DNS Zone - CosmosDB"]
        DNS4["Private DNS Zone - OpenAI"]
        DNS5["Private DNS Zone - AI Services"]
        DNS6["Private DNS Zone - Search"]
    end
    VNET --> SA
    VNET --> COSMOS
    VNET --> SEARCH
    VNET --> JUMPBOX
    VNET --> APIM
    VNET --> DNS1
    VNET --> DNS2
    VNET --> DNS3
    VNET --> DNS4
    VNET --> DNS5
    VNET --> DNS6
```

### ⚙️ **How to run**

1. **Push your secrets** to the repository.
2. **Trigger** the `core.yml` workflow in GitHub Actions.
3. Wait for completion. The workflow will also **save outputs as new secrets** for the next steps.

---

## 3️⃣ Step 2: Deploy AI Foundry Resource (`foundry.yml`)

**Next, run the `foundry.yml` GitHub Action.**

### 🤖 What does it create?

The [`infra/foundry/main.bicep`](infra/foundry/main.bicep) file provisions the **Azure AI Foundry account**:

- **AI Foundry Account** (Cognitive Services, kind: `AIServices`)
- **VNet Injection** for network isolation (uses agent subnet)
- **System-assigned Managed Identity**
- **Disables public network access** (private only)

### 🗝️ **Secrets Used**

- `LOCATION`
- `SUBNET_AGENT_ID`
- `RESOURCE_GROUP_NAME`

### ⚙️ **How to run**

1. Ensure the previous workflow completed and secrets are available.
2. **Trigger** the `foundry.yml` workflow in GitHub Actions.
3. Wait for completion. The workflow will **save the Foundry resource name as a secret**.

---

## 4️⃣ Step 3: Deploy AI Foundry Project (`project.yml`)

**Finally, run the `project.yml` GitHub Action.**

### 📦 What does it create?

The [`infra/project/main.bicep`](infra/project/main.bicep) file provisions the **AI Foundry Project** and connects it to your existing resources:

- **AI Foundry Project** (with display name & description)
- **Connections** to:
  - CosmosDB (thread storage)
  - Azure Storage (agent data)
  - AI Search (vector storage)
- **Capability Host** for agent operations
- **RBAC Role Assignments** for secure access to resources
- **Private endpoints and DNS integration**

### 🗝️ **Secrets Used**

- `LOCATION`
- `AI_SEARCH_RESOURCE_NAME`
- `AZURE_COSMOS_DB_ACCOUNT_RESOURCE_NAME`
- `FOUNDRY_RESOURCE_NAME`
- `STORAGE_ACCOUNT_RESOURCE_NAME`
- `RESOURCE_GROUP_NAME`
- (Project-specific inputs: name, display name, description)

### ⚙️ **How to run**

1. Ensure all previous workflows completed and secrets are available.
2. **Trigger** the `project.yml` workflow in GitHub Actions.
3. Provide the required project inputs (name, display name, description).

---

## 📝 **Summary Table**

| Step | Workflow      | What it Deploys                                      | Run Order |
|------|--------------|------------------------------------------------------|-----------|
| 1    | `core.yml`   | Core network, DNS, storage, CosmosDB, search, jumpbox| 1st       |
| 2    | `foundry.yml`| AI Foundry account (private, VNet-injected)          | 2nd       |
| 3    | `project.yml`| AI Foundry project, connections, RBAC, capability host| 3rd       |

---

## 🛡️ **Security & Best Practices**

- **No public access**: All resources are network-isolated.
- **Private endpoints**: Used for all service connectivity.
- **Managed identities**: Used for secure, passwordless access.
- **RBAC**: Least-privilege roles assigned automatically.

---

## 🧹 **Cleanup**

To remove all resources, delete the resource groups or use the corresponding destroy workflows.

---

## 📚 **References**

- [infra/base/main.bicep](infra/base/main.bicep)
- [infra/foundry/main.bicep](infra/foundry/main.bicep)
- [infra/project/main.bicep](infra/project/main.bicep)
- [GitHub Actions Workflows](.github/workflows/)

---

Happy