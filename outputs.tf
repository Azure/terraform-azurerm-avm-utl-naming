output "names" {
  description = "Generated names keyed by the snake-case keys in the JSON catalogs. Entries include the selected slug and its source, uniqueness seed, constraints, variant, and validation. Validation flags are null when the documented rules cannot be completely evaluated."

  precondition {
    condition     = local.generated_catalog.schema_version == 2 && local.manual_catalog.schema_version == 2
    error_message = "Both naming catalogs must use schema version 2."
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
  description = "Generated names grouped by documented Azure resource type, then by the snake-case JSON key. Every type contains a map, including types with a single entry. Non-ARM manual entries are available only through names."
  value       = local.names_by_azure_type
}
