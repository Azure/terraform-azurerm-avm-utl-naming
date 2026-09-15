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
      for key, override in local.manual_catalog.resources :
      output.names[key].max_length == override.max_length
      if contains(keys(override), "max_length")
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
  command = apply

  variables {
    naming_templates = {
      name_unique = "constant"
    }
  }

  assert {
    condition = (
      output.names.storage_account.name_unique == null &&
      !output.names.storage_account.name_unique_available &&
      !output.names.storage_account.unique_suffix_retained &&
      length(output.names.storage_account.name_unique_errors) > 0
    )
    error_message = "An omitted uniqueness token must make the affected entry explicitly unusable."
  }
}

run "oversized_unique_template" {
  command = apply

  variables {
    naming_template_variables = {
      long_value = join("", [for i in range(1000) : "a"])
    }
    naming_templates = {
      name_unique = "$${long_value}$${unique}"
    }
  }

  assert {
    condition = (
      output.names.storage_account.name_unique == null &&
      !output.names.storage_account.fits_max_length &&
      length(output.names.storage_account.name_unique_errors) > 0
    )
    error_message = "An oversized unique name must be reported on its entry, not fail the entire catalog."
  }
}

run "coincidental_prefix_is_not_uniqueness" {
  command = apply

  variables {
    prefix        = ["prod"]
    unique_seed   = "p"
    unique_length = 1
    naming_templates = {
      name_unique = "$${name}"
    }
  }

  assert {
    condition = (
      !output.names.storage_account.unique_suffix_retained &&
      !output.names.resource_group.unique_suffix_retained &&
      output.names.storage_account.name_unique == null &&
      output.names.resource_group.name_unique == null
    )
    error_message = "A seed appearing in the prefix must not disguise a missing unique interpolation."
  }
}

run "uppercase_unique_interpolation" {
  command = apply

  variables {
    prefix      = ["contoso"]
    unique_seed = "abcd"
    naming_templates = {
      name_unique = "$${name}$${upper(unique)}"
    }
  }

  assert {
    condition = (
      output.names.resource_group.unique_suffix_retained &&
      output.names.resource_group.name_unique_available &&
      endswith(output.names.resource_group.name_unique, "ABCD") &&
      output.names.storage_account.unique_suffix_retained &&
      endswith(output.names.storage_account.name_unique, "abcd")
    )
    error_message = "Whole-token case transformations must retain uniqueness."
  }
}

run "entry_capacity_is_independent" {
  command = apply

  variables {
    unique_seed   = "abcdefghijklmnopqrstuvwxyz"
    unique_length = 20
  }

  assert {
    condition = (
      output.names.storage_account.name_unique_available &&
      output.names.resource_group.name_unique_available &&
      output.names.storage_account.name_unique != null &&
      output.names.virtual_machine_scale_set.name_unique == null &&
      !output.names.virtual_machine_scale_set.fits_max_length
    )
    error_message = "A tight limit on an unused entry must not prevent generating feasible names."
  }
}

run "truncation_respects_boundary_rules" {
  command = apply

  variables {
    prefix = ["Contoso"]
    suffix = ["westeurope", "prod", "001"]
  }

  assert {
    condition = alltrue([
      for key, definition in local.catalog :
      alltrue([for ending in definition.forbidden_suffixes : !endswith(output.names[key].name, ending)])
      if definition.name_kind == "standard"
    ])
    error_message = "Truncation must not leave a suffix prohibited by the entry's boundary rules."
  }
}

run "windows_computer_name_variant" {
  command = apply

  variables {
    prefix = ["contosoenterprisegroup", "platform"]
    suffix = ["production"]
  }

  assert {
    condition = (
      output.names.virtual_machine_windows.resource_type == "Microsoft.Compute/virtualMachines" &&
      output.names.virtual_machine_windows.variant == "windows" &&
      output.names.virtual_machine_windows.max_length == 15 &&
      length(output.names.virtual_machine_windows.name) <= 15 &&
      length(output.names.virtual_machine_windows.name_unique) <= 15 &&
      output.names.compute_virtual_machine.max_length == 64 &&
      output.names.compute_virtual_machine.dashes &&
      startswith(output.names.compute_virtual_machine.name, "contosoenterprisegroup-platform-")
    )
    error_message = "The Windows-specific variant must preserve the computer-name cap without restricting generic ARM names."
  }
}
