output "web_public_ip" {
  value = azurerm_public_ip.pip.ip_address
}

output "ssh_command" {
  value = "ssh ${var.admin_username}@${azurerm_public_ip.pip.ip_address}"
}

output "web_vm_name" {
  value = azurerm_linux_virtual_machine.web.name
}