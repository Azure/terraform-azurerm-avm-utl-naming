module "naming" {
  source = "../.."

  naming_template_variables = {
    environment = "dev"
    location    = "uks"
  }
  naming_templates = {
    name        = "$${join(separator, compact([slug, environment, location]))}"
    name_unique = "$${join(separator, compact([unique, name]))}"
  }
  unique_seed = "abcd1234"
}
