output "names" {
  description = "Twenty resource-group and storage-account names keyed by their formatted instance."

  precondition {
    condition = alltrue([
      for naming in values(module.naming) :
      naming.names.resource_group.name_available && naming.names.storage_account.name_available
    ])
    error_message = "Every selected name must fit and retain its complete instance."
  }
  value = {
    for naming in values(module.naming) : naming.names.resource_group.instance => {
      resource_group  = naming.names.resource_group.name
      storage_account = naming.names.storage_account.name
    }
  }
}
