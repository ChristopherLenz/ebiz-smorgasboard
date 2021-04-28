# SUBSCRIPTION_HASH is a short 4-char consistent hash of the longer subscription id.
# This is useful because azure storage account names are not allowed special characters and are limited to 24 chars.
terraform {
  backend "azurerm" {
    resource_group_name = "<%= expansion('terraform-resources') %>"
    # storage_account_name = "<%= expansion('ts:SUBSCRIPTION_HASH:LOCATION:ENV') %>"
    storage_account_name = "<%= expansion('ts:SUBSCRIPTION_HASH:ENV') %>"
    container_name       = "terraform-state"
    key                  = "<%= expansion(':LOCATION/:ENV/:BUILD_DIR/terraform.tfstate') %>"
  }
}
