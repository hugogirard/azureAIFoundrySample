````markdown
# AI Foundry Infrastructure Setup

This repository contains the necessary configurations and scripts to set up the foundational infrastructure for AI Foundry projects on Azure. It leverages GitHub Actions for CI/CD to automate the deployment of resources using ARM templates and Bicep files.

## 🚀 Setting Up Secrets for the Pipeline

After cloning the repository, you need to set up the required secrets to ensure the pipeline runs successfully. These secrets are essential for deploying the core resources using the `base_infra.yml` GitHub Actions workflow. The pipeline creates foundational resources for AI Foundry projects, including:

- A Virtual Network (VNet) with:
  - Two subnets: one for the agent and one for the private endpoint.
  - A third subnet for a Windows jumpbox used for debugging purposes.
- All necessary private DNS zones for Azure resources.

### 🔑 Required Secrets

Here is the list of secrets you need to create:

1. **LOCATION**: The Azure region where resources will be deployed.
2. **RESOURCE_GROUP_NAME**: The name of the resource group for the deployment.
3. **VNET_RESOURCE_GROUP_NAME**: The name of the resource group for the VNet.
4. **SUBNET_AGENT_ADDRESS_PREFIX**: The address prefix for the agent subnet.
5. **JUMPBOX_SUBNET_ADDRESS_PREFIX**: The address prefix for the jumpbox subnet.
6. **SUBNET_PRIVATE_ENDPOINT_ADDRESS_PREFIX**: The address prefix for the private endpoint subnet.
7. **VNET_ADDRESS_PREFIX**: The address prefix for the VNet.
8. **VM_PASSWORD**: The password for the Windows jumpbox.
9. **VM_ADMIN**: The admin username for the Windows jumpbox.
10. **PA_TOKEN**: Personal Access Token for creating GitHub secrets.
11. **AZURE_CREDENTIALS**: Azure credentials for logging in.

### 🛠️ Creating the Service Principal

Run this command to create the service principal that will be used for the AZURE_CREDENTIALS.

```bash
az ad sp create-for-rbac --name foundry-iac --role reader --scopes /subscriptions/00000000-0000-0000-0000-000000000000/ contributor
```

Make sure to save the output of this command, as it contains the credentials needed for the `AZURE_CREDENTIALS` secret.

### 🌟 Next Steps

1. Run the above command to create the service principal.
2. Add the secrets listed above to your repository settings.
3. Trigger the `base_infra.yml` workflow to deploy the core resources.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
````