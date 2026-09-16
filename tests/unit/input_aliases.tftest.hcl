mock_provider "random" {}

override_resource {
  target = random_string.modern_first_letter
  values = {
    result = "a"
  }
}

override_resource {
  target = random_string.modern
  values = {
    result = "bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb"
  }
}

run "deprecated_inputs" {
  command = apply

  variables {
    unique-include-numbers = false
    unique-length          = 2
    unique-seed            = "Z9abcdefgh"
  }

  assert {
    condition = (
      local.unique_include_numbers == false &&
      length(random_string.modern) == 0 &&
      output.names.storage_account.unique_seed == "Z9abcdefgh" &&
      endswith(output.names.storage_account.name_unique, "z9")
    )
    error_message = "Deprecated inputs must continue to supply their values when replacement inputs are omitted."
  }
}

run "replacement_inputs" {
  command = apply

  variables {
    unique_include_numbers = false
    unique_length          = 2
    unique_seed            = "Z9abcdefgh"
  }

  assert {
    condition     = output.names == run.deprecated_inputs.names && local.unique_include_numbers == false && length(random_string.modern) == 0
    error_message = "The replacement inputs must produce the same current naming results as their deprecated aliases."
  }
}

run "replacement_values_take_precedence" {
  command = apply

  variables {
    unique-include-numbers = false
    unique-length          = 8
    unique-seed            = "OldSeed"
    unique_include_numbers = true
    unique_length          = 3
    unique_seed            = "NewSeed"
  }

  assert {
    condition = (
      local.unique_include_numbers == true &&
      length(random_string.modern) == 0 &&
      output.names.storage_account.unique_seed == "NewSeed" &&
      endswith(output.names.storage_account.name_unique, "new") &&
      output.unique-seed == "NewSeed"
    )
    error_message = "Replacement values must override conflicting aliases, including the deprecated seed output."
  }
}

run "false_zero_and_empty_are_explicit" {
  command = apply

  variables {
    unique-include-numbers = true
    unique-length          = 8
    unique-seed            = "OldSeed"
    unique_include_numbers = false
    unique_length          = 0
    unique_seed            = ""
  }

  assert {
    condition = (
      local.unique_include_numbers == false &&
      length(random_string.modern) == 0 &&
      length(random_string.modern_first_letter) == 0 &&
      output.names.storage_account.unique_seed == null &&
      output.unique-seed == output.names.storage_account.unique_seed &&
      alltrue([for entry in values(output.names) : entry.name == entry.name_unique])
    )
    error_message = "Explicit false, zero, and empty-string replacements must not fall back to nonempty deprecated values."
  }
}

run "null_replacements_use_aliases" {
  command = apply

  variables {
    unique-include-numbers = false
    unique-length          = 2
    unique-seed            = "Z9abcdefgh"
    unique_include_numbers = null
    unique_length          = null
    unique_seed            = null
  }

  assert {
    condition     = output.names == run.deprecated_inputs.names && local.unique_include_numbers == false && length(random_string.modern) == 0
    error_message = "Explicit null replacements must leave the deprecated inputs effective."
  }
}
