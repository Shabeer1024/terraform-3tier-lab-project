output "resource_group_name" {
  value = module.networking.resource_group_name
}

output "vnet_id" {
  value = module.networking.vnet_id
}

output "sql_fqdn" {
  value = module.data_tier.sql_fqdn
}

output "sql_server_name" {
  value = module.data_tier.sql_server_name
}

output "storage_account_name" {
  value = module.data_tier.storage_account_name
}

output "storage_blob_endpoint" {
  value = module.data_tier.storage_blob_endpoint
}

output "key_vault_uri" {
  value = module.data_tier.key_vault_uri
}

output "key_vault_name" {
  value = module.data_tier.key_vault_name
}

output "app_private_ip" {
  value = module.app_tier.app_private_ip
}

output "app_vm_name" {
  value = module.app_tier.app_vm_name
}

output "web_public_ip" {
  value = module.web_tier.web_public_ip
}

output "ssh_to_web" {
  value = module.web_tier.ssh_command
}
