module "naming" {
  source = "../.."

  naming_template_variables = {
    environment = "dev"
    location    = "uks"
    sequence    = "001"
  }
  naming_templates = {
    name = "$${slug}-$${environment}-$${location}-$${sequence}"
  }
  unique_length = 0
}

module "separator_aware" {
  source = "../.."

  naming_template_variables = {
    environment = "dev"
    location    = "uks"
    sequence    = "001"
  }
  naming_templates = {
    name = "$${slug}$${separator}$${environment}$${separator}$${location}$${separator}$${sequence}"
  }
  unique_length = 0
}
