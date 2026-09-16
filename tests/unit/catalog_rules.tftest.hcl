mock_provider "random" {}

variables {
  unique_seed = "a1b2c3d4"
}

run "corrected_catalog_defaults" {
  command = apply

  variables {
    suffix = ["prod", "001"]
  }

  assert {
    condition = (
      output.names.storage_table.name == "sttprod001" &&
      output.names.storage_table.validation.valid_name &&
      output.names.storage_table.validation.valid_name_unique &&
      output.names.synapse_workspace.name == "synw-prod-001" &&
      output.names.synapse_workspace.validation.valid_name
    )
    error_message = "Storage tables must omit separators and Synapse must retain numeric suffixes."
  }

  assert {
    condition = alltrue([
      for key, slug in {
        automation_account_runbook                    = "aarb"
        firewall_application_rule_collection          = "fwapprc"
        namespace_notification_hub_authorization_rule = "nhar"
        namespace_topic_authorization_rule            = "sbtar"
      } : output.names[key].slug == slug && output.names[key].slug_source == "manual"
    ])
    error_message = "The reviewed modern abbreviation corrections must be used."
  }

  assert {
    condition = (
      output.names_by_azure_type["Microsoft.Monitor/accounts"].monitor_workspace.slug == "amw" &&
      output.names_by_azure_type["Microsoft.Insights/dataCollectionRuleAssociations"].data_collection_rule_association.slug == "dcra" &&
      output.names_by_azure_type["Microsoft.Compute/diskAccesses"].disk_access.slug == "da"
    )
    error_message = "New manual coverage must be available through the existing modern maps."
  }
}

run "numeric_boundaries" {
  command = apply

  variables {
    naming_templates = {
      name = "1abc2"
    }
  }

  assert {
    condition = (
      length(output.names_by_azure_type["Microsoft.DocumentDB/databaseAccounts"]) == 6 &&
      alltrue([
        for entry in values(output.names_by_azure_type["Microsoft.DocumentDB/databaseAccounts"]) :
        entry.name == "1abc2" && entry.validation.valid_name && entry.validation.valid_name_unique
      ]) &&
      output.names.synapse_workspace.name == "1abc2" &&
      output.names.synapse_workspace.validation.valid_name &&
      !output.names.storage_table.validation.valid_name
    )
    error_message = "Cosmos and Synapse accept numeric boundaries, but storage tables require a letter first."
  }
}

run "invalid_leading_hyphens" {
  command = apply

  variables {
    naming_templates = {
      name = "-abc"
    }
  }

  assert {
    condition = (
      alltrue([
        for entry in values(output.names_by_azure_type["Microsoft.DocumentDB/databaseAccounts"]) :
        !entry.validation.valid_name
      ]) &&
      !output.names.synapse_workspace.validation.valid_name &&
      !output.names.storage_table.validation.valid_name
    )
    error_message = "Leading hyphens must not validate for Cosmos, Synapse, or storage tables."
  }
}

run "reserved_synapse_sequence" {
  command = apply

  variables {
    naming_templates = {
      name = "synw-ondemand"
    }
  }

  assert {
    condition     = !output.names.synapse_workspace.validation.valid_name && !output.names.synapse_workspace.validation.valid_name_unique
    error_message = "Synapse workspace names must not contain -ondemand."
  }
}

run "reserved_storage_table" {
  command = apply

  variables {
    naming_templates = {
      name = "TABLES"
    }
  }

  assert {
    condition     = output.names.storage_table.name == "tables" && !output.names.storage_table.validation.valid_name
    error_message = "The reserved table name must be rejected case-insensitively."
  }
}

run "policy_definition_characters" {
  command = apply

  variables {
    naming_templates = {
      name = "policy/name"
    }
  }

  assert {
    condition     = output.names.policy_definition.slug == "pdef" && !output.names.policy_definition.validation.valid_name
    error_message = "Policy-definition resource names must reject prohibited characters without changing the slug."
  }
}

run "minimum_lengths" {
  command = apply

  variables {
    naming_templates = {
      name = "ab"
    }
  }

  assert {
    condition = (
      !output.names.storage_table.validation.valid_name &&
      alltrue([
        for entry in values(output.names_by_azure_type["Microsoft.DocumentDB/databaseAccounts"]) :
        !entry.validation.valid_name
      ]) &&
      output.names.policy_definition.validation.valid_name &&
      output.names.synapse_workspace.validation.valid_name
    )
    error_message = "Resource-specific minimum lengths must be enforced."
  }
}

run "truncation_repairs_only_forbidden_endings" {
  command = apply

  variables {
    naming_templates = {
      name = "${join("", [for i in range(43) : "a"])}-bbbbb-tail"
    }
  }

  assert {
    condition = alltrue([
      for entry in values(output.names_by_azure_type["Microsoft.DocumentDB/databaseAccounts"]) :
      length(entry.name) == 43 &&
      !endswith(entry.name, "-") &&
      entry.max_length == 44 &&
      entry.validation.valid_name &&
      entry.validation.valid_name_unique &&
      endswith(entry.name_unique, "-a1b2")
    ])
    error_message = "Every Cosmos variant must retain the 44-character cap, repair a truncated hyphen, and retain the unique token."
  }

  assert {
    condition = (
      length(output.names.synapse_workspace.name) == 49 &&
      !endswith(output.names.synapse_workspace.name, "-") &&
      output.names.synapse_workspace.validation.valid_name &&
      output.names.synapse_workspace.validation.valid_name_unique &&
      endswith(output.names.synapse_workspace.name_unique, "-a1b2")
    )
    error_message = "Synapse truncation must repair hyphens without stripping valid numeric uniqueness suffixes."
  }
}

run "verified_bounds_and_unknown_constraints" {
  command = apply

  variables {
    naming_templates = {
      name = join("", [for i in range(81) : "a"])
    }
  }

  assert {
    condition = (
      length(output.names.policy_definition.name) == 64 &&
      output.names.policy_definition.validation.valid_name &&
      length(output.names.storage_table.name) == 63 &&
      output.names.storage_table.validation.valid_name &&
      length(output.names.disk_access.name) == 80 &&
      length(output.names.hosting_environment.name) == 35 &&
      length(output.names.hosting_environment_app_service_environment.name) == 35
    )
    error_message = "Only verified resource-name bounds should constrain generated names."
  }

  assert {
    condition = (
      length(output.names.monitor_workspace.name) == 81 &&
      length(output.names.express_route_port.name) == 81 &&
      alltrue([
        for key in [
          "monitor_workspace",
          "data_collection_rule_association",
          "disk_access",
          "hosting_environment",
          "hosting_environment_app_service_environment",
          "express_route_port",
        ] :
        !output.names[key].validation_complete &&
        output.names[key].validation.valid_name == null &&
        output.names[key].validation.valid_name_unique == null
      ])
    )
    error_message = "Unverified naming constraints must remain explicitly unknown."
  }
}
