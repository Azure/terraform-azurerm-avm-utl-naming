output "storage_account_name" {
  description = "A resource name using custom environment and location tokens."
  value       = module.naming.names.storage_account.name_unique
}

output "resource_group_name" {
  description = "The same naming convention with the resource's separator policy."
  value       = module.naming.names.resource_group.name_unique
}
