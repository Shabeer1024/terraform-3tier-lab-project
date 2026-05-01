output "sql_fqdn" {
  value = azurerm_mssql_server.sql.fully_qualified_domain_name
}

output "sql_server_name" {
  value = azurerm_mssql_server.sql.name
}

output "storage_account_name" {
  value = azurerm_storage_account.stg.name
}

output "storage_blob_endpoint" {
  value = azurerm_storage_account.stg.primary_blob_endpoint
}

output "key_vault_uri" {
  value = azurerm_key_vault.kv.vault_uri
}

output "key_vault_name" {
  value = azurerm_key_vault.kv.name
}