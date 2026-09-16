mock_provider "random" {}

variables {
  suffix      = ["workload", "dev"]
  unique_seed = "abcd1234"
}

run "compact_modern_components" {
  command = apply

  variables {
    prefix        = ["", "Team", null, ""]
    suffix        = ["", null, "Dev", ""]
    unique_length = 0
  }

  assert {
    condition = (
      output.names.resource_group.name == "Team-rg-Dev" &&
      output.names.storage_account.name == "teamstdev" &&
      output.names.resource_group.name_unique == output.names.resource_group.name &&
      output.names.resource_group.instance == null &&
      output.names.resource_group.separator == "-" &&
      output.names.storage_account.separator == "" &&
      output.names_by_azure_type[output.names.resource_group.resource_type].resource_group.separator == "-"
    )
    error_message = "Modern empty/null components must disappear without changing casing or catalog separator metadata."
  }
}

run "formatted_instance" {
  command = apply

  variables {
    instance = 1
  }

  assert {
    condition = (
      output.names.resource_group.name == "rg-workload-dev-001" &&
      output.names.resource_group.name_unique == "rg-workload-dev-001-abcd" &&
      output.names.storage_account.name == "stworkloaddev001" &&
      output.names.storage_account.name_unique == "stworkloaddev001abcd" &&
      output.names.resource_group.instance == "001" &&
      output.names.resource_group.name_available &&
      output.names.resource_group.instance_retained.name &&
      output.names.resource_group.instance_retained.name_unique
    )
    error_message = "The module must append its three-digit formatted instance after the suffix and before uniqueness."
  }
}

run "zero_instance" {
  command = apply

  variables {
    instance = 0
  }

  assert {
    condition     = output.names.resource_group.instance == "000" && endswith(output.names.resource_group.name, "-000")
    error_message = "Zero must be an explicit formatted instance, not an omitted value."
  }
}

run "custom_instance_format" {
  command = apply

  variables {
    instance        = 20
    instance_format = "%02d"
  }

  assert {
    condition     = output.names.resource_group.instance == "20" && output.names.resource_group.name == "rg-workload-dev-20"
    error_message = "The instance format must be overridable inside the module."
  }
}

run "minimum_width_not_cap" {
  command = apply

  variables {
    instance = 1000
  }

  assert {
    condition     = output.names.resource_group.instance == "1000" && endswith(output.names.resource_group.name, "-1000")
    error_message = "The default format width must not truncate larger instance identifiers."
  }
}

run "instance_survives_truncation" {
  command = apply

  variables {
    prefix   = [join("", [for i in range(100) : "a"])]
    instance = 1
  }

  assert {
    condition = (
      length(output.names.storage_account.name) == 24 &&
      length(output.names.storage_account.name_unique) == 24 &&
      endswith(output.names.storage_account.name, "001") &&
      endswith(output.names.storage_account.name_unique, "001abcd") &&
      output.names.storage_account.instance_retained.name &&
      output.names.storage_account.instance_retained.name_unique &&
      output.names.storage_account.unique_suffix_retained
    )
    error_message = "Truncation must reserve room for both the complete instance and uniqueness tokens."
  }
}

run "truncated_instances_remain_distinct" {
  command = apply

  variables {
    prefix   = [join("", [for i in range(100) : "a"])]
    instance = 20
  }

  assert {
    condition = (
      endswith(output.names.storage_account.name, "020") &&
      endswith(output.names.storage_account.name_unique, "020abcd") &&
      output.names.storage_account.name != run.instance_survives_truncation.names.storage_account.name &&
      output.names.storage_account.name_unique != run.instance_survives_truncation.names.storage_account.name_unique
    )
    error_message = "Distinct instances must not collapse to the same name after truncation."
  }
}

run "custom_instance_position" {
  command = apply

  variables {
    instance = 20
    naming_templates = {
      name = "$${join(separator, compact(concat([instance, slug], suffix)))}"
    }
  }

  assert {
    condition = (
      output.names.resource_group.name == "020-rg-workload-dev" &&
      output.names.resource_group.name_unique == "020-rg-workload-dev-abcd" &&
      output.names.resource_group.instance_retained.name &&
      output.names.resource_group.instance_retained.name_unique
    )
    error_message = "Custom templates must receive the already-formatted instance token."
  }
}

run "custom_unique_instance_position" {
  command = apply

  variables {
    instance = 1
    naming_templates = {
      name_unique = "$${join(separator, compact([unique, name]))}"
    }
  }

  assert {
    condition = (
      output.names.resource_group.name_unique == "abcd-rg-workload-dev-001" &&
      output.names.resource_group.instance_retained.name_unique &&
      output.names.resource_group.unique_suffix_retained
    )
    error_message = "Custom unique templates must retain instances carried through the bounded name token."
  }
}

run "instance_only_in_unique_template" {
  command = apply

  variables {
    instance = 1
    naming_templates = {
      name        = "$${slug}"
      name_unique = "$${join(separator, [name, instance, unique])}"
    }
  }

  assert {
    condition = (
      output.names.resource_group.name == null &&
      output.names.resource_group.name_unique == "rg-001-abcd" &&
      output.names.resource_group.name_unique_available
    )
    error_message = "A feasible unique template must remain usable independently of an omitted normal-name instance."
  }
}

run "case_converted_instance" {
  command = apply

  variables {
    instance        = 1
    instance_format = "id%03d"
    naming_templates = {
      name = "$${join(separator, [upper(instance), slug])}"
    }
  }

  assert {
    condition = (
      output.names.resource_group.instance == "id001" &&
      output.names.resource_group.name == "ID001-rg" &&
      output.names.resource_group.name_unique == "ID001-rg-abcd" &&
      output.names.resource_group.instance_retained.name &&
      output.names.resource_group.instance_retained.name_unique
    )
    error_message = "Whole-token case conversions must preserve the instance."
  }
}

run "unverifiable_instance_transform" {
  command = apply

  variables {
    instance = 1
    naming_templates = {
      name = "$${format(\"%d\", tonumber(instance))}"
    }
  }

  assert {
    condition = (
      output.names.resource_group.name == null &&
      output.names.resource_group.name_unique == null &&
      length(output.names.resource_group.name_errors) > 0
    )
    error_message = "Lossy instance transformations must produce explicit diagnostics rather than a probe evaluation error."
  }
}

run "coincidental_digits_are_not_instance_interpolation" {
  command = apply

  variables {
    instance = 1
    prefix   = ["001"]
    naming_templates = {
      name = "$${join(separator, compact(concat(prefix, [slug], suffix)))}"
    }
  }

  assert {
    condition = (
      output.names.resource_group.name == null &&
      output.names.resource_group.name_unique == null &&
      !output.names.resource_group.instance_retained.name &&
      !output.names.resource_group.instance_retained.name_unique &&
      length(output.names.resource_group.name_errors) > 0
    )
    error_message = "A matching literal in the prefix must not disguise omission of the instance token."
  }
}

run "custom_template_loses_instance" {
  command = apply

  variables {
    instance = 1
    prefix   = [join("", [for i in range(100) : "a"])]
    naming_templates = {
      name = "$${join(separator, compact(concat(prefix, [slug, \"fixed\"], suffix, [instance])))}"
    }
  }

  assert {
    condition = (
      output.names.storage_account.name == null &&
      output.names.storage_account.name_unique == null &&
      !output.names.storage_account.name_available &&
      !output.names.storage_account.name_unique_available
    )
    error_message = "A custom template that truncates away the instance must be explicitly unusable."
  }
}

run "oversized_instance_is_per_entry" {
  command = apply

  variables {
    instance        = 1
    instance_format = "%030d"
  }

  assert {
    condition = (
      output.names.storage_account.name == null &&
      output.names.storage_account.name_unique == null &&
      length(output.names.storage_account.name_errors) > 0 &&
      output.names.resource_group.name_available &&
      output.names.resource_group.name_unique_available
    )
    error_message = "An instance too large for one resource type must not block feasible catalog entries."
  }
}

run "existing_custom_instance_token" {
  command = apply

  variables {
    naming_template_variables = {
      instance = "existing"
    }
    naming_templates = {
      name = "$${join(separator, [slug, instance])}"
    }
  }

  assert {
    condition     = output.names.resource_group.name == "rg-existing" && output.names.resource_group.instance == null
    error_message = "An existing custom instance token must remain supported when the new numeric input is omitted."
  }
}

run "legacy_ignores_instance_customization" {
  command = apply

  variables {
    legacy_mode     = true
    instance        = 20
    instance_format = "%Q"
    naming_template_variables = {
      instance = "ignored"
    }
    naming_templates = {
      name = "$${undefined_modern_token}"
    }
  }

  assert {
    condition = (
      output.resource_group.name == "rg-workload-dev" &&
      output.resource_group.name_unique == "rg-workload-dev-abcd" &&
      length(output.names) == 0 &&
      length(random_string.main) == 1 &&
      length(random_string.modern) == 0
    )
    error_message = "New instance inputs and templates must not affect legacy rendering or resources."
  }
}

run "negative_instance_rejected" {
  command = plan

  variables {
    instance = -1
  }

  expect_failures = [var.instance]
}

run "fractional_instance_rejected" {
  command = plan

  variables {
    instance = 1.5
  }

  expect_failures = [var.instance]
}

run "invalid_instance_format_rejected" {
  command = plan

  variables {
    instance        = 1
    instance_format = "%Q"
  }

  expect_failures = [var.instance_format]
}

run "empty_instance_format_rejected" {
  command = plan

  variables {
    instance        = 1
    instance_format = ""
  }

  expect_failures = [var.instance_format]
}

run "instance_token_collision_rejected" {
  command = plan

  variables {
    instance = 1
    naming_template_variables = {
      instance = "not-allowed"
    }
  }

  expect_failures = [var.naming_template_variables]
}
