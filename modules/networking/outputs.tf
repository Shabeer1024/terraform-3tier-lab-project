output "resource_group_name" {
  value = azurerm_resource_group.rg.name
}

output "location" {
  value = azurerm_resource_group.rg.location
}

output "vnet_id" {
  value = azurerm_virtual_network.vnet.id
}

output "subnet_web_id" {
  value = azurerm_subnet.web.id
}

output "subnet_app_id" {
  value = azurerm_subnet.app.id
}

output "subnet_pe_id" {
  value = azurerm_subnet.pe.id
}

output "private_dns_zone_ids" {
  value = { for k, z in azurerm_private_dns_zone.zones : k => z.id }
}