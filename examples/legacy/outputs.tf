output "resource_group_name" {
  description = "Original resource-group naming behavior, including case and separators."
  value       = module.naming.resource_group.name
}

output "storage_account_name" {
  description = "Original storage-account naming behavior, including lowercasing."
  value       = module.naming.storage_account.name_unique
}

output "windows_virtual_machine_name" {
  description = "Original Windows VM naming behavior, including the 15-character limit."
  value       = module.naming.windows_virtual_machine.name
}
