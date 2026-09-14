# RMFR7 applies to resource modules; this utility does not deploy an Azure resource.
rule "avm_output_resource_id_required" {
  enabled = false
}

# SFR3 prohibits telemetry in local-only utility modules.
rule "avm_provider_modtm_version_constraint" {
  enabled = false
}
