output "names" {
  description = "Modern names keyed by the snake-case JSON keys; empty in legacy_mode. Unusable unique names are null with name_unique_available=false and per-entry name_unique_errors. Entries expose source, constraints, token retention, and validation; incomplete rule validation is null."

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
  value = local.names
}

output "names_by_azure_type" {
  description = "Modern names grouped by Azure type and then JSON key; empty in legacy_mode. Every type contains a map, including single-entry types. Non-ARM manual entries are available only through names."
  value       = local.names_by_azure_type
}
