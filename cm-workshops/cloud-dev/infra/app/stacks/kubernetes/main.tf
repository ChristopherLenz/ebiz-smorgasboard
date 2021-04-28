locals {
  resource_group_name = "cm-cloud-ws-<%= Terraspace.env %>-resources"
  tags = {
    "env"     = "<%= Terraspace.env %>"
    "purpose" = "cm-workshop"
  }
}

# https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/data-sources/group
# aktuell fehlt die Berechtigung: https://stackoverflow.com/questions/60137544/azure-active-directory-graphrbac-groupsclientlist-failure-responding-to-requ
# data "azuread_group" "group_cm" {
#   display_name     = "CM_WORKSHOP_CLOUD_DEVELOPMENT"
#   security_enabled = true
# }

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group
resource "azurerm_resource_group" "this" {
  name     = local.resource_group_name
  location = "<%= AzureInfo.location %>"
  tags     = local.tags
}

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment
resource "azurerm_role_assignment" "group_cm_to_resource_group" {
  scope                = azurerm_resource_group.this.id
  role_definition_name = "Contributor"
  principal_id         = "7ecd40b7-8aaf-4a94-9bd1-3050284e2543" #data.azuread_group.group_cm.id
}

module "network" {
  source              = "Azure/network/azurerm"
  vnet_name           = "aks-network"
  resource_group_name = azurerm_resource_group.this.name
  address_space       = "10.11.0.0/16"
  subnet_prefixes     = ["10.11.1.0/24", "10.11.2.0/24", "10.11.3.0/24"]
  subnet_names        = ["subnet1", "subnet2", "subnet3"]

  depends_on = [azurerm_resource_group.this]
}

resource "random_pet" "this" {
  length = 2
}

module "aks" {
  source                          = "../../modules/aks"
  agents_size                     = var.agents_size
  agents_count                    = var.agents_count
  resource_group_name             = local.resource_group_name
  prefix                          = var.prefix
  vnet_subnet_id                  = module.network.vnet_subnets[0]
  os_disk_size_gb                 = var.os_disk_size_gb
  kubernetes_version              = var.kubernetes_version
  availability_zones              = var.availability_zones
  enable_log_analytics_workspace  = false
  enable_http_application_routing = var.enable_http_application_routing
  tags                            = local.tags

  depends_on = [azurerm_resource_group.this]
}

module "kv" {
  source              = "../../modules/keyvault"
  resource_group_name = local.resource_group_name
  prefix              = var.prefix
  tags                = local.tags

  depends_on = [azurerm_resource_group.this]
}

module "psql" {
  source                   = "../../modules/postgres"
  resource_group_name      = local.resource_group_name
  prefix                   = var.prefix
  tags                     = local.tags
  keyvault_secrets_enabled = true
  keyvault_id              = module.kv.id

  depends_on = [azurerm_resource_group.this]
}
