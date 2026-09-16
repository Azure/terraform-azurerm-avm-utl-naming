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
    result = "123456789012345678901234567890123456789012345678901234567890"
  }
}

run "default_random_seed" {
  command = apply

  assert {
    condition     = output.names.storage_account.unique_seed == "a123456789012345678901234567890123456789012345678901234567890"
    error_message = "The full 61-character seed must begin with the independently generated letter."
  }

  assert {
    condition     = endswith(output.names.resource_group.name_unique, "-a123") && endswith(output.names.storage_account.name_unique, "a123")
    error_message = "Only the first four seed characters must be used by default."
  }

  assert {
    condition = (
      length(random_string.main) == 0 &&
      length(random_string.first_letter) == 0 &&
      random_string.modern[0].length == 60 &&
      random_string.modern[0].numeric == true &&
      random_string.modern[0].special == false &&
      random_string.modern[0].upper == false &&
      random_string.modern_first_letter[0].length == 1 &&
      random_string.modern_first_letter[0].numeric == false &&
      random_string.modern_first_letter[0].special == false &&
      random_string.modern_first_letter[0].upper == false
    )
    error_message = "Random generation must use a leading letter and the configured number policy."
  }
}

run "null_seed" {
  command = apply

  variables {
    unique_seed = null
  }

  assert {
    condition     = output.names.storage_account.unique_seed == run.default_random_seed.names.storage_account.unique_seed
    error_message = "A null custom seed must retain the state-persisted random fallback."
  }
}

run "seed_longer_than_requested_suffix" {
  command = apply

  variables {
    unique_length = 2
    unique_seed   = "Z9abcdefgh"
  }

  assert {
    condition = (
      output.names.storage_account.unique_seed == "Z9abcdefgh" &&
      length(random_string.modern) == 0 &&
      length(random_string.modern_first_letter) == 0 &&
      endswith(output.names.resource_group.name_unique, "-Z9") &&
      endswith(output.names.storage_account.name_unique, "z9")
    )
    error_message = "Seed truncation and resource-specific lowercasing must not change the seed output."
  }
}

run "numbers_disabled" {
  command = apply

  variables {
    unique_include_numbers = false
    unique_seed            = "X9abcd"
  }

  assert {
    condition     = length(random_string.modern) == 0 && length(random_string.modern_first_letter) == 0 && endswith(output.names.resource_group.name_unique, "-X9ab")
    error_message = "Disabling generated numbers must not alter a user-supplied seed."
  }
}

run "generated_without_numbers" {
  command = apply

  variables {
    unique_include_numbers = false
  }

  assert {
    condition     = random_string.modern[0].numeric == false && random_string.modern_first_letter[0].numeric == false
    error_message = "The number policy must still configure generated modern seeds."
  }
}

run "empty_seed_uses_random_fallback" {
  command = apply

  variables {
    unique_seed = ""
  }

  assert {
    condition     = length(random_string.modern) == 1 && output.names.storage_account.unique_seed == run.default_random_seed.names.storage_account.unique_seed
    error_message = "An empty seed must select generation when uniqueness is needed."
  }
}

run "zero_length_needs_no_seed" {
  command = apply

  variables {
    prefix        = [join("", [for i in range(100) : "a"])]
    unique_length = 0
  }

  assert {
    condition = (
      length(random_string.modern) == 0 &&
      length(random_string.modern_first_letter) == 0 &&
      length(random_string.main) == 0 &&
      length(random_string.first_letter) == 0 &&
      output.names.storage_account.unique_seed == null &&
      alltrue([for entry in values(output.names) : entry.name == entry.name_unique])
    )
    error_message = "Zero uniqueness must create no random resources and keep default names equal, including GUID names."
  }
}

run "zero_length_preserves_explicit_seed" {
  command = apply

  variables {
    unique_length = 0
    unique_seed   = "FixedSeed"
  }

  assert {
    condition     = length(random_string.modern) == 0 && output.names.storage_account.unique_seed == "FixedSeed"
    error_message = "An unused supplied seed must remain observable without creating random resources."
  }
}

run "legacy_keeps_original_resources" {
  command = apply

  variables {
    legacy_mode   = true
    unique_length = 0
    unique_seed   = "LegacySeed"
  }

  assert {
    condition = (
      length(random_string.main) == 1 &&
      length(random_string.first_letter) == 1 &&
      length(random_string.modern) == 0 &&
      length(random_string.modern_first_letter) == 0 &&
      output.unique-seed == "LegacySeed"
    )
    error_message = "Legacy mode must retain its original resources even when their values are unused."
  }
}

run "unicode_components" {
  command = apply

  variables {
    prefix      = ["\u00c9quipe"]
    suffix      = ["\u6771\u4eac", "\u00e9"]
    unique_seed = "a1b2c3d4"
  }

  assert {
    condition = (
      startswith(output.names.resource_group.name, "\u00c9quipe-") &&
      endswith(output.names.resource_group.name, "-\u6771\u4eac-\u00e9") &&
      startswith(output.names.storage_account.name, "\u00e9quipe") &&
      endswith(output.names.storage_account.name, "\u6771\u4eac\u00e9")
    )
    error_message = "Unicode case conversion and concatenation must retain Terraform string semantics."
  }
}
