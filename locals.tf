locals {
  az                     = var.legacy_mode ? local.legacy_az : local.modern_aliases
  random                 = substr(local.unique_seed, 0, local.unique_length)
  random_safe_generation = join("", [random_string.first_letter.result, random_string.main.result])
  unique_include_numbers = var.unique_include_numbers != null ? var.unique_include_numbers : var.unique-include-numbers
  unique_length          = var.unique_length != null ? var.unique_length : var.unique-length
  unique_seed            = coalesce(local.unique_seed_input, local.random_safe_generation)
  unique_seed_input      = var.unique_seed != null ? var.unique_seed : var.unique-seed
  validation             = var.legacy_mode ? local.legacy_validation : local.modern_alias_validation
}
