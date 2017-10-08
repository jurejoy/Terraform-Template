# Configure the Microsoft Azure Provider
provider "azurerm" {
  subscription_id = "bac04d51-9318-4301-be98-863489c8a7cf"
  client_id       = "097afc49-cfca-4846-a11b-6c3840b3da6c"
  client_secret   = "aa4e5fbd-601d-43cb-917c-62953dec94b9"
  tenant_id       = "0e275126-51e6-439d-bf43-543f9a1afc66"
  environment	= "china"
}



resource "azurerm_resource_group" "test" {
  name     = "acctestrg"
  location = "China North"
}


resource "azurerm_template_deployment" "test" {
  name                = "acctesttemplate-01"
  resource_group_name = "${azurerm_resource_group.test.name}"

  template_body = <<DEPLOY
{
  "$schema": "https://schema.management.azure.com/schemas/2015-01-01/deploymentTemplate.json#",
  "contentVersion": "1.0.0.0",
  "parameters": {
    "storageAccountType": {
      "type": "string",
      "defaultValue": "Standard_LRS",
      "allowedValues": [
        "Standard_LRS",
        "Standard_GRS",
        "Standard_ZRS"
      ],
      "metadata": {
        "description": "Storage Account type"
      }
    }
  },
  "variables": {
    "location": "[resourceGroup().location]",
    "storageAccountName": "[concat(uniquestring(resourceGroup().id), 'storage')]",
    "publicIPAddressName": "[concat('myPublicIp', uniquestring(resourceGroup().id))]",
    "publicIPAddressType": "Dynamic",
    "apiVersion": "2015-06-15",
    "dnsLabelPrefix": "terraform-acctest"
  },
  "resources": [
    {
      "type": "Microsoft.Storage/storageAccounts",
      "name": "[variables('storageAccountName')]",
      "apiVersion": "[variables('apiVersion')]",
      "location": "[variables('location')]",
      "properties": {
        "accountType": "[parameters('storageAccountType')]"
      }
    },
    {
      "type": "Microsoft.Network/publicIPAddresses",
      "apiVersion": "[variables('apiVersion')]",
      "name": "[variables('publicIPAddressName')]",
      "location": "[variables('location')]",
      "properties": {
        "publicIPAllocationMethod": "[variables('publicIPAddressType')]",
        "dnsSettings": {
          "domainNameLabel": "[variables('dnsLabelPrefix')]"
        }
      }
    }
  ],
  "outputs": {
    "storageAccountName": {
      "type": "string",
      "value": "[variables('storageAccountName')]"
    }
  }
}
DEPLOY

  deployment_mode = "Incremental"
}

output "storageAccountName" {
  value = "${azurerm_template_deployment.test.outputs["storageAccountName"]}"
}
