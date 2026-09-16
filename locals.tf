locals {
  az                     = var.legacy_mode ? local.legacy_az : local.modern_aliases
  modern_random_required = var.legacy_mode ? false : local.unique_length != 0 && (local.unique_seed_input == null || local.unique_seed_input == "")
  random                 = !var.legacy_mode && local.unique_length == 0 ? "" : substr(local.unique_seed, 0, local.unique_length)
  random_required        = var.legacy_mode || local.modern_random_required
  random_safe_generation = var.legacy_mode ? (
    join("", [random_string.first_letter[0].result, random_string.main[0].result])
  ) : local.modern_random_required ? join("", [random_string.modern_first_letter[0].result, random_string.modern[0].result]) : null
  unique_include_numbers = var.unique_include_numbers != null ? var.unique_include_numbers : var.unique-include-numbers
  unique_length          = var.unique_length != null ? var.unique_length : var.unique-length
  unique_seed            = local.random_required ? coalesce(local.unique_seed_input, local.random_safe_generation) : local.unique_seed_input == "" ? null : local.unique_seed_input
  unique_seed_input      = var.unique_seed != null ? var.unique_seed : var.unique-seed
  validation             = var.legacy_mode ? local.legacy_validation : local.modern_alias_validation
}
