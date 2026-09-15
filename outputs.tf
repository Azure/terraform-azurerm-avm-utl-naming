output "names" {
  description = "Modern generated names keyed by the snake-case JSON keys. Empty in legacy_mode. Entries expose source, constraints, seed retention, and validation; incomplete modern validation is null."

  precondition {
    condition     = local.generated_catalog.schema_version == 2 && local.manual_catalog.schema_version == 2
    error_message = "Both naming catalogs must use schema version 2."
  }
  precondition {
    condition     = alltrue([for key in try(keys(local.manual_catalog.overrides), []) : contains(keys(local.catalog_defaults), key)])
    error_message = "Every manual rule override must identify a current catalog entry."
  }
  precondition {
    condition     = alltrue([for definition in values(local.catalog) : contains(["standard", "uuid", "literal"], definition.name_kind)])
    error_message = "Catalog name_kind values must be standard, uuid, or literal."
  }
  precondition {
    condition = length(setintersection(
      toset([for definition in values(local.generated_catalog.resources) : lower(definition.resource_type) if definition.resource_type != null]),
      toset([for definition in values(local.manual_catalog.resources) : lower(definition.resource_type) if definition.resource_type != null]),
    )) == 0
    error_message = "Manual resource definitions must not duplicate resource types covered by the generated catalog."
  }
  precondition {
    condition = alltrue([
      for key, definition in local.catalog :
      definition.max_length == null ? true : length(local.rendered_names[key].name_unique) <= definition.max_length
    ])
    error_message = "A unique-name template or uniqueness suffix exceeds the configured maximum length. Adjust the template, unique_length, or the reviewed JSON rule override."
  }
  precondition {
    condition = alltrue([
      for key, definition in local.catalog : local.unique_suffix_retained[key]
      if definition.name_kind != "literal"
    ])
    error_message = "The name_unique template must retain the unique token when unique_length is nonzero."
  }
  value = local.names
}

output "names_by_azure_type" {
  description = "Modern names grouped by Azure type and then JSON key; empty in legacy_mode. Every type contains a map, including single-entry types. Non-ARM manual entries are available only through names."

  precondition {
    condition = alltrue([
      for key, definition in local.catalog :
      definition.max_length == null ? true : length(local.rendered_names[key].name_unique) <= definition.max_length
    ])
    error_message = "A unique-name template or uniqueness suffix exceeds the configured maximum length."
  }
  precondition {
    condition = alltrue([
      for key, definition in local.catalog : local.unique_suffix_retained[key]
      if definition.name_kind != "literal"
    ])
    error_message = "The name_unique template must retain the unique token when unique_length is nonzero."
  }
  value = local.names_by_azure_type
}
