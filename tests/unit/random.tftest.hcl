mock_provider "random" {}

override_resource {
  target = random_string.first_letter
  values = {
    result = "a"
  }
}

override_resource {
  target = random_string.main
  values = {
    result = "123456789012345678901234567890123456789012345678901234567890"
  }
}

run "default_random_seed" {
  command = apply

  assert {
    condition     = output.unique-seed == "a123456789012345678901234567890123456789012345678901234567890"
    error_message = "The full 61-character seed must begin with the independently generated letter."
  }

  assert {
    condition     = output.resource_group.name_unique == "rg-a123" && output.storage_account.name_unique == "sta123"
    error_message = "Only the first four seed characters must be used by default."
  }

  assert {
    condition = (
      random_string.main.length == 60 &&
      random_string.main.numeric == true &&
      random_string.main.special == false &&
      random_string.main.upper == false &&
      random_string.first_letter.length == 1 &&
      random_string.first_letter.numeric == false &&
      random_string.first_letter.special == false &&
      random_string.first_letter.upper == false
    )
    error_message = "Legacy random resource addresses and configuration must remain unchanged."
  }
}

run "null_seed" {
  command = apply

  variables {
    unique-seed = null
  }

  assert {
    condition     = output.unique-seed == run.default_random_seed.unique-seed
    error_message = "A null custom seed must retain the state-persisted random fallback."
  }
}

run "seed_longer_than_requested_suffix" {
  command = apply

  variables {
    unique-length = 2
    unique-seed   = "Z9abcdefgh"
  }

  assert {
    condition = (
      output.unique-seed == "Z9abcdefgh" &&
      output.resource_group.name_unique == "rg-Z9" &&
      output.storage_account.name_unique == "stz9"
    )
    error_message = "Seed truncation and resource-specific lowercasing must not change the seed output."
  }
}

run "numbers_disabled" {
  command = apply

  variables {
    unique-include-numbers = false
    unique-seed            = "X9abcd"
  }

  assert {
    condition     = random_string.main.numeric == false && output.resource_group.name_unique == "rg-X9ab"
    error_message = "Disabling generated numbers must not alter a user-supplied seed."
  }
}

run "unicode_components" {
  command = apply

  variables {
    prefix      = ["\u00c9quipe"]
    suffix      = ["\u6771\u4eac", "\u00e9"]
    unique-seed = "a1b2c3d4"
  }

  assert {
    condition = (
      output.resource_group.name == "\u00c9quipe-rg-\u6771\u4eac-\u00e9" &&
      output.storage_account.name == "\u00e9quipest\u6771\u4eac\u00e9"
    )
    error_message = "Unicode case conversion and concatenation must retain Terraform string semantics."
  }
}
