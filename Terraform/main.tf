# We strongly recommend using the required_providers block to set the
# Azure Provider source and version being used
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.0.0"
    }
  }
}

# Configure the Microsoft Azure Provider
provider "azurerm" {
  features {}

  subscription_id = "dbec680b-7200-42e4-98c4-e1e8b8cf69bf"
  tenant_id = "30670006-8f8b-41ce-9b20-c9d57651cece"
  client_id = "04c7a94e-174c-40cc-abff-ba22fa602365"
  
}

resource "azurerm_resource_group" "deployz" {
  name     = "deployz-resources"
  location = "West Europe"
}

resource "azurerm_virtual_network" "deployz" {
  name                = "deployz-network"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.deployz.location
  resource_group_name = azurerm_resource_group.deployz.name
}

resource "azurerm_subnet" "deployz" {
  name                 = "internal"
  resource_group_name  = azurerm_resource_group.deployz.name
  virtual_network_name = azurerm_virtual_network.deployz.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_public_ip" "deployz" {
  name                = "deployz-public-ip"
  location            = azurerm_resource_group.deployz.location
  resource_group_name = azurerm_resource_group.deployz.name
  allocation_method   = "Static" # or "Static" if you prefer a static IP

}

resource "azurerm_network_security_group" "deployz" {
  name                = "deployz-nsg"
  location            = azurerm_resource_group.deployz.location
  resource_group_name = azurerm_resource_group.deployz.name

  # SSH Rule
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

  # Default Allow Internet Outbound
  security_rule {
    name                       = "AllowInternetOutbound"
    priority                   = 1002
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "Internet"
  }

  security_rule {
    name                       = "AllowVnetInbound"
    priority                   = 1003
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "Internet"
  }

  security_rule {
    name                       = "DenyAllInbound"
    priority                   = 1004
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_network_interface" "deployz" {
  name                = "deployz-nic"
  location            = azurerm_resource_group.deployz.location
  resource_group_name = azurerm_resource_group.deployz.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.deployz.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.deployz.id
  }
}

resource "azurerm_linux_virtual_machine" "deployz" {
  name                = "deployz-machine"
  resource_group_name = azurerm_resource_group.deployz.name
  location            = azurerm_resource_group.deployz.location
  size                = "Standard_F2"
  admin_username      = "adminuser"
  admin_password      = var.admin_password
  disable_password_authentication = false

  network_interface_ids = [
    azurerm_network_interface.deployz.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
}
