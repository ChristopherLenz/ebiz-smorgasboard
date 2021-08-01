locals {
  full_key_permissions         = ["purge", "create", "delete", "get", "list", "update"]
  full_secret_permissions      = ["purge", "set", "delete", "get", "list"]
  full_certificate_permissions = ["purge", "create", "delete", "get", "list"]
}

data "azurerm_resource_group" "main" {
  name = var.resource_group_name
}

# https://www.terraform.io/docs/providers/azurerm/d/client_config.html
data "azurerm_client_config" "current" {}

# https://www.terraform.io/docs/providers/azurerm/r/user_assigned_identity.html
resource "azurerm_user_assigned_identity" "pi_fence" {
  resource_group_name = data.azurerm_resource_group.main.name
  location            = data.azurerm_resource_group.main.location
  name                = "svc-fence-identity"
  tags                = var.tags
}

# https://www.terraform.io/docs/providers/azurerm/r/key_vault.html
resource "azurerm_key_vault" "kv" {
  name                = format("%s-kv", var.prefix)
  location            = data.azurerm_resource_group.main.location
  resource_group_name = data.azurerm_resource_group.main.name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  sku_name            = "standard"
  tags                = var.tags

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    key_permissions         = local.full_key_permissions
    secret_permissions      = local.full_secret_permissions
    certificate_permissions = local.full_certificate_permissions
  }

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = "7ecd40b7-8aaf-4a94-9bd1-3050284e2543" # lookup of 'our' group is not working because of missing permissions, therefor we hardcode the id

    key_permissions         = local.full_key_permissions
    secret_permissions      = local.full_secret_permissions
    certificate_permissions = local.full_certificate_permissions
  }

  # fence microservice needs access to secrets only
  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = azurerm_user_assigned_identity.pi_fence.principal_id

    certificate_permissions = []
    key_permissions         = []
    secret_permissions      = ["get"]
  }

  # network_acls {
  #   bypass                     = "None"
  #   default_action             = "Deny"
  #   ip_rules                   = [for ip in var.ip_whitelist : format("%s/32", ip)]
  #   virtual_network_subnet_ids = [azurerm_subnet.subnet.id]
  # }
}
