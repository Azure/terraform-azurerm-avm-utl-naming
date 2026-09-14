output "resource_group_name" {
  description = "Resource group name with the supplied seed."
  value       = module.naming.resource_group.name_unique
}

output "storage_account_name" {
  description = "Storage account name accessed through the complete catalog."
  value       = module.naming.names.storage_account.name_unique
}
