mock_provider "random" {}

variables {
  instance      = 1
  unique_length = 0
  naming_template_variables = {
    environment = "dev"
    location    = "uks"
  }
}

run "literal_tokens" {
  command = apply

  variables {
    naming_templates = {
      name = "$${slug}-$${environment}-$${location}-$${instance}"
    }
  }

  assert {
    condition = (
      output.names.resource_group.name == "rg-dev-uks-001" &&
      output.names.resource_group.name_unique == output.names.resource_group.name &&
      output.names.resource_group.name_available &&
      output.names.storage_account.validation.valid_name == false
    )
    error_message = "Literal hyphens must stay literal; the template is suitable only for resource types that allow them."
  }
}

run "separator_tokens" {
  command = apply

  variables {
    naming_templates = {
      name = "$${slug}$${separator}$${environment}$${separator}$${location}$${separator}$${instance}"
    }
  }

  assert {
    condition = (
      output.names.resource_group.name == "rg-dev-uks-001" &&
      output.names.storage_account.name == "stdevuks001" &&
      output.names.storage_account.name_unique == output.names.storage_account.name &&
      output.names.resource_group.name_available &&
      output.names.storage_account.validation.valid_name
    )
    error_message = "Direct separator-token interpolation must support dashed and separator-free names without functions."
  }
}

run "formatted_instance_token" {
  command = apply

  variables {
    instance        = 3
    instance_format = "%04d"
    naming_templates = {
      name = "$${slug}-$${environment}-$${location}-$${instance}"
    }
  }

  assert {
    condition = (
      output.names.resource_group.name == "rg-dev-uks-0003" &&
      output.names.resource_group.name_unique == output.names.resource_group.name &&
      output.names.resource_group.instance_retained.name &&
      output.names.resource_group.instance_retained.name_unique
    )
    error_message = "Simple templates must receive module-formatted numeric instances without inline format functions."
  }
}
