provider "azurerm" {
  features {}
}

# Create a resource group
resource "azurerm_resource_group" "example_rg" {
  name     = "example-resources"
  location = var.location
}

# Create a storage account
resource "azurerm_storage_account" "example_storage" {
  name                     = var.storage_account_name
  resource_group_name      = azurerm_resource_group.example_rg.name
  location                 = azurerm_resource_group.example_rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

# Create a storage container
resource "azurerm_storage_container" "example_container" {
  name                  = "example-container"
  storage_account_name  = azurerm_storage_account.example_storage.name
  container_access_type = "private"
}

# Upload setup script to storage container
resource "azurerm_storage_blob" "setup_script" {
  name                   = "user-data.sh"
  storage_account_name   = azurerm_storage_account.example_storage.name
  storage_container_name = azurerm_storage_container.example_container.name
  type                   = "Block"
  source                 = var.user_data  # local path to user-data.sh initial config file
}

# Create a managed identity for the VM
resource "azurerm_user_assigned_identity" "example_identity" {
  name                = "example-identity"
  resource_group_name = azurerm_resource_group.example_rg.name
  location            = azurerm_resource_group.example_rg.location
}

# Assign the managed identity to the storage account
resource "azurerm_role_assignment" "example_role_assignment" {
  scope                = azurerm_storage_account.example_storage.id
  role_definition_name = "Storage Blob Data Reader"
  principal_id         = azurerm_user_assigned_identity.example_identity.principal_id
}

# Create a virtual network
resource "azurerm_virtual_network" "example_vnet" {
  name                = "example-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.example_rg.location
  resource_group_name = azurerm_resource_group.example_rg.name
}

# Create a subnet
resource "azurerm_subnet" "example_subnet" {
  name                 = "example-subnet"
  resource_group_name  = azurerm_resource_group.example_rg.name
  virtual_network_name = azurerm_virtual_network.example_vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Create a network security group
resource "azurerm_network_security_group" "example_nsg" {
  name                = "example-nsg"
  location            = azurerm_resource_group.example_rg.location
  resource_group_name = azurerm_resource_group.example_rg.name
}

# Allow HTTP access on port 8080 and SSH access on port 22
resource "azurerm_network_security_rule" "example_rule" {
  name                        = "allow-http-ssh"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_ranges     = ["8080", "22"]
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.example_rg.name
  network_security_group_name = azurerm_network_security_group.example_nsg.name
}

# Create a network interface
resource "azurerm_network_interface" "example_nic" {
  name                = "example-nic"
  location            = azurerm_resource_group.example_rg.location
  resource_group_name = azurerm_resource_group.example_rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.example_subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}

# Create a virtual machine
resource "azurerm_linux_virtual_machine" "example_vm" {
  name                = "example-vm"
  resource_group_name = azurerm_resource_group.example_rg.name
  location            = azurerm_resource_group.example_rg.location
  size                = var.vm_size
  admin_username      = "adminuser"
  network_interface_ids = [
    azurerm_network_interface.example_nic.id,
  ]
  admin_ssh_key {
    username   = "adminuser"
    public_key = file(var.public_key_path)
  }
  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.example_identity.id]
  }
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
  custom_data = filebase64(var.user_data)
}