mock_provider "random" {}

variables {
  unique_seed = "a1b2c3d4"
}

run "dynamic_catalog" {
  command = apply

  assert {
    condition     = length(output.names) > 0 && length(output.names) == length(local.catalog)
    error_message = "Every JSON catalog entry must appear in the Terraform-keyed output."
  }

  assert {
    condition = alltrue([
      for key, definition in local.catalog :
      output.names[key].terraform_key == key &&
      output.names[key].slug == definition.slug &&
      output.names[key].slug_source == definition.slug_source
    ])
    error_message = "The default mode must use the generated catalog keys and modern slugs."
  }

  assert {
    condition = alltrue([
      for definition in values(output.names) :
      definition.regex == null ? true : can(regexall(definition.regex, definition.name))
    ])
    error_message = "Every published non-null regex must be a valid RE2 expression."
  }

  assert {
    condition = alltrue([
      for definition in values(output.names) :
      definition.validation_complete ? (
        definition.validation.valid_name != null && definition.validation.valid_name_unique != null
        ) : (
        definition.validation.valid_name == null &&
        definition.validation.valid_name_unique == null &&
        length(definition.validation_notes) > 0
      )
    ])
    error_message = "Incomplete rules must explicitly report unknown validation and explain the limitation."
  }
}

run "azure_type_groups" {
  command = apply

  assert {
    condition = alltrue([
      for key, definition in local.catalog :
      output.names_by_azure_type[definition.resource_type][key] == output.names[key]
      if definition.resource_type != null
    ])
    error_message = "The Azure-type view must preserve every variant without overwriting entries."
  }

  assert {
    condition = alltrue([
      for key, definition in local.catalog :
      alltrue([for entries in values(output.names_by_azure_type) : !contains(keys(entries), key)])
      if definition.resource_type == null
    ])
    error_message = "Non-ARM manual entries must not be assigned a fabricated Azure resource type."
  }
}

run "legacy_slugs" {
  command = apply

  variables {
    legacy_mode = true
  }

  assert {
    condition = alltrue([
      for key, definition in local.catalog :
      output.names[key].slug == (definition.legacy_slug != null ? definition.legacy_slug : definition.slug) &&
      output.names[key].slug_source == (definition.legacy_slug != null ? "legacy" : definition.slug_source)
    ])
    error_message = "Legacy mode must select each mapped legacy slug and retain current defaults for new entries."
  }

  assert {
    condition = (
      contains([for entry in values(output.names_by_azure_type["Microsoft.Web/sites"]) : entry.slug], "app") &&
      contains([for entry in values(output.names_by_azure_type["Microsoft.Web/sites"]) : entry.slug], "func")
    )
    error_message = "Web apps and function apps must retain distinct legacy variants under the same Azure type."
  }
}

run "override_precedence" {
  command = apply

  variables {
    legacy_mode = true
    slug_overrides = {
      storage_account = "store"
    }
  }

  assert {
    condition     = output.names.storage_account.slug == "store" && output.names.storage_account.slug_source == "override"
    error_message = "A per-entry slug override must take precedence over legacy mode."
  }

  assert {
    condition = alltrue([
      for key, definition in local.catalog :
      output.names[key].slug == (definition.legacy_slug != null ? definition.legacy_slug : definition.slug)
      if key != "storage_account"
    ])
    error_message = "Overriding one key must not change other catalog entries."
  }
}

run "omit_slug" {
  command = apply

  variables {
    slug_overrides = {
      storage_account = ""
    }
    suffix = ["sample"]
  }

  assert {
    condition     = output.names.storage_account.slug == "" && output.names.storage_account.name == "sample"
    error_message = "An explicitly empty override must omit the slug."
  }
}

run "unknown_override_key" {
  command = plan

  variables {
    slug_overrides = {
      __not_a_catalog_resource__ = "invalid"
    }
  }

  expect_failures = [var.slug_overrides]
}

run "zero_uniqueness_length" {
  command = apply

  variables {
    suffix        = ["example"]
    unique_length = 0
  }

  assert {
    condition     = alltrue([for entry in values(output.names) : entry.name == entry.name_unique])
    error_message = "A zero-length uniqueness suffix must not add a trailing separator."
  }
}

run "documented_name_modes" {
  command = apply

  assert {
    condition = alltrue([
      for key, definition in local.catalog :
      output.names[key].name == definition.fixed_name && output.names[key].name_unique == definition.fixed_name
      if definition.name_kind == "literal"
    ])
    error_message = "Documented literal names must not acquire prefixes or suffixes."
  }

  assert {
    condition = alltrue([
      for key, definition in local.catalog :
      can(regex("^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$", output.names[key].name)) &&
      can(regex("^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$", output.names[key].name_unique))
      if definition.name_kind == "uuid"
    ])
    error_message = "GUID-only resources must receive GUID-shaped names."
  }
}

run "maximum_length" {
  command = apply

  variables {
    prefix = [join("", [for i in range(1000) : "ab"])]
  }

  assert {
    condition = alltrue([
      for key, definition in local.catalog :
      length(output.names[key].name) == definition.max_length &&
      length(output.names[key].name_unique) == definition.max_length
      if definition.name_kind == "standard" && (definition.max_length == null ? false : definition.max_length <= 2000)
    ])
    error_message = "Standard names must be truncated to their documented maximum when one is known."
  }
}
