output "resource_group_name" {
  description = "Resource group name with the supplied seed."
  value       = module.naming.names.resource_group.name_unique
}

output "storage_account_name" {
  description = "Storage account name with a slug override, accessed through the Azure-type grouping."
  value       = module.naming.names_by_azure_type["Microsoft.Storage/storageAccounts"].storage_account.name_unique
}
