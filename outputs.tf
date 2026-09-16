output "names" {
  description = "Modern names keyed by the snake-case JSON keys; empty in legacy_mode. Unusable names are null with name_available/name_errors or name_unique_available/name_unique_errors diagnostics. Entries expose the catalog separator, formatted instance, source, constraints, token retention, and validation; incomplete rule validation is null. Availability checks token retention and capacity, not Azure name availability."

  precondition {
    condition     = local.generated_catalog.schema_version == 2 && local.manual_catalog.schema_version == 2
    error_message = "Bundled naming catalogs must use schema version 2."
  }
  precondition {
    condition     = local.customer_catalog_valid
    error_message = "custom_override_file must contain valid JSON with schema_version 2 and a resources object. Put additions and partial overrides directly in resources, not an overrides section."
  }
  precondition {
    condition     = alltrue(values(local.customer_entry_valid))
    error_message = local.customer_entry_error
  }
  precondition {
    condition     = alltrue([for key in keys(local.catalog) : can(regex("^[a-z][a-z0-9]*(?:_[a-z0-9]+)*$", key))])
    error_message = "All catalog keys must use lower snake case."
  }
  precondition {
    condition     = alltrue([for definition in values(local.catalog) : contains(["standard", "uuid", "literal"], definition.name_kind)])
    error_message = "Catalog name_kind values must be standard, uuid, or literal."
  }
  precondition {
    condition     = alltrue([for definition in values(local.catalog) : try(definition.slug != null && tostring(definition.slug) == definition.slug, false)])
    error_message = "Each merged catalog entry must supply a string slug. New entries cannot omit it."
  }
  precondition {
    condition = alltrue([
      for definition in values(local.catalog) :
      (definition.min_length == null ? true : definition.min_length >= 0 && floor(definition.min_length) == definition.min_length) &&
      (definition.max_length == null ? true : definition.max_length >= 0 && floor(definition.max_length) == definition.max_length) &&
      (definition.min_length == null || definition.max_length == null ? true : definition.min_length <= definition.max_length)
    ])
    error_message = "Merged naming lengths must be nonnegative integers with min_length no greater than max_length."
  }
  value = local.names
}

output "names_by_azure_type" {
  description = "Modern names grouped by Azure type and then JSON key; empty in legacy_mode. Every type contains a map, including single-entry types. Non-ARM manual entries are available only through names."

  precondition {
    condition     = local.customer_catalog_valid
    error_message = "custom_override_file must contain valid JSON with schema_version 2 and a resources object. Put additions and partial overrides directly in resources, not an overrides section."
  }
  precondition {
    condition     = alltrue(values(local.customer_entry_valid))
    error_message = local.customer_entry_error
  }
  value = local.names_by_azure_type
}
