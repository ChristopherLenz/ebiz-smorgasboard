# This is where you put your variables declaration
variable "resource_group_name" {
  description = "The resource group name to be imported"
  type        = string
}

variable "prefix" {
  description = "The prefix for the resources created in the specified Azure Resource Group"
  type        = string
}

variable "keyvault_secrets_enabled" {
  type        = bool
  description = "Enable the creation of azurerm_key_vault_secret for username and password"
  default     = false
}

variable "keyvault_id" {
  type        = string
  description = "The id of the Azure KeyVault"
  default     = ""
}

variable "cache_capacity" {
  type        = number
  description = "The size of the Redis cache to deploy. Valid values for a SKU family of C (Basic/Standard) are 0, 1, 2, 3, 4, 5, 6, and for P (Premium) family are 1, 2, 3, 4"
  default     = 0
}

variable "cache_family" {
  type        = string
  description = "The SKU family/pricing group to use. Valid values are C (for Basic/Standard SKU family) and P (for Premium)"
  default     = "C"
}

variable "cache_sku_name" {
  type        = string
  description = "The SKU of Redis to use. Possible values are Basic, Standard and Premium."
  default     = "Basic"
}

variable "cache_enable_non_ssl_port" {
  type        = bool
  description = "Enable the non-SSL port (6379) - disabled by default."
  default     = false
}

variable "cache_minimum_tls_version" {
  type        = string
  description = "The minimum TLS version. Defaults to 1.2."
  default     = "1.2"
}

variable "tags" {
  type        = map(string)
  description = "Any tags that should be present on the resources"
  default     = {}
}
