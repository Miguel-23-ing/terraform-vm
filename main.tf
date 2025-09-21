# Configuración del proveedor Azure
terraform {
  required_version = ">= 1.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.1"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.0"
    }
  }
}

provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
}

# Crear grupo de recursos
resource "azurerm_resource_group" "main" {
  name     = var.resource_group_name
  location = var.location

  tags = var.tags
}

# Generar SSH key pair
resource "tls_private_key" "ssh" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Guardar la clave privada localmente
resource "local_file" "private_key" {
  content  = tls_private_key.ssh.private_key_pem
  filename = "${path.module}/ssh-key-${var.vm_name}.pem"
  file_permission = "0600"
}

# Módulo de networking
module "networking" {
  source = "./modules/networking"

  resource_group_name = azurerm_resource_group.main.name
  location           = azurerm_resource_group.main.location
  vnet_name          = var.vnet_name
  vnet_address_space = var.vnet_address_space
  subnet_name        = var.subnet_name
  subnet_address_prefix = var.subnet_address_prefix
  public_ip_name     = var.public_ip_name

  tags = var.tags
}

# Módulo de seguridad
module "security" {
  source = "./modules/security"

  resource_group_name = azurerm_resource_group.main.name
  location           = azurerm_resource_group.main.location
  nsg_name           = var.nsg_name
  allowed_ssh_sources = var.allowed_ssh_sources

  tags = var.tags
}

# Módulo de compute
module "compute" {
  source = "./modules/compute"

  resource_group_name = azurerm_resource_group.main.name
  location           = azurerm_resource_group.main.location
  vm_name            = var.vm_name
  vm_size            = var.vm_size
  admin_username     = var.admin_username
  ssh_public_key     = tls_private_key.ssh.public_key_openssh
  
  subnet_id          = module.networking.subnet_id
  public_ip_id       = module.networking.public_ip_id
  network_security_group_id = module.security.nsg_id
  
  os_disk_type       = var.os_disk_type
  ubuntu_version     = var.ubuntu_version

  tags = var.tags

  depends_on = [module.networking, module.security]
}
