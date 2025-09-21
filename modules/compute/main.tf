# Compute Module - Virtual Machine, Network Interface, and Storage

# Generar ID aleatorio para storage account
resource "random_id" "storage" {
  keepers = {
    resource_group = var.resource_group_name
  }
  byte_length = 4
}

# Storage account para diagnósticos
resource "azurerm_storage_account" "diag" {
  name                     = "diagstorage${random_id.storage.hex}"
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = var.tags
}

# Network interface
resource "azurerm_network_interface" "main" {
  name                = "nic-${var.vm_name}"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = var.public_ip_id
  }

  tags = var.tags
}

# Associate NSG with network interface
resource "azurerm_network_interface_security_group_association" "main" {
  network_interface_id      = azurerm_network_interface.main.id
  network_security_group_id = var.network_security_group_id
}

# Virtual Machine
resource "azurerm_linux_virtual_machine" "main" {
  name                = var.vm_name
  resource_group_name = var.resource_group_name
  location            = var.location
  size                = var.vm_size
  admin_username      = var.admin_username

  # Deshabilitar autenticación por contraseña para usar SSH keys
  disable_password_authentication = true

  network_interface_ids = [
    azurerm_network_interface.main.id,
  ]

  # Configuración de SSH
  admin_ssh_key {
    username   = var.admin_username
    public_key = var.ssh_public_key
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = var.os_disk_type
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = var.ubuntu_version
    version   = "latest"
  }

  boot_diagnostics {
    storage_account_uri = azurerm_storage_account.diag.primary_blob_endpoint
  }

  # Cloud-init script
  custom_data = base64encode(templatefile("${path.root}/cloud-init.txt", {
    admin_username = var.admin_username
  }))

  tags = var.tags
}