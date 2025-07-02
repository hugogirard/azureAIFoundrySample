```
az network vnet subnet show \
  --resource-group <ResourceGroupName> \
  --vnet-name <VNetName> \
  --name <SubnetName> \
  --query "id" \
  --output tsv
```