output "resource_group_name" {
  description = "Name of the resource group"
  value       = azurerm_resource_group.main.name
}

output "public_ip_address" {
  description = "Public IP address of the VM"
  value       = module.networking.public_ip_address
}

output "ssh_connection_command" {
  description = "SSH command to connect to the VM"
  value       = "ssh -i ssh-key-${var.vm_name}.pem ${var.admin_username}@${module.networking.public_ip_address}"
}

output "vm_admin_username" {
  description = "VM admin username"
  value       = var.admin_username
}

output "vm_size" {
  description = "VM size"
  value       = var.vm_size
}

output "vm_location" {
  description = "VM location"
  value       = azurerm_resource_group.main.location
}

output "private_key_path" {
  description = "Path to the private SSH key"
  value       = "ssh-key-${var.vm_name}.pem"
  sensitive   = true
}

output "web_url" {
  description = "URL to access the web server"
  value       = "http://${module.networking.public_ip_address}"
}

output "estimated_monthly_cost" {
  description = "Estimated monthly cost for Standard_B1s VM"
  value       = "$7.30 USD/month (East US region)"
}

output "vm_private_ip" {
  description = "Private IP address of the VM"
  value       = module.compute.private_ip_address
}
