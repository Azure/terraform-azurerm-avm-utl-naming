output "resource_group_name" {
  description = "A compact workload hash followed by the complete formatted instance."

  precondition {
    condition     = module.naming.names.resource_group.name_available
    error_message = join(" ", module.naming.names.resource_group.name_errors)
  }
  value = module.naming.names.resource_group.name
}

output "storage_account_name" {
  description = "A separator-free compact name retaining the complete instance and uniqueness token."

  precondition {
    condition     = module.naming.names.storage_account.name_unique_available
    error_message = join(" ", module.naming.names.storage_account.name_unique_errors)
  }
  value = module.naming.names.storage_account.name_unique
}
