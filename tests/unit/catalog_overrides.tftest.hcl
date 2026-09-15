mock_provider "random" {}

variables {
  unique_seed = "a1b2c3d4"
}

run "bundled_layers" {
  command = apply

  assert {
    condition = (
      local.generated_catalog.resources.database_account.slug_source == "derived" &&
      local.manual_catalog.resources.database_account.slug == "cosmos" &&
      output.names.database_account.slug == "cosmos" &&
      output.names.database_account.slug_source == "manual" &&
      output.names.database_account.regex == local.generated_catalog.resources.database_account.regex &&
      output.names.static_site.max_length == 40
    )
    error_message = "Manual fallback slugs and limits must override individual generated properties."
  }

  assert {
    condition = alltrue([
      for key, definition in local.catalog :
      output.names[key].slug == definition.legacy_slug
      if definition.legacy_slug != null && try(local.generated_catalog.resources[key].slug_source, "manual") != "caf"
    ])
    error_message = "Every legacy-mapped entry without a documented CAF abbreviation must use its original slug."
  }

  assert {
    condition = alltrue([
      for key, definition in local.generated_catalog.resources :
      output.names[key].slug == definition.slug
      if definition.slug_source == "caf"
    ])
    error_message = "Legacy fallback patches must not overwrite documented CAF recommendations."
  }
}

run "customer_file_objects" {
  command = apply

  variables {
    custom_override_file = "./examples/customer_overrides/naming-overrides.json"
  }

  assert {
    condition = (
      output.names.database_account.slug == "account" &&
      output.names.database_account.slug_source == "customer" &&
      output.names.database_account.min_length == run.bundled_layers.names.database_account.min_length &&
      output.names.database_account.max_length == run.bundled_layers.names.database_account.max_length &&
      output.names.database_account.regex == run.bundled_layers.names.database_account.regex &&
      output.names.static_site.max_length == 30 &&
      output.names.static_site.slug == run.bundled_layers.names.static_site.slug
    )
    error_message = "Customer properties must win without discarding omitted properties inherited from both bundled layers."
  }

  assert {
    condition = (
      length(output.names) == length(run.bundled_layers.names) + 1 &&
      output.names.resource_group == run.bundled_layers.names.resource_group &&
      output.names.storage_account_internal.slug == "intst" &&
      output.names.storage_account_internal.regex == "^[a-z0-9]{3,24}$" &&
      output.names.storage_account_internal.validation.valid_name &&
      output.names_by_azure_type["Microsoft.Storage/storageAccounts"].storage_account_internal == output.names.storage_account_internal
    )
    error_message = "A customer key must be added to both dynamic views without changing unrelated entries."
  }
}

run "runtime_slug_wins" {
  command = apply

  variables {
    custom_override_file = "./examples/customer_overrides/naming-overrides.json"
    slug_overrides = {
      database_account         = "runtime"
      storage_account_internal = "private"
    }
  }

  assert {
    condition = (
      output.names.database_account.slug == "runtime" &&
      output.names.database_account.slug_source == "override" &&
      output.names.storage_account_internal.slug == "private" &&
      output.names.static_site.max_length == 30
    )
    error_message = "slug_overrides must remain above all files, including customer-added keys."
  }
}

run "explicit_values_and_alias_isolation" {
  command = apply

  variables {
    custom_override_file = "./tests/unit/fixtures/customer_values.json"
    prefix               = ["Contoso"]
  }

  assert {
    condition = (
      output.names.storage_account.slug == "" &&
      output.names.storage_account.name == "Contoso" &&
      output.names.storage_account.min_length == 0 &&
      output.names.storage_account.max_length == null &&
      output.names.storage_account.regex == null &&
      !output.names.storage_account.validation_complete &&
      output.names.storage_account.validation.valid_name == null &&
      length(output.names.storage_account.validation_notes) > 0
    )
    error_message = "Explicit empty, zero, false, and null values must override defaults without retaining a false validation guarantee."
  }

  assert {
    condition = (
      length(local.catalog.site_web_app.forbidden_suffixes) == 0 &&
      local.catalog.site_web_app.reserved_names == ["admin"] &&
      local.catalog.site_web_app.forbidden_prefixes == local.bundled_catalog.site_web_app.forbidden_prefixes &&
      local.catalog.storage_account.source == { organization = "Contoso" } &&
      output.names.organization_label.name == "contosoteam" &&
      output.names.organization_label.validation.valid_name == null
    )
    error_message = "Supplied arrays and metadata objects replace as properties; omitted arrays and new-entry defaults must be retained."
  }

  assert {
    condition = (
      output.resource_group.name == output.names.resource_group.name &&
      output.resource_group.slug == "rg" &&
      output.storage_account.name == output.names.storage_account.name &&
      local.legacy_catalog_keys.resource_group == "resource_group"
    )
    error_message = "Customer metadata must not reassign the deprecated alias mapping."
  }
}

run "invalid_entries_fail" {
  command = plan

  variables {
    custom_override_file = "./tests/unit/fixtures/invalid_catalog_entries.json"
  }

  expect_failures = [output.names, output.names_by_azure_type]

  assert {
    condition     = alltrue([for valid in values(local.customer_entry_valid) : !valid])
    error_message = "Every invalid entry in the fixture must be rejected, not just the first."
  }
}

run "unsupported_schema_fails" {
  command = plan

  variables {
    custom_override_file = "./tests/unit/fixtures/invalid_catalog_schema.json"
  }

  expect_failures = [output.names, output.names_by_azure_type]
}

run "non_object_resources_fail" {
  command = plan

  variables {
    custom_override_file = "./tests/unit/fixtures/invalid_catalog_shape.json"
  }

  expect_failures = [output.names, output.names_by_azure_type]
}

run "malformed_json_fails" {
  command = plan

  variables {
    custom_override_file = "./tests/unit/fixtures/malformed_catalog.txt"
  }

  expect_failures = [output.names, output.names_by_azure_type]
}

run "missing_file_fails" {
  command = plan

  variables {
    custom_override_file = "./tests/unit/fixtures/does-not-exist.json"
  }

  expect_failures = [var.custom_override_file]
}

run "legacy_ignores_malformed_customer_file" {
  command = apply

  variables {
    legacy_mode          = true
    custom_override_file = "./tests/unit/fixtures/malformed_catalog.txt"
  }

  assert {
    condition = (
      output.storage_account.name == "st" &&
      output.cosmosdb_account.slug == "cosmos" &&
      length(output.names) == 0 &&
      length(output.names_by_azure_type) == 0 &&
      length(local.generated_catalog.resources) == 0 &&
      length(local.manual_catalog.resources) == 0 &&
      length(local.customer_catalog.resources) == 0
    )
    error_message = "Legacy mode must not read or depend on any modern catalog or customer file."
  }
}
