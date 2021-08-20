# This is where you put your outputs declaration
output "primary_connection_string" {
  value       = azurerm_redis_cache.default.primary_connection_string
  description = "The primary connection string for logging in to the redis-cache."
  sensitive   = true
}

output "secondary_connection_string" {
  value       = azurerm_redis_cache.default.secondary_connection_string
  description = "The secondary connection string for logging in to the redis-cache."
  sensitive   = true
}
