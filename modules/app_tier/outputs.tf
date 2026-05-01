output "app_private_ip" {
  value = azurerm_network_interface.nic.private_ip_address
}

output "app_vm_name" {
  value = azurerm_linux_virtual_machine.app.name
}