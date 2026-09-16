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

module "literal_template" {
  source = "../.."

  instance = 1
  naming_template_variables = {
    environment = "dev"
    location    = "uks"
  }
  naming_templates = {
    name = "$${slug}-$${environment}-$${location}-$${instance}"
  }
  unique_length = 0
}

module "separator_aware" {
  source = "../.."

  instance = 1
  naming_template_variables = {
    environment = "dev"
    location    = "uks"
  }
  naming_templates = {
    name = "$${slug}$${separator}$${environment}$${separator}$${location}$${separator}$${instance}"
  }
  unique_length = 0
}
