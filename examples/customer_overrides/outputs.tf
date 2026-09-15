output "database_account_name" {
  description = "A name using the customer slug instead of the bundled manual fallback."
  value       = module.naming.names.database_account.name_unique
}

output "internal_storage_account_name" {
  description = "A customer-defined variant accessed through its Azure resource type."
  value       = module.naming.names_by_azure_type["Microsoft.Storage/storageAccounts"].storage_account_internal.name_unique
}

output "static_site_name" {
  description = "A name with a customer maximum overriding the bundled manual limit."
  value       = module.naming.names.static_site.name_unique
}
