# This is where you put your resource declaration
locals {
  prefixCleaned = replace(var.prefix, "-", "")
}

data "azurerm_resource_group" "main" {
  name = var.resource_group_name
}

# https://www.terraform.io/docs/providers/random/r/password.html
resource "random_password" "db_passwd" {
  length  = 64
  special = false
}

resource "azurerm_sql_server" "dbserver-sql" {
  name                         = "${local.prefixCleaned}sql"
  resource_group_name          = data.azurerm_resource_group.main.name
  location                     = data.azurerm_resource_group.main.location
  version                      = "12.0"
  administrator_login          = "chris"
  administrator_login_password = random_password.db_passwd.result

  tags = var.tags
}

resource "azurerm_storage_account" "dbserver-sa" {
  name                     = "${local.prefixCleaned}sqlsa"
  resource_group_name      = data.azurerm_resource_group.main.name
  location                 = data.azurerm_resource_group.main.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_sql_database" "dbserver-db" {
  name                = "${local.prefixCleaned}db"
  resource_group_name = data.azurerm_resource_group.main.name
  location            = data.azurerm_resource_group.main.location
  server_name         = azurerm_sql_server.dbserver-sql.name
  edition = "Standard"
  requested_service_objective_name = "S0"

  extended_auditing_policy {
    storage_endpoint                        = azurerm_storage_account.dbserver-sa.primary_blob_endpoint
    storage_account_access_key              = azurerm_storage_account.dbserver-sa.primary_access_key
    storage_account_access_key_is_secondary = true
    retention_in_days                       = 6
  }

  tags = var.tags
}

resource "azurerm_key_vault_secret" "sql-user" {
  name         = "sql-user"
  value        = azurerm_sql_server.dbserver-sql.administrator_login
  key_vault_id = var.keyvault_id
}

resource "azurerm_key_vault_secret" "sql-pass" {
  name         = "sql-pass"
  value        = azurerm_sql_server.dbserver-sql.administrator_login_password
  key_vault_id = var.keyvault_id
}