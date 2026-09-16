moved {
  from = random_string.first_letter
  to   = random_string.first_letter[0]
}

moved {
  from = random_string.main
  to   = random_string.main[0]
}

resource "random_string" "modern_first_letter" {
  count = local.modern_random_required ? 1 : 0

  length  = 1
  numeric = false
  special = false
  upper   = false
}

resource "random_string" "modern" {
  count = local.modern_random_required ? 1 : 0

  length  = 60
  numeric = local.unique_include_numbers
  special = false
  upper   = false
}
