mock_provider "random" {}

variables {
  unique_seed = "a1b2c3d4"
}

run "custom_template_tokens" {
  command = apply

  variables {
    naming_template_variables = {
      environment = "dev"
      location    = "uks"
    }
    naming_templates = {
      name        = "$${join(separator, compact([slug, environment, location]))}"
      name_unique = "$${join(separator, compact([unique, name]))}"
    }
  }

  assert {
    condition = (
      output.names.storage_account.name == "stdevuks" &&
      output.names.storage_account.name_unique == "a1b2stdevuks" &&
      output.names.resource_group.name == "rg-dev-uks" &&
      output.names.resource_group.name_unique == "a1b2-rg-dev-uks"
    )
    error_message = "Escaped template interpolation must resolve built-in and custom tokens."
  }
}

run "unique_suffix_survives_truncation" {
  command = apply

  variables {
    prefix = [join("", [for i in range(1000) : "a"])]
  }

  assert {
    condition = alltrue([
      for key, entry in output.names :
      entry.unique_suffix_retained &&
      (entry.max_length == null ? true : length(entry.name_unique) <= entry.max_length)
      if entry.name_kind == "standard"
    ])
    error_message = "Default unique naming must reserve room for the uniqueness token before truncating."
  }

  assert {
    condition     = endswith(output.names.storage_account.name_unique, "a1b2") && output.names.storage_account.name_unique != output.names.storage_account.name
    error_message = "A long storage-account base must not consume its uniqueness token."
  }
}

run "manual_rule_overrides" {
  command = apply

  assert {
    condition = alltrue([
      for key, override in local.manual_catalog.overrides :
      output.names[key].max_length == override.settings.max_length
      if contains(keys(override.settings), "max_length")
    ])
    error_message = "Reviewed maximum-length overrides must reach the modern output."
  }
}

run "reserved_token_override" {
  command = plan

  variables {
    naming_template_variables = {
      slug = "not-allowed"
    }
  }

  expect_failures = [var.naming_template_variables]
}

run "missing_uniqueness_token" {
  command = plan

  variables {
    naming_templates = {
      name_unique = "constant"
    }
  }

  expect_failures = [output.names, output.names_by_azure_type]
}

run "oversized_unique_template" {
  command = plan

  variables {
    naming_template_variables = {
      long_value = join("", [for i in range(1000) : "a"])
    }
    naming_templates = {
      name_unique = "$${long_value}$${unique}"
    }
  }

  expect_failures = [output.names, output.names_by_azure_type]
}
