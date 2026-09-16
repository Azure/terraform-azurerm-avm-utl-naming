module "naming" {
  source = "../.."

  instance = 7
  naming_templates = {
    name        = "$${join(separator, compact([slug, substr(sha256(jsonencode([prefix, suffix])), 0, 8), instance]))}"
    name_unique = "$${join(separator, compact([slug, substr(sha256(jsonencode([prefix, suffix])), 0, 8), instance, unique]))}"
  }
  prefix      = ["payments"]
  suffix      = ["prod", "uks"]
  unique_seed = "abcd1234"
}
