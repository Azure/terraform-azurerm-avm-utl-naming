resource "random_string" "first_letter" {
  length  = 1
  numeric = false
  special = false
  upper   = false
}

resource "random_string" "main" {
  length  = 60
  numeric = var.unique-include-numbers
  special = false
  upper   = false
}
