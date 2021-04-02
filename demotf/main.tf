terraform {
 required_version = ">= 0.13"
 backend "azurerm" {
        resource_group_name = "rg-terrastateaa-uksouth001"
        storage_account_name = "stterrorstateuks001"
        container_name = "tfstate"
        key = "myapp.tfstate"
 }
}


provider "azurerm" {
  features {}
}


resource "azurerm_resource_group" "rg-app" {
  name     = "RG-DEMO"
  location = "westeurope"
}

resource "azurerm_app_service_plan" "plan-app" {
  name                = "SPDemo"
  location            = "westeurope"
  resource_group_name = azurerm_resource_group.rg-app.name

  sku {
    tier = "Standard"
    size = "S1"
  }

}

resource "azurerm_virtual_network" "myterraformnetwork" {
    name                = "myVnet"
    address_space       = ["10.0.0.0/16"]
    location            = "westeurope"
    resource_group_name = azurerm_resource_group.rg-app.name

    tags = {
        environment = "Terraform Demo"
    }
}

resource "azurerm_subnet" "myterraformsubnet" {
    name                 = "mySubnet"
    resource_group_name  = azurerm_resource_group.rg-app.name
    virtual_network_name = azurerm_virtual_network.myterraformnetwork.name
    address_prefixes       = ["10.0.2.0/24"]
}

resource "azurerm_public_ip" "myterraformpublicip" {
    name                         = "myPublicIP"
    location                     = "westeurope"
    resource_group_name          = azurerm_resource_group.rg-app.name
    allocation_method            = "Dynamic"

    tags = {
        environment = "Terraform Demo"
    }
}

resource "azurerm_network_interface" "myterraformnic" {
    name                        = "myNIC"
    location                    = "westeurope"
    resource_group_name         = azurerm_resource_group.rg-app.name

    ip_configuration {
        name                          = "myNicConfiguration"
        subnet_id                     = azurerm_subnet.myterraformsubnet.id
        private_ip_address_allocation = "Dynamic"
        public_ip_address_id          = azurerm_public_ip.myterraformpublicip.id
    }

    tags = {
        environment = "Terraform Demo"
    }
}


resource "azurerm_network_security_group" "myterraformnsg" {
    name                = "myNetworkSecurityGroup"
    location            = "westeurope"
    resource_group_name = azurerm_resource_group.rg-app.name

    security_rule {
        name                       = "SSH"
        priority                   = 1001
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "22"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }

    tags = {
        environment = "Terraform Demo"
    }
}


resource "azurerm_app_service" "app" {
  name                = "AppDemoARM"
  location            = "westeurope"
  resource_group_name = azurerm_resource_group.rg-app.name
  app_service_plan_id = azurerm_app_service_plan.plan-app.id
}


resource "azurerm_template_deployment" "extension" {
  name                = "extension"
  resource_group_name = azurerm_resource_group.rg-app.name
  template_body       = file("ARM_siteExtension.json")

  parameters = {
    appserviceName   = azurerm_app_service.app.name
    extensionName    = "AspNetCoreRuntime.2.2.x64"
    extensionVersion = "2.2.0-preview3-35497"
  }

  deployment_mode = "Incremental"
}
