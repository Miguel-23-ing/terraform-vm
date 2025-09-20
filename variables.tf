# Variables de configuración
variable "resource_group_location" {
  default     = "East US"
  description = "Ubicación del grupo de recursos"
}

variable "vm_size" {
  default     = "Standard_B1s"
  description = "Tamaño de la máquina virtual (más económica)"
}

variable "admin_username" {
  default     = "azureuser"
  description = "Nombre de usuario administrador"
}

variable "admin_password" {
  description = "Contraseña del administrador"
  sensitive   = true
}
