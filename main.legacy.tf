resource "random_string" "first_letter" {
  count = var.legacy_mode ? 1 : 0

  length  = 1
  numeric = false
  special = false
  upper   = false
}

resource "random_string" "main" {
  count = var.legacy_mode ? 1 : 0

  length  = 60
  numeric = local.unique_include_numbers
  special = false
  upper   = false
}
