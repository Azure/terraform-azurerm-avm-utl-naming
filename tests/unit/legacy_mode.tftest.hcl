mock_provider "random" {}

variables {
  legacy_mode = true
  unique_seed = "abcd1234"
}

run "mixed_case_contract" {
  command = apply

  variables {
    prefix = ["Contoso"]
    suffix = ["Prod"]
  }

  assert {
    condition = (
      output.cosmosdb_account.name == "Contoso-cosmos-Prod" &&
      output.mssql_server.name == "Contoso-sql-Prod" &&
      output.container_app.name == "Contoso-ca-Prod" &&
      output.container_registry.name == "contosoacrprod" &&
      output.container_registry_webhook.name == "contosocrwhprod" &&
      output.redis_firewall_rule.name == "contosoredisfwprod" &&
      output.shared_image_gallery.name == "contososigprod"
    )
    error_message = "Legacy mode must preserve original separator and casing behavior."
  }

  assert {
    condition = (
      output.role_assignment.name == "Contoso-ra-Prod" &&
      output.role_assignment.name_unique == "Contoso-ra-Prod-abcd" &&
      output.container_registry.scope == "resourceGroup" &&
      output.app_service.scope == "global"
    )
    error_message = "Legacy mode must preserve original naming modes and scope tokens."
  }

  assert {
    condition = (
      length(output.names) == 0 && length(output.names_by_azure_type) == 0 &&
      alltrue([for entry in values(output.validation) : entry.valid_name != null && entry.valid_name_unique != null]) &&
      alltrue([for entry in values(local.az) : entry.regex != null && entry.min_length != null && entry.max_length != null && entry.scope != null])
    )
    error_message = "The legacy output contract must remain independent of modern nullable metadata."
  }

  assert {
    condition     = length(regexall(output.key_vault.regex, "Contoso-kv-Prod")) > 0
    error_message = "The original legacy regex must continue to accept legal uppercase letters."
  }
}

run "per_alias_length_limits" {
  command = apply

  variables {
    prefix = ["contosoenterprisegroup", "platform"]
    suffix = ["westeurope", "prod", "001"]
  }

  assert {
    condition = (
      output.windows_virtual_machine.max_length == 15 &&
      output.virtual_machine.max_length == 15 &&
      output.linux_virtual_machine.max_length == 64 &&
      output.windows_virtual_machine.name == "contosoenterpri" &&
      output.windows_virtual_machine_scale_set.max_length == 15 &&
      length(output.windows_virtual_machine_scale_set.name) == 15 &&
      output.container_registry.max_length == 63 &&
      output.machine_learning_workspace.max_length == 260
    )
    error_message = "Shared modern Azure types must not collapse distinct legacy per-alias limits."
  }
}

run "legacy_validation_and_zero_length" {
  command = apply

  variables {
    unique_length = 0
    suffix        = ["example"]
  }

  assert {
    condition     = output.resource_group.name == "rg-example" && output.resource_group.name_unique == "rg-example-"
    error_message = "The frozen renderer must retain even the original zero-length separator behavior."
  }

  assert {
    condition = alltrue([
      for key, entry in local.az :
      output.validation[key].valid_name == (length(regexall(entry.regex, entry.name)) > 0 && length(entry.name) > entry.min_length) &&
      output.validation[key].valid_name_unique == (length(regexall(entry.regex, entry.name_unique)) > 0)
    ])
    error_message = "The deprecated validation output must retain its original boolean semantics."
  }
}

run "modern_customization_is_isolated" {
  command = apply

  variables {
    prefix = ["Contoso"]
    suffix = ["Prod"]
    slug_overrides = {
      storage_account = "changed"
    }
    naming_templates = {
      name        = "$${undefined_modern_token}"
      name_unique = "$${another_undefined_token}"
    }
  }

  assert {
    condition     = output.storage_account.name == "contosostprod" && output.storage_account.name_unique == "contosostprodabcd"
    error_message = "Modern templates and overrides must not affect the frozen legacy renderer."
  }
}
