# This is where you put your outputs declaration
output "cache_primary_connection_string" {
  value       = module.redis.primary_connection_string
  description = "The primary connection string for logging in to the redis-cache."
  sensitive   = true
}

output "cache_secondary_connection_string" {
  value       = module.redis.secondary_connection_string
  description = "The secondary connection string for logging in to the redis-cache."
  sensitive   = true
}
