variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
}

variable "vm_name" {
  description = "Name of the virtual machine"
  type        = string
}

variable "vm_size" {
  description = "Size of the virtual machine"
  type        = string
}

variable "admin_username" {
  description = "Admin username for the VM"
  type        = string
}

variable "ssh_public_key" {
  description = "SSH public key for authentication"
  type        = string
}

variable "subnet_id" {
  description = "ID of the subnet"
  type        = string
}

variable "public_ip_id" {
  description = "ID of the public IP"
  type        = string
}

variable "network_security_group_id" {
  description = "ID of the network security group"
  type        = string
}

variable "os_disk_type" {
  description = "Type of OS disk"
  type        = string
  default     = "Standard_LRS"
}

variable "ubuntu_version" {
  description = "Ubuntu version"
  type        = string
  default     = "20_04-lts-gen2"
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}