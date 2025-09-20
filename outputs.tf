# Outputs para obtener información importante de la VM
output "resource_group_name" {
  value = azurerm_resource_group.vm_rg.name
}

output "public_ip_address" {
  value = azurerm_public_ip.vm_public_ip.ip_address
}

output "ssh_connection_command" {
  value = "ssh azureuser@${azurerm_public_ip.vm_public_ip.ip_address}"
}

output "vm_admin_username" {
  value = "azureuser"
}

output "vm_admin_password" {
  value     = "TerraformVM123!"
  sensitive = true
}

output "vm_size" {
  value = "Standard_B1s"
}

output "vm_location" {
  value = azurerm_resource_group.vm_rg.location
}
