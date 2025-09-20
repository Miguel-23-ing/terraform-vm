# Configuración del proveedor Azure
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~>3.1"
    }
  }
}

provider "azurerm" {
  features {}
  subscription_id = "270b4efe-9ebd-44f7-ab7e-a468a5d58e77"
}

resource "azurerm_resource_group" "vm_rg" {
  name     = "rg-vm-terraform"
  location = "East US"
}

resource "azurerm_virtual_network" "vm_vnet" {
  name                = "vnet-vm-terraform"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.vm_rg.location
  resource_group_name = azurerm_resource_group.vm_rg.name
}

# Crear subred
resource "azurerm_subnet" "vm_subnet" {
  name                 = "subnet-vm-terraform"
  resource_group_name  = azurerm_resource_group.vm_rg.name
  virtual_network_name = azurerm_virtual_network.vm_vnet.name
  address_prefixes     = ["10.0.2.0/24"]
}

# Crear IP pública
resource "azurerm_public_ip" "vm_public_ip" {
  name                = "pip-vm-terraform"
  resource_group_name = azurerm_resource_group.vm_rg.name
  location            = azurerm_resource_group.vm_rg.location
  allocation_method   = "Static"
  sku                 = "Standard"
}

# Crear grupo de seguridad de red y reglas
resource "azurerm_network_security_group" "vm_nsg" {
  name                = "nsg-vm-terraform"
  location            = azurerm_resource_group.vm_rg.location
  resource_group_name = azurerm_resource_group.vm_rg.name

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

  security_rule {
    name                       = "RDP"
    priority                   = 1002
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "HTTP"
    priority                   = 1003
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "HTTPS"
    priority                   = 1004
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

# Crear interfaz de red
resource "azurerm_network_interface" "vm_nic" {
  name                = "nic-vm-terraform"
  location            = azurerm_resource_group.vm_rg.location
  resource_group_name = azurerm_resource_group.vm_rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.vm_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.vm_public_ip.id
  }
}

# Conectar el grupo de seguridad a la interfaz de red
resource "azurerm_network_interface_security_group_association" "vm_nsg_association" {
  network_interface_id      = azurerm_network_interface.vm_nic.id
  network_security_group_id = azurerm_network_security_group.vm_nsg.id
}

# Crear cuenta de almacenamiento para diagnósticos de arranque
resource "azurerm_storage_account" "vm_storage_account" {
  name                     = "diagstorage${substr(random_id.randomId.hex, 0, 8)}"
  resource_group_name      = azurerm_resource_group.vm_rg.name
  location                 = azurerm_resource_group.vm_rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

# Crear ID aleatorio
resource "random_id" "randomId" {
  keepers = {
    resource_group = azurerm_resource_group.vm_rg.name
  }

  byte_length = 4
}

# Crear máquina virtual
resource "azurerm_linux_virtual_machine" "vm" {
  name                = "vm-terraform-miguel"
  resource_group_name = azurerm_resource_group.vm_rg.name
  location            = azurerm_resource_group.vm_rg.location
  size                = "Standard_B1s" # VM más económica
  admin_username      = "azureuser"
  disable_password_authentication = false
  admin_password      = "Terra2323"

  network_interface_ids = [
    azurerm_network_interface.vm_nic.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts-gen2"
    version   = "latest"
  }

  boot_diagnostics {
    storage_account_uri = azurerm_storage_account.vm_storage_account.primary_blob_endpoint
  }

  # Script de inicialización para configurar la VM
  custom_data = base64encode(templatefile("cloud-init.txt", {}))
}
