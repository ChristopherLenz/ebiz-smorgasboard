# This is where you put your resource declaration
data "azurerm_resource_group" "main" {
  name = var.resource_group_name
}

# NOTE: the Name used for Redis needs to be globally unique
resource "azurerm_redis_cache" "default" {
  name                = format("%s-cache", var.prefix)
  location            = data.azurerm_resource_group.main.location
  resource_group_name = data.azurerm_resource_group.main.name
  capacity            = var.cache_capacity
  family              = var.cache_family
  sku_name            = var.cache_sku_name
  enable_non_ssl_port = var.cache_enable_non_ssl_port
  minimum_tls_version = var.cache_minimum_tls_version

  redis_configuration {
  }

  tags = var.tags
}

resource "azurerm_key_vault_secret" "cache-primary-connection-string" {
  count        = var.keyvault_secrets_enabled ? 1 : 0
  name         = "cache-primary-connection-string"
  value        = azurerm_redis_cache.default.primary_connection_string
  key_vault_id = var.keyvault_id
}

resource "azurerm_key_vault_secret" "cache-secondary-connection-string" {
  count        = var.keyvault_secrets_enabled ? 1 : 0
  name         = "cache-secondary-connection-string"
  value        = azurerm_redis_cache.default.secondary_connection_string
  key_vault_id = var.keyvault_id
}
