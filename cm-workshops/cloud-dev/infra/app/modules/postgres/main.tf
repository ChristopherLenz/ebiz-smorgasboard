data "azurerm_resource_group" "main" {
  name = var.resource_group_name
}

# https://www.terraform.io/docs/providers/random/r/password.html
resource "random_password" "db_passwd" {
  length  = 64
  special = false
}

# https://www.terraform.io/docs/providers/azurerm/r/postgresql_server.html
resource "azurerm_postgresql_server" "dbserver" {
  name                = format("%s-psql", var.prefix)
  location            = data.azurerm_resource_group.main.location
  resource_group_name = data.azurerm_resource_group.main.name

  # The name of the SKU, follows the tier + family + cores pattern (e.g. B_Gen4_1, GP_Gen5_8)
  # (B)asic_(Gen5)_(1) vCore
  sku_name = "B_Gen5_1"
  version  = 11

  storage_mb                   = 5120 # 25 GB
  backup_retention_days        = 20
  geo_redundant_backup_enabled = false
  auto_grow_enabled            = false

  administrator_login              = "psqladmin"
  administrator_login_password     = random_password.db_passwd.result
  ssl_enforcement_enabled          = true
  ssl_minimal_tls_version_enforced = "TLS1_2"
  public_network_access_enabled    = true # false is only available on GP-tier (https://docs.microsoft.com/en-us/azure/postgresql/concepts-data-access-and-security-private-link)

  tags = var.tags
}

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/postgresql_firewall_rule
# The Azure feature Allow access to Azure services can be enabled by setting start_ip_address and end_ip_address to 0.0.0.0 which (is documented in the Azure API Docs).
resource "azurerm_postgresql_firewall_rule" "allow_azure_services" {
  name                = "allow_azure_services"
  resource_group_name = data.azurerm_resource_group.main.name
  server_name         = azurerm_postgresql_server.dbserver.name
  start_ip_address    = "0.0.0.0"
  end_ip_address      = "0.0.0.0"
}

resource "azurerm_postgresql_database" "example" {
  name                = "exampledb"
  resource_group_name = data.azurerm_resource_group.main.name
  server_name         = azurerm_postgresql_server.dbserver.name
  charset             = "UTF8"
  collation           = "English_United States.1252"
}

resource "azurerm_key_vault_secret" "psql-user" {
  name         = "psql-user"
  value        = azurerm_postgresql_server.dbserver.administrator_login
  key_vault_id = var.keyvault_id
}

resource "azurerm_key_vault_secret" "psql-pass" {
  name         = "psql-pass"
  value        = azurerm_postgresql_server.dbserver.administrator_login_password
  key_vault_id = var.keyvault_id
}
