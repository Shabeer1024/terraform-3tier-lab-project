

provider "azurerm" {
  features {
    key_vault {
      purge_soft_delete_on_destroy    = true
      recover_soft_deleted_key_vaults = true
    }
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }

  client_id       = "xxxx-xxxxx-xxxxxx-xxxxxx-xxxxxx"
  client_secret   = "xxxx-xxxxx-xxxxxx-xxxxxx-xxxxxx"
  tenant_id       = "xxxx-xxxxx-xxxxxx-xxxxxx-xxxxxx"
  subscription_id = "xxxx-xxxxx-xxxxxx-xxxxxx-xxxxxx"
}