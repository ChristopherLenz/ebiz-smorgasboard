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

variable "tags" {
  type        = map(string)
  description = "Any tags that should be present on the resources"
  default     = {}
}
