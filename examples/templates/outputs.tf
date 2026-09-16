output "storage_account_name" {
  description = "A resource name using custom environment and location tokens."
  value       = module.naming.names.storage_account.name_unique
}

output "resource_group_name" {
  description = "The same naming convention with the resource's separator policy."
  value       = module.naming.names.resource_group.name_unique
}

output "simple_storage_account_name" {
  description = "The separator-aware template produces stdevuks001 without illegal hyphens."

  precondition {
    condition     = module.separator_aware.names.storage_account.name_available && module.separator_aware.names.storage_account.validation.valid_name == true
    error_message = "The selected storage-account name must be available and satisfy its naming rules."
  }
  value = module.separator_aware.names.storage_account.name
}

output "simple_resource_group_name" {
  description = "The literal-hyphen template produces rg-dev-uks-001."

  precondition {
    condition     = module.literal_template.names.resource_group.name_available
    error_message = join(" ", module.literal_template.names.resource_group.name_errors)
  }
  value = module.literal_template.names.resource_group.name
}
