provider "kubernetes" {
  config_path    = "~/.kube/config"
  config_context = "ckad-dev-aks"
}

locals {
  resource_group_name = "${var.prefix}-resources"
  tags = {
    "env"     = "<%= Terraspace.env %>"
    "purpose" = "ckad"
  }
}

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group
resource "azurerm_resource_group" "this" {
  name     = local.resource_group_name
  location = "<%= AzureInfo.location %>"
  tags     = local.tags
}

# # https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment
# resource "azurerm_role_assignment" "group_cm_to_resource_group" {
#   scope                = azurerm_resource_group.this.id
#   role_definition_name = "Contributor"
#   principal_id         = "7ecd40b7-8aaf-4a94-9bd1-3050284e2543" #data.azuread_group.group_cm.id
# }

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
  resource_group_name             = azurerm_resource_group.this.name
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

# https://github.com/fbeltrao/aks-letsencrypt/blob/master/readme.md
resource "azurerm_dns_zone" "default" {
  name                = var.dns_zone_name
  resource_group_name = azurerm_resource_group.this.name
}

resource "azurerm_dns_a_record" "dns-a-records" {
  for_each = toset(var.dns_a_records)

  name                = each.key
  zone_name           = azurerm_dns_zone.default.name
  resource_group_name = azurerm_resource_group.this.name
  ttl                 = 300
  records             = var.dns_a_records_ips
}

module "kv" {
  source              = "../../modules/keyvault"
  resource_group_name = azurerm_resource_group.this.name
  prefix              = var.prefix
  tags                = local.tags

  depends_on = [azurerm_resource_group.this]
}

module "db" {
  source                   = "../../modules/db"
  resource_group_name      = azurerm_resource_group.this.name
  prefix                   = var.prefix
  tags                     = local.tags
  keyvault_secrets_enabled = true
  keyvault_id              = module.kv.id
}

module "redis" {
  source                    = "../../modules/redis"
  resource_group_name       = azurerm_resource_group.this.name
  prefix                    = var.prefix
  tags                      = local.tags
  cache_capacity            = 0
  cache_family              = "C"
  cache_sku_name            = "Basic"
  cache_enable_non_ssl_port = false
  cache_minimum_tls_version = "1.2"
  keyvault_secrets_enabled  = true
  keyvault_id               = module.kv.id
}

resource "local_file" "kube_config" {
  content  = module.aks.kube_config_raw
  filename = "${path.module}/kubeconfig"

  depends_on = [module.aks]
}

# module "argocd" {
#   source                          = "../../modules/argocd"

#   cluster_config_file = local_file.kube_config.filename
#   cluster_type        = "kubernetes"
#   app_namespace       = "argocd-app"
#   ingress_subdomain   = "christopher-lenz.de"
#   olm_namespace       = "argocd-olm"
#   operator_namespace  = "argocd-operator"
#   name                = "argocd"

#   depends_on = [local_file.kube_config]
# }
