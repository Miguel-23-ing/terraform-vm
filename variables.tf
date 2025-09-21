# Configuración principal
variable "subscription_id" {
  description = "Azure subscription ID"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
  default     = "rg-vm-terraform"
}

variable "location" {
  description = "Azure region"
  type        = string
  default     = "East US"
}

variable "vm_name" {
  description = "Name of the virtual machine"
  type        = string
  default     = "vm-terraform-miguel"
}

variable "vm_size" {
  description = "Size of the virtual machine (optimized for student plan)"
  type        = string
  default     = "Standard_B1s"
  
  validation {
    condition = contains([
      "Standard_B1s",   # 1 vCPU, 1GB RAM - Más económica
      "Standard_B1ms",  # 1 vCPU, 2GB RAM - Backup option
      "Standard_B2s"    # 2 vCPU, 4GB RAM - Si necesitas más poder
    ], var.vm_size)
    error_message = "VM size must be one of the cost-effective options for student plan."
  }
}

variable "admin_username" {
  description = "Admin username for the VM"
  type        = string
  default     = "azureuser"
}

# Configuración de red
variable "vnet_name" {
  description = "Name of the virtual network"
  type        = string
  default     = "vnet-vm-terraform"
}

variable "vnet_address_space" {
  description = "Address space for the virtual network"
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

variable "subnet_name" {
  description = "Name of the subnet"
  type        = string
  default     = "subnet-vm-terraform"
}

variable "subnet_address_prefix" {
  description = "Address prefix for the subnet"
  type        = string
  default     = "10.0.2.0/24"
}

variable "public_ip_name" {
  description = "Name of the public IP"
  type        = string
  default     = "pip-vm-terraform"
}

variable "nsg_name" {
  description = "Name of the network security group"
  type        = string
  default     = "nsg-vm-terraform"
}

variable "allowed_ssh_sources" {
  description = "List of IP addresses/CIDR blocks allowed for SSH access"
  type        = list(string)
  default     = ["0.0.0.0/0"]  # Para desarrollo, cambiar en producción
}

# Configuración del sistema
variable "os_disk_type" {
  description = "Type of OS disk (Standard_LRS is cheapest)"
  type        = string
  default     = "Standard_LRS"
}

variable "ubuntu_version" {
  description = "Ubuntu version"
  type        = string
  default     = "20_04-lts-gen2"
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default = {
    Environment = "Development"
    Project     = "Terraform-VM"
    ManagedBy   = "Terraform"
    CostCenter  = "Student"
  }
}
