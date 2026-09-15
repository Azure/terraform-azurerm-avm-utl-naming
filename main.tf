resource "random_string" "first_letter" {
  length  = 1
  numeric = false
  special = false
  upper   = false
}

resource "random_string" "main" {
  length  = 60
  numeric = local.unique_include_numbers
  special = false
  upper   = false
}
