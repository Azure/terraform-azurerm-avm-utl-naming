output "resource_group_name" {
  description = "Resource group name with a workload and environment suffix."
  value       = module.naming.names.resource_group.name
}

output "storage_account_name" {
  description = "Storage account name with a state-persisted uniqueness suffix."
  value       = module.naming.names.storage_account.name_unique
}
