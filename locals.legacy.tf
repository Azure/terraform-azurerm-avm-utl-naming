# Frozen Azure/naming renderer at fc289126c9c888393ff02a79e1babadd6865861c.
# Legacy-only random resources retain their seed through moved blocks.
locals {
  legacy_random_safe_generation = var.legacy_mode ? join("", [random_string.first_letter[0].result, random_string.main[0].result]) : ""
  legacy_random                 = var.legacy_mode ? substr(coalesce(local.unique_seed_input, local.legacy_random_safe_generation), 0, local.unique_length) : ""
  legacy_prefix                 = var.legacy_mode ? join("-", var.prefix) : ""
  legacy_prefix_safe            = var.legacy_mode ? lower(join("", var.prefix)) : ""
  legacy_suffix                 = var.legacy_mode ? join("-", var.suffix) : ""
  legacy_suffix_unique          = var.legacy_mode ? join("-", concat(var.suffix, [local.legacy_random])) : ""
  legacy_suffix_safe            = var.legacy_mode ? lower(join("", var.suffix)) : ""
  legacy_suffix_unique_safe     = var.legacy_mode ? lower(join("", concat(var.suffix, [local.legacy_random]))) : ""
  legacy_az = {
    analysis_services_server = {
      name        = substr(join("", compact([local.legacy_prefix_safe, "as", local.legacy_suffix_safe])), 0, 63)
      name_unique = substr(join("", compact([local.legacy_prefix_safe, "as", local.legacy_suffix_unique_safe])), 0, 63)
      dashes      = false
      slug        = "as"
      min_length  = 3
      max_length  = 63
      scope       = "resourceGroup"
      regex       = "^[a-z][a-z0-9]+$"
    }
    api_management = {
      name        = substr(join("-", compact([local.legacy_prefix, "apim", local.legacy_suffix])), 0, 50)
      name_unique = substr(join("-", compact([local.legacy_prefix, "apim", local.legacy_suffix_unique])), 0, 50)
      dashes      = true
      slug        = "apim"
      min_length  = 1
      max_length  = 50
      scope       = "global"
      regex       = "^[a-zA-Z][a-zA-Z0-9-]+[a-zA-Z0-9]+$"
    }
    app_configuration = {
      name        = substr(join("-", compact([local.legacy_prefix, "appcg", local.legacy_suffix])), 0, 50)
      name_unique = substr(join("-", compact([local.legacy_prefix, "appcg", local.legacy_suffix_unique])), 0, 50)
      dashes      = true
      slug        = "appcg"
      min_length  = 5
      max_length  = 50
      scope       = "resourceGroup"
      regex       = "^[a-zA-Z0-9_-]+$"
    }
    app_service = {
      name        = substr(join("-", compact([local.legacy_prefix, "app", local.legacy_suffix])), 0, 60)
      name_unique = substr(join("-", compact([local.legacy_prefix, "app", local.legacy_suffix_unique])), 0, 60)
      dashes      = true
      slug        = "app"
      min_length  = 2
      max_length  = 60
      scope       = "global"
      regex       = "^[a-z0-9][a-zA-Z0-9-]+[a-z0-9]"
    }
    app_service_environment = {
      name        = substr(join("-", compact([local.legacy_prefix, "ase", local.legacy_suffix])), 0, 40)
      name_unique = substr(join("-", compact([local.legacy_prefix, "ase", local.legacy_suffix_unique])), 0, 40)
      dashes      = true
      slug        = "ase"
      min_length  = 1
      max_length  = 40
      scope       = "resourceGroup"
      regex       = "^[a-zA-Z0-9-]+$"
    }
    app_service_plan = {
      name        = substr(join("-", compact([local.legacy_prefix, "plan", local.legacy_suffix])), 0, 40)
      name_unique = substr(join("-", compact([local.legacy_prefix, "plan", local.legacy_suffix_unique])), 0, 40)
      dashes      = true
      slug        = "plan"
      min_length  = 1
      max_length  = 40
      scope       = "resourceGroup"
      regex       = "^[a-zA-Z0-9-]+$"
    }
    application_gateway = {
      name        = substr(join("-", compact([local.legacy_prefix, "agw", local.legacy_suffix])), 0, 80)
      name_unique = substr(join("-", compact([local.legacy_prefix, "agw", local.legacy_suffix_unique])), 0, 80)
      dashes      = true
      slug        = "agw"
      min_length  = 1
      max_length  = 80
      scope       = "resourceGroup"
      regex       = "^[a-zA-Z0-9][a-zA-Z0-9-._]+[a-zA-Z0-9_]$"
    }
    application_insights = {
      name        = substr(join("-", compact([local.legacy_prefix, "appi", local.legacy_suffix])), 0, 260)
      name_unique = substr(join("-", compact([local.legacy_prefix, "appi", local.legacy_suffix_unique])), 0, 260)
      dashes      = true
      slug        = "appi"
      min_length  = 10
      max_length  = 260
      scope       = "resourceGroup"
      regex       = "^[^%\\&?/]+$"
    }
    application_security_group = {
      name        = substr(join("-", compact([local.legacy_prefix, "asg", local.legacy_suffix])), 0, 80)
      name_unique = substr(join("-", compact([local.legacy_prefix, "asg", local.legacy_suffix_unique])), 0, 80)
      dashes      = true
      slug        = "asg"
      min_length  = 1
      max_length  = 80
      scope       = "resourceGroup"
      regex       = "^[a-zA-Z0-9][a-zA-Z0-9-._]+[a-zA-Z0-9_]$"
    }
    automation_account = {
      name        = substr(join("-", compact([local.legacy_prefix, "aa", local.legacy_suffix])), 0, 50)
      name_unique = substr(join("-", compact([local.legacy_prefix, "aa", local.legacy_suffix_unique])), 0, 50)
      dashes      = true
      slug        = "aa"
      min_length  = 6
      max_length  = 50
      scope       = "resourceGroup"
      regex       = "^[a-zA-Z][a-zA-Z0-9-]+[a-zA-Z0-9]$"
    }
    automation_certificate = {
      name        = substr(join("-", compact([local.legacy_prefix, "aacert", local.legacy_suffix])), 0, 128)
      name_unique = substr(join("-", compact([local.legacy_prefix, "aacert", local.legacy_suffix_unique])), 0, 128)
      dashes      = true
      slug        = "aacert"
      min_length  = 1
      max_length  = 128
      scope       = "parent"
      regex       = "^[^<>*%:.?\\+\\/]+[^<>*%:.?\\+\\/ ]$"
    }
    automation_credential = {
      name        = substr(join("-", compact([local.legacy_prefix, "aacred", local.legacy_suffix])), 0, 128)
      name_unique = substr(join("-", compact([local.legacy_prefix, "aacred", local.legacy_suffix_unique])), 0, 128)
      dashes      = true
      slug        = "aacred"
      min_length  = 1
      max_length  = 128
      scope       = "parent"
      regex       = "^[^<>*%:.?\\+\\/]+[^<>*%:.?\\+\\/ ]$"
    }
    automation_runbook = {
      name        = substr(join("-", compact([local.legacy_prefix, "aacred", local.legacy_suffix])), 0, 63)
      name_unique = substr(join("-", compact([local.legacy_prefix, "aacred", local.legacy_suffix_unique])), 0, 63)
      dashes      = true
      slug        = "aacred"
      min_length  = 1
      max_length  = 63
      scope       = "parent"
      regex       = "^[a-zA-Z][a-zA-Z0-9-]+$"
    }
    automation_schedule = {
      name        = substr(join("-", compact([local.legacy_prefix, "aasched", local.legacy_suffix])), 0, 128)
      name_unique = substr(join("-", compact([local.legacy_prefix, "aasched", local.legacy_suffix_unique])), 0, 128)
      dashes      = true
      slug        = "aasched"
      min_length  = 1
      max_length  = 128
      scope       = "parent"
      regex       = "^[^<>*%:.?\\+\\/]+[^<>*%:.?\\+\\/ ]$"
    }
    automation_variable = {
      name        = substr(join("-", compact([local.legacy_prefix, "aavar", local.legacy_suffix])), 0, 128)
      name_unique = substr(join("-", compact([local.legacy_prefix, "aavar", local.legacy_suffix_unique])), 0, 128)
      dashes      = true
      slug        = "aavar"
      min_length  = 1
      max_length  = 128
      scope       = "parent"
      regex       = "^[^<>*%:.?\\+\\/]+[^<>*%:.?\\+\\/ ]$"
    }
    availability_set = {
      name        = substr(join("-", compact([local.legacy_prefix, "avail", local.legacy_suffix])), 0, 80)
      name_unique = substr(join("-", compact([local.legacy_prefix, "avail", local.legacy_suffix_unique])), 0, 80)
      dashes      = true
      slug        = "avail"
      min_length  = 1
      max_length  = 80
      scope       = "resourceGroup"
      regex       = "^[a-zA-Z0-9][a-zA-Z0-9-_.]+[a-zA-Z0-9_]$"
    }
    backup_policy_vm = {
      name        = substr(join("-", compact([local.legacy_prefix, "bkpol", local.legacy_suffix])), 0, 150)
      name_unique = substr(join("-", compact([local.legacy_prefix, "bkpol", local.legacy_suffix_unique])), 0, 150)
      dashes      = true
      slug        = "bkpol"
      min_length  = 3
      max_length  = 150
      scope       = "parent"
      regex       = "^[a-zA-Z][a-zA-Z0-9-]+[a-zA-Z0-9]$"
    }
    bastion_host = {
      name        = substr(join("-", compact([local.legacy_prefix, "snap", local.legacy_suffix])), 0, 80)
      name_unique = substr(join("-", compact([local.legacy_prefix, "snap", local.legacy_suffix_unique])), 0, 80)
      dashes      = true
      slug        = "snap"
      min_length  = 1
      max_length  = 80
      scope       = "parent"
      regex       = "^[a-zA-Z0-9][a-zA-Z0-9-._]+[a-zA-Z0-9_]$"
    }
    batch_account = {
      name        = substr(join("", compact([local.legacy_prefix_safe, "ba", local.legacy_suffix_safe])), 0, 24)
      name_unique = substr(join("", compact([local.legacy_prefix_safe, "ba", local.legacy_suffix_unique_safe])), 0, 24)
      dashes      = false
      slug        = "ba"
      min_length  = 3
      max_length  = 24
      scope       = "region"
      regex       = "^[a-z0-9]+$"
    }
    batch_application = {
      name        = substr(join("-", compact([local.legacy_prefix, "baapp", local.legacy_suffix])), 0, 64)
      name_unique = substr(join("-", compact([local.legacy_prefix, "baapp", local.legacy_suffix_unique])), 0, 64)
      dashes      = true
      slug        = "baapp"
      min_length  = 1
      max_length  = 64
      scope       = "parent"
      regex       = "^[a-zA-Z0-9_-]+$"
    }
    batch_certificate = {
      name        = substr(join("-", compact([local.legacy_prefix, "bacert", local.legacy_suffix])), 0, 45)
      name_unique = substr(join("-", compact([local.legacy_prefix, "bacert", local.legacy_suffix_unique])), 0, 45)
      dashes      = true
      slug        = "bacert"
      min_length  = 5
      max_length  = 45
      scope       = "parent"
      regex       = "^[a-zA-Z0-9_-]+$"
    }
    batch_pool = {
      name        = substr(join("-", compact([local.legacy_prefix, "bapool", local.legacy_suffix])), 0, 24)
      name_unique = substr(join("-", compact([local.legacy_prefix, "bapool", local.legacy_suffix_unique])), 0, 24)
      dashes      = true
      slug        = "bapool"
      min_length  = 3
      max_length  = 24
      scope       = "parent"
      regex       = "^[a-zA-Z0-9_-]+$"
    }
    bot_channel_directline = {
      name        = substr(join("-", compact([local.legacy_prefix, "botline", local.legacy_suffix])), 0, 64)
      name_unique = substr(join("-", compact([local.legacy_prefix, "botline", local.legacy_suffix_unique])), 0, 64)
      dashes      = true
      slug        = "botline"
      min_length  = 2
      max_length  = 64
      scope       = "parent"
      regex       = "^[a-zA-Z0-9][a-zA-Z0-9-_.]+$"
    }
    bot_channel_email = {
      name        = substr(join("-", compact([local.legacy_prefix, "botmail", local.legacy_suffix])), 0, 64)
      name_unique = substr(join("-", compact([local.legacy_prefix, "botmail", local.legacy_suffix_unique])), 0, 64)
      dashes      = true
      slug        = "botmail"
      min_length  = 2
      max_length  = 64
      scope       = "parent"
      regex       = "^[a-zA-Z0-9][a-zA-Z0-9-_.]+$"
    }
    bot_channel_ms_teams = {
      name        = substr(join("-", compact([local.legacy_prefix, "botteams", local.legacy_suffix])), 0, 64)
      name_unique = substr(join("-", compact([local.legacy_prefix, "botteams", local.legacy_suffix_unique])), 0, 64)
      dashes      = true
      slug        = "botteams"
      min_length  = 2
      max_length  = 64
      scope       = "parent"
      regex       = "^[a-zA-Z0-9][a-zA-Z0-9-_.]+$"
    }
    bot_channel_slack = {
      name        = substr(join("-", compact([local.legacy_prefix, "botslack", local.legacy_suffix])), 0, 64)
      name_unique = substr(join("-", compact([local.legacy_prefix, "botslack", local.legacy_suffix_unique])), 0, 64)
      dashes      = true
      slug        = "botslack"
      min_length  = 2
      max_length  = 64
      scope       = "parent"
      regex       = "^[a-zA-Z0-9][a-zA-Z0-9-_.]+$"
    }
    bot_channels_registration = {
      name        = substr(join("-", compact([local.legacy_prefix, "botchan", local.legacy_suffix])), 0, 64)
      name_unique = substr(join("-", compact([local.legacy_prefix, "botchan", local.legacy_suffix_unique])), 0, 64)
      dashes      = true
      slug        = "botchan"
      min_length  = 2
      max_length  = 64
      scope       = "parent"
      regex       = "^[a-zA-Z0-9][a-zA-Z0-9-_.]+$"
    }
    bot_connection = {
      name        = substr(join("-", compact([local.legacy_prefix, "botcon", local.legacy_suffix])), 0, 64)
      name_unique = substr(join("-", compact([local.legacy_prefix, "botcon", local.legacy_suffix_unique])), 0, 64)
      dashes      = true
      slug        = "botcon"
      min_length  = 2
      max_length  = 64
      scope       = "parent"
      regex       = "^[a-zA-Z0-9][a-zA-Z0-9-_.]+$"
    }
    bot_web_app = {
      name        = substr(join("-", compact([local.legacy_prefix, "bot", local.legacy_suffix])), 0, 64)
      name_unique = substr(join("-", compact([local.legacy_prefix, "bot", local.legacy_suffix_unique])), 0, 64)
      dashes      = true
      slug        = "bot"
      min_length  = 2
      max_length  = 64
      scope       = "global"
      regex       = "^[a-zA-Z0-9][a-zA-Z0-9-_.]+$"
    }
    cdn_endpoint = {
      name        = substr(join("-", compact([local.legacy_prefix, "cdn", local.legacy_suffix])), 0, 50)
      name_unique = substr(join("-", compact([local.legacy_prefix, "cdn", local.legacy_suffix_unique])), 0, 50)
      dashes      = true
      slug        = "cdn"
      min_length  = 1
      max_length  = 50
      scope       = "global"
      regex       = "^[a-zA-Z0-9][a-zA-Z0-9-]+[a-zA-Z0-9]$"
    }
    cdn_frontdoor_endpoint = {
      name        = substr(join("-", compact([local.legacy_prefix, "fde", local.legacy_suffix])), 0, 50)
      name_unique = substr(join("-", compact([local.legacy_prefix, "fde", local.legacy_suffix_unique])), 0, 50)
      dashes      = true
      slug        = "fde"
      min_length  = 1
      max_length  = 50
      scope       = "global"
      regex       = "^[a-zA-Z0-9][a-zA-Z0-9-]+[a-zA-Z0-9]$"
    }
    cdn_frontdoor_origin = {
      name        = substr(join("-", compact([local.legacy_prefix, "cdno", local.legacy_suffix])), 0, 50)
      name_unique = substr(join("-", compact([local.legacy_prefix, "cdno", local.legacy_suffix_unique])), 0, 50)
      dashes      = true
      slug        = "cdno"
      min_length  = 1
      max_length  = 50
      scope       = "parent"
      regex       = "^[a-zA-Z0-9][a-zA-Z0-9-]+[a-zA-Z0-9]$"
    }
    cdn_frontdoor_origin_group = {
      name        = substr(join("-", compact([local.legacy_prefix, "cdnog", local.legacy_suffix])), 0, 50)
      name_unique = substr(join("-", compact([local.legacy_prefix, "cdnog", local.legacy_suffix_unique])), 0, 50)
      dashes      = true
      slug        = "cdnog"
      min_length  = 1
      max_length  = 50
      scope       = "parent"
      regex       = "^[a-zA-Z0-9][a-zA-Z0-9-]+[a-zA-Z0-9]$"
    }
    cdn_frontdoor_profile = {
      name        = substr(join("-", compact([local.legacy_prefix, "afd", local.legacy_suffix])), 0, 64)
      name_unique = substr(join("-", compact([local.legacy_prefix, "afd", local.legacy_suffix_unique])), 0, 64)
      dashes      = true
      slug        = "afd"
      min_length  = 5
      max_length  = 64
      scope       = "global"
      regex       = "^[a-zA-Z0-9][a-zA-Z0-9-]+[a-zA-Z0-9]$"
    }
    cdn_frontdoor_route = {
      name        = substr(join("-", compact([local.legacy_prefix, "cdnr", local.legacy_suffix])), 0, 50)
      name_unique = substr(join("-", compact([local.legacy_prefix, "cdnr", local.legacy_suffix_unique])), 0, 50)
      dashes      = true
      slug        = "cdnr"
      min_length  = 1
      max_length  = 50
      scope       = "parent"
      regex       = "^[a-zA-Z0-9][a-zA-Z0-9-]+[a-zA-Z0-9]$"
    }
    cdn_profile = {
      name        = substr(join("-", compact([local.legacy_prefix, "cdnprof", local.legacy_suffix])), 0, 260)
      name_unique = substr(join("-", compact([local.legacy_prefix, "cdnprof", local.legacy_suffix_unique])), 0, 260)
      dashes      = true
      slug        = "cdnprof"
      min_length  = 1
      max_length  = 260
      scope       = "resourceGroup"
      regex       = "^[a-zA-Z0-9][a-zA-Z0-9-]+[a-zA-Z0-9]$"
    }
    cognitive_account = {
      name        = substr(join("-", compact([local.legacy_prefix, "cog", local.legacy_suffix])), 0, 64)
      name_unique = substr(join("-", compact([local.legacy_prefix, "cog", local.legacy_suffix_unique])), 0, 64)
      dashes      = true
      slug        = "cog"
      min_length  = 2
      max_length  = 64
      scope       = "resourceGroup"
      regex       = "^[a-zA-Z0-9][a-zA-Z0-9-]+$"
    }
    communication_service = {
      name        = substr(join("-", compact([local.legacy_prefix, "acs", local.legacy_suffix])), 0, 63)
      name_unique = substr(join("-", compact([local.legacy_prefix, "acs", local.legacy_suffix_unique])), 0, 63)
      dashes      = true
      slug        = "acs"
      min_length  = 1
      max_length  = 63
      scope       = "global"
      regex       = "^[a-zA-Z0-9][a-zA-Z0-9-]+[a-zA-Z0-9]$"
    }
    container_app = {
      name        = substr(join("-", compact([local.legacy_prefix, "ca", local.legacy_suffix])), 0, 32)
      name_unique = substr(join("-", compact([local.legacy_prefix, "ca", local.legacy_suffix_unique])), 0, 32)
      dashes      = true
      slug        = "ca"
      min_length  = 1
      max_length  = 32
      scope       = "resourceGroup"
      regex       = "^[a-zA-Z0-9][a-zA-Z0-9-]+[a-zA-Z0-9]$"
    }
    container_app_environment = {
      name        = substr(join("-", compact([local.legacy_prefix, "cae", local.legacy_suffix])), 0, 60)
      name_unique = substr(join("-", compact([local.legacy_prefix, "cae", local.legacy_suffix_unique])), 0, 60)
      dashes      = true
      slug        = "cae"
      min_length  = 1
      max_length  = 60
      scope       = "resourceGroup"
      regex       = "^[a-zA-Z0-9][a-zA-Z0-9-]+[a-zA-Z0-9]$"
    }
    container_app_job = {
      name        = substr(join("-", compact([local.legacy_prefix, "caj", local.legacy_suffix])), 0, 32)
      name_unique = substr(join("-", compact([local.legacy_prefix, "caj", local.legacy_suffix_unique])), 0, 32)
      dashes      = true
      slug        = "caj"
      min_length  = 2
      max_length  = 32
      scope       = "resourceGroup"
      regex       = "^[a-zA-Z0-9][a-zA-Z0-9-]+[a-zA-Z0-9]$"
    }
    container_group = {
      name        = substr(join("-", compact([local.legacy_prefix, "cg", local.legacy_suffix])), 0, 63)
      name_unique = substr(join("-", compact([local.legacy_prefix, "cg", local.legacy_suffix_unique])), 0, 63)
      dashes      = true
      slug        = "cg"
      min_length  = 1
      max_length  = 63
      scope       = "resourceGroup"
      regex       = "^[a-zA-Z0-9][a-zA-Z0-9-]+[a-zA-Z0-9]$"
    }
    container_registry = {
      name        = substr(join("", compact([local.legacy_prefix_safe, "acr", local.legacy_suffix_safe])), 0, 63)
      name_unique = substr(join("", compact([local.legacy_prefix_safe, "acr", local.legacy_suffix_unique_safe])), 0, 63)
      dashes      = false
      slug        = "acr"
      min_length  = 1
      max_length  = 63
      scope       = "resourceGroup"
      regex       = "^[a-zA-Z0-9]+$"
    }
    container_registry_webhook = {
      name        = substr(join("", compact([local.legacy_prefix_safe, "crwh", local.legacy_suffix_safe])), 0, 50)
      name_unique = substr(join("", compact([local.legacy_prefix_safe, "crwh", local.legacy_suffix_unique_safe])), 0, 50)
      dashes      = false
      slug        = "crwh"
      min_length  = 1
      max_length  = 50
      scope       = "resourceGroup"
      regex       = "^[a-zA-Z0-9]+$"
    }
    cosmosdb_account = {
      name        = substr(join("-", compact([local.legacy_prefix, "cosmos", local.legacy_suffix])), 0, 63)
      name_unique = substr(join("-", compact([local.legacy_prefix, "cosmos", local.legacy_suffix_unique])), 0, 63)
      dashes      = true
      slug        = "cosmos"
      min_length  = 1
      max_length  = 63
      scope       = "resourceGroup"
      regex       = "^[a-z0-9][a-z0-9-_.]+[a-z0-9]$"
    }
    cosmosdb_cassandra = {
      name        = substr(join("-", compact([local.legacy_prefix, "coscas", local.legacy_suffix])), 0, 44)
      name_unique = substr(join("-", compact([local.legacy_prefix, "coscas", local.legacy_suffix_unique])), 0, 44)
      dashes      = true
      slug        = "coscas"
      min_length  = 3
      max_length  = 44
      scope       = "resourceGroup"
      regex       = "^[a-z0-9][a-z0-9-_.]+[a-z0-9]$"
    }
    cosmosdb_cassandra_cluster = {
      name        = substr(join("-", compact([local.legacy_prefix, "mcc", local.legacy_suffix])), 0, 44)
      name_unique = substr(join("-", compact([local.legacy_prefix, "mcc", local.legacy_suffix_unique])), 0, 44)
      dashes      = true
      slug        = "mcc"
      min_length  = 1
      max_length  = 44
      scope       = "parent"
      regex       = "^[a-z0-9][a-zA-Z0-9-]+[a-z0-9]$"
    }
    cosmosdb_cassandra_datacenter = {
      name        = substr(join("-", compact([local.legacy_prefix, "mcdc", local.legacy_suffix])), 0, 44)
      name_unique = substr(join("-", compact([local.legacy_prefix, "mcdc", local.legacy_suffix_unique])), 0, 44)
      dashes      = true
      slug        = "mcdc"
      min_length  = 1
      max_length  = 44
      scope       = "parent"
      regex       = "^[a-z0-9][a-zA-Z0-9-]+[a-z0-9]$"
    }
    cosmosdb_gremlin = {
      name        = substr(join("-", compact([local.legacy_prefix, "cosgrm", local.legacy_suffix])), 0, 44)
      name_unique = substr(join("-", compact([local.legacy_prefix, "cosgrm", local.legacy_suffix_unique])), 0, 44)
      dashes      = true
      slug        = "cosgrm"
      min_length  = 3
      max_length  = 44
      scope       = "resourceGroup"
      regex       = "^[a-z0-9][a-z0-9-_.]+[a-z0-9]$"
    }
    cosmosdb_mongodb = {
      name        = substr(join("-", compact([local.legacy_prefix, "cosmon", local.legacy_suffix])), 0, 44)
      name_unique = substr(join("-", compact([local.legacy_prefix, "cosmon", local.legacy_suffix_unique])), 0, 44)
      dashes      = true
      slug        = "cosmon"
      min_length  = 3
      max_length  = 44
      scope       = "resourceGroup"
      regex       = "^[a-z0-9][a-z0-9-_.]+[a-z0-9]$"
    }
    cosmosdb_nosql = {
      name        = substr(join("-", compact([local.legacy_prefix, "cosno", local.legacy_suffix])), 0, 44)
      name_unique = substr(join("-", compact([local.legacy_prefix, "cosno", local.legacy_suffix_unique])), 0, 44)
      dashes      = true
      slug        = "cosno"
      min_length  = 3
      max_length  = 44
      scope       = "resourceGroup"
      regex       = "^[a-z0-9][a-z0-9-_.]+[a-z0-9]$"
    }
    cosmosdb_postgres = {
      name        = substr(join("-", compact([local.legacy_prefix, "cospos", local.legacy_suffix])), 0, 63)
      name_unique = substr(join("-", compact([local.legacy_prefix, "cospos", local.legacy_suffix_unique])), 0, 63)
      dashes      = true
      slug        = "cospos"
      min_length  = 1
      max_length  = 63
      scope       = "resourceGroup"
      regex       = "^[a-z0-9][a-z0-9-_.]+[a-z0-9]$"
    }
    cosmosdb_tables = {
      name        = substr(join("-", compact([local.legacy_prefix, "costab", local.legacy_suffix])), 0, 44)
      name_unique = substr(join("-", compact([local.legacy_prefix, "costab", local.legacy_suffix_unique])), 0, 44)
      dashes      = true
      slug        = "costab"
      min_length  = 3
      max_length  = 44
      scope       = "resourceGroup"
      regex       = "^[a-z0-9][a-z0-9-_.]+[a-z0-9]$"
    }
    custom_provider = {
      name        = substr(join("-", compact([local.legacy_prefix, "prov", local.legacy_suffix])), 0, 64)
      name_unique = substr(join("-", compact([local.legacy_prefix, "prov", local.legacy_suffix_unique])), 0, 64)
      dashes      = true
      slug        = "prov"
      min_length  = 3
      max_length  = 64
      scope       = "resourceGroup"
      regex       = "^[^&%?\\/]+[^&%.?\\/ ]$"
    }
    dashboard = {
      name        = substr(join("-", compact([local.legacy_prefix, "dsb", local.legacy_suffix])), 0, 160)
      name_unique = substr(join("-", compact([local.legacy_prefix, "dsb", local.legacy_suffix_unique])), 0, 160)
      dashes      = true
      slug        = "dsb"
      min_length  = 3
      max_length  = 160
      scope       = "parent"
      regex       = "^[a-zA-Z0-9-]+$"
    }
    dashboard_grafana = {
      name        = substr(join("-", compact([local.legacy_prefix, "amg", local.legacy_suffix])), 0, 80)
      name_unique = substr(join("-", compact([local.legacy_prefix, "amg", local.legacy_suffix_unique])), 0, 80)
      dashes      = true
      slug        = "amg"
      min_length  = 1
      max_length  = 80
      scope       = "resourceGroup"
      regex       = "^[a-zA-Z0-9][a-zA-Z0-9-._]+[a-zA-Z0-9_]$"
    }
    data_factory = {
      name        = substr(join("-", compact([local.legacy_prefix, "adf", local.legacy_suffix])), 0, 63)
      name_unique = substr(join("-", compact([local.legacy_prefix, "adf", local.legacy_suffix_unique])), 0, 63)
      dashes      = true
      slug        = "adf"
      min_length  = 3
      max_length  = 63
      scope       = "global"
      regex       = "^[a-zA-Z0-9][a-zA-Z0-9-]+[a-zA-Z0-9]$"
    }
    data_factory_dataset_mysql = {
      name        = substr(join("-", compact([local.legacy_prefix, "adfmysql", local.legacy_suffix])), 0, 260)
      name_unique = substr(join("-", compact([local.legacy_prefix, "adfmysql", local.legacy_suffix_unique])), 0, 260)
      dashes      = true
      slug        = "adfmysql"
      min_length  = 1
      max_length  = 260
      scope       = "parent"
      regex       = "^[a-zA-Z0-9][^<>*%:.?\\+\\/]+[a-zA-Z0-9]$"
    }
    data_factory_dataset_postgresql = {
      name        = substr(join("-", compact([local.legacy_prefix, "adfpsql", local.legacy_suffix])), 0, 260)
      name_unique = substr(join("-", compact([local.legacy_prefix, "adfpsql", local.legacy_suffix_unique])), 0, 260)
      dashes      = true
      slug        = "adfpsql"
      min_length  = 1
      max_length  = 260
      scope       = "parent"
      regex       = "^[a-zA-Z0-9][^<>*%:.?\\+\\/]+[a-zA-Z0-9]$"
    }
    data_factory_dataset_sql_server_table = {
      name        = substr(join("-", compact([local.legacy_prefix, "adfmssql", local.legacy_suffix])), 0, 260)
      name_unique = substr(join("-", compact([local.legacy_prefix, "adfmssql", local.legacy_suffix_unique])), 0, 260)
      dashes      = true
      slug        = "adfmssql"
      min_length  = 1
      max_length  = 260
      scope       = "parent"
      regex       = "^[a-zA-Z0-9][^<>*%:.?\\+\\/]+[a-zA-Z0-9]$"
    }
    data_factory_integration_runtime_managed = {
      name        = substr(join("-", compact([local.legacy_prefix, "adfir", local.legacy_suffix])), 0, 63)
      name_unique = substr(join("-", compact([local.legacy_prefix, "adfir", local.legacy_suffix_unique])), 0, 63)
      dashes      = true
      slug        = "adfir"
      min_length  = 3
      max_length  = 63
      scope       = "parent"
      regex       = "^[a-zA-Z0-9][a-zA-Z0-9-]+[a-zA-Z0-9]$"
    }
    data_factory_linked_service_data_lake_storage_gen2 = {
      name        = substr(join("-", compact([local.legacy_prefix, "adfsvst", local.legacy_suffix])), 0, 260)
      name_unique = substr(join("-", compact([local.legacy_prefix, "adfsvst", local.legacy_suffix_unique])), 0, 260)
      dashes      = true
      slug        = "adfsvst"
      min_length  = 1
      max_length  = 260
      scope       = "parent"
      regex       = "^[a-zA-Z0-9][^<>*%:.?\\+\\/]+$"
    }
    data_factory_linked_service_key_vault = {
      name        = substr(join("-", compact([local.legacy_prefix, "adfsvkv", local.legacy_suffix])), 0, 260)
      name_unique = substr(join("-", compact([local.legacy_prefix, "adfsvkv", local.legacy_suffix_unique])), 0, 260)
      dashes      = true
      slug        = "adfsvkv"
      min_length  = 1
      max_length  = 260
      scope       = "parent"
      regex       = "^[a-zA-Z0-9][^<>*%:.?\\+\\/]+$"
    }
    data_factory_linked_service_mysql = {
      name        = substr(join("-", compact([local.legacy_prefix, "adfsvmysql", local.legacy_suffix])), 0, 260)
      name_unique = substr(join("-", compact([local.legacy_prefix, "adfsvmysql", local.legacy_suffix_unique])), 0, 260)
      dashes      = true
      slug        = "adfsvmysql"
      min_length  = 1
      max_length  = 260
      scope       = "parent"
      regex       = "^[a-zA-Z0-9][^<>*%:.?\\+\\/]+$"
    }
    data_factory_linked_service_postgresql = {
      name        = substr(join("-", compact([local.legacy_prefix, "adfsvpsql", local.legacy_suffix])), 0, 260)
      name_unique = substr(join("-", compact([local.legacy_prefix, "adfsvpsql", local.legacy_suffix_unique])), 0, 260)
      dashes      = true
      slug        = "adfsvpsql"
      min_length  = 1
      max_length  = 260
      scope       = "parent"
      regex       = "^[a-zA-Z0-9][^<>*%:.?\\+\\/]+$"
    }
    data_factory_linked_service_sql_server = {
      name        = substr(join("-", compact([local.legacy_prefix, "adfsvmssql", local.legacy_suffix])), 0, 260)
      name_unique = substr(join("-", compact([local.legacy_prefix, "adfsvmssql", local.legacy_suffix_unique])), 0, 260)
      dashes      = true
      slug        = "adfsvmssql"
      min_length  = 1
      max_length  = 260
      scope       = "parent"
      regex       = "^[a-zA-Z0-9][^<>*%:.?\\+\\/]+$"
    }
    data_factory_pipeline = {
      name        = substr(join("-", compact([local.legacy_prefix, "adfpl", local.legacy_suffix])), 0, 260)
      name_unique = substr(join("-", compact([local.legacy_prefix, "adfpl", local.legacy_suffix_unique])), 0, 260)
      dashes      = true
      slug        = "adfpl"
      min_length  = 1
      max_length  = 260
      scope       = "parent"
      regex       = "^[a-zA-Z0-9][^<>*%:.?\\+\\/]+[a-zA-Z0-9]$"
    }
    data_factory_trigger_schedule = {
      name        = substr(join("-", compact([local.legacy_prefix, "adftg", local.legacy_suffix])), 0, 260)
      name_unique = substr(join("-", compact([local.legacy_prefix, "adftg", local.legacy_suffix_unique])), 0, 260)
      dashes      = true
      slug        = "adftg"
      min_length  = 1
      max_length  = 260
      scope       = "parent"
      regex       = "^[a-zA-Z0-9][^<>*%:.?\\+\\/]+$"
    }
    data_lake_analytics_account = {
      name        = substr(join("", compact([local.legacy_prefix_safe, "dla", local.legacy_suffix_safe])), 0, 24)
      name_unique = substr(join("", compact([local.legacy_prefix_safe, "dla", local.legacy_suffix_unique_safe])), 0, 24)
      dashes      = false
      slug        = "dla"
      min_length  = 3
      max_length  = 24
      scope       = "global"
      regex       = "^[a-z0-9]+$"
    }
    data_lake_analytics_firewall_rule = {
      name        = substr(join("-", compact([local.legacy_prefix, "dlfw", local.legacy_suffix])), 0, 50)
      name_unique = substr(join("-", compact([local.legacy_prefix, "dlfw", local.legacy_suffix_unique])), 0, 50)
      dashes      = true
      slug        = "dlfw"
      min_length  = 3
      max_length  = 50
      scope       = "parent"
      regex       = "^[a-z0-9-_]+$"
    }
    data_lake_store = {
      name        = substr(join("", compact([local.legacy_prefix_safe, "dls", local.legacy_suffix_safe])), 0, 24)
      name_unique = substr(join("", compact([local.legacy_prefix_safe, "dls", local.legacy_suffix_unique_safe])), 0, 24)
      dashes      = false
      slug        = "dls"
      min_length  = 3
      max_length  = 24
      scope       = "parent"
      regex       = "^[a-z0-9]+$"
    }
    data_lake_store_firewall_rule = {
      name        = substr(join("-", compact([local.legacy_prefix, "dlsfw", local.legacy_suffix])), 0, 50)
      name_unique = substr(join("-", compact([local.legacy_prefix, "dlsfw", local.legacy_suffix_unique])), 0, 50)
      dashes      = true
      slug        = "dlsfw"
      min_length  = 3
      max_length  = 50
      scope       = "parent"
      regex       = "^[a-zA-Z0-9-_]+$"
    }
    data_protection_backup_vault = {
      name        = substr(join("-", compact([local.legacy_prefix, "bvault", local.legacy_suffix])), 0, 50)
      name_unique = substr(join("-", compact([local.legacy_prefix, "bvault", local.legacy_suffix_unique])), 0, 50)
      dashes      = true
      slug        = "bvault"
      min_length  = 2
      max_length  = 50
      scope       = "resourceGroup"
      regex       = "^[a-zA-Z][a-zA-Z0-9-]+[a-zA-Z0-9]$"
    }
    database_migration_project = {
      name        = substr(join("-", compact([local.legacy_prefix, "migr", local.legacy_suffix])), 0, 57)
      name_unique = substr(join("-", compact([local.legacy_prefix, "migr", local.legacy_suffix_unique])), 0, 57)
      dashes      = true
      slug        = "migr"
      min_length  = 2
      max_length  = 57
      scope       = "parent"
      regex       = "^[a-zA-Z0-9][a-zA-Z0-9-_.]+$"
    }
    database_migration_service = {
      name        = substr(join("-", compact([local.legacy_prefix, "dms", local.legacy_suffix])), 0, 62)
      name_unique = substr(join("-", compact([local.legacy_prefix, "dms", local.legacy_suffix_unique])), 0, 62)
      dashes      = true
      slug        = "dms"
      min_length  = 2
      max_length  = 62
      scope       = "resourceGroup"
      regex       = "^[a-zA-Z0-9][a-zA-Z0-9-_.]+$"
    }
    databricks_access_connector = {
      name        = substr(join("-", compact([local.legacy_prefix, "dbac", local.legacy_suffix])), 0, 30)
      name_unique = substr(join("-", compact([local.legacy_prefix, "dbac", local.legacy_suffix_unique])), 0, 30)
      dashes      = true
      slug        = "dbac"
      min_length  = 3
      max_length  = 30
      scope       = "resourceGroup"
      regex       = "^[a-zA-Z0-9-_]+$"
    }
    databricks_cluster = {
      name        = substr(join("-", compact([local.legacy_prefix, "dbc", local.legacy_suffix])), 0, 30)
      name_unique = substr(join("-", compact([local.legacy_prefix, "dbc", local.legacy_suffix_unique])), 0, 30)
      dashes      = true
      slug        = "dbc"
      min_length  = 3
      max_length  = 30
      scope       = "parent"
      regex       = "^[a-zA-Z0-9-_]+$"
    }
    databricks_high_concurrency_cluster = {
      name        = substr(join("-", compact([local.legacy_prefix, "dbhcc", local.legacy_suffix])), 0, 30)
      name_unique = substr(join("-", compact([local.legacy_prefix, "dbhcc", local.legacy_suffix_unique])), 0, 30)
      dashes      = true
      slug        = "dbhcc"
      min_length  = 3
      max_length  = 30
      scope       = "parent"
      regex       = "^[a-zA-Z0-9-_]+$"
    }
    databricks_standard_cluster = {
      name        = substr(join("-", compact([local.legacy_prefix, "dbsc", local.legacy_suffix])), 0, 30)
      name_unique = substr(join("-", compact([local.legacy_prefix, "dbsc", local.legacy_suffix_unique])), 0, 30)
      dashes      = true
      slug        = "dbsc"
      min_length  = 3
      max_length  = 30
      scope       = "parent"
      regex       = "^[a-zA-Z0-9-_]+$"
    }
    databricks_workspace = {
      name        = substr(join("-", compact([local.legacy_prefix, "dbw", local.legacy_suffix])), 0, 30)
      name_unique = substr(join("-", compact([local.legacy_prefix, "dbw", local.legacy_suffix_unique])), 0, 30)
      dashes      = true
      slug        = "dbw"
      min_length  = 3
      max_length  = 30
      scope       = "resourceGroup"
      regex       = "^[a-zA-Z0-9-_]+$"
    }
    dev_test_lab = {
      name        = substr(join("-", compact([local.legacy_prefix, "lab", local.legacy_suffix])), 0, 50)
      name_unique = substr(join("-", compact([local.legacy_prefix, "lab", local.legacy_suffix_unique])), 0, 50)
      dashes      = true
      slug        = "lab"
      min_length  = 1
      max_length  = 50
      scope       = "resourceGroup"
      regex       = "^[a-zA-Z0-9-_]+$"
    }
    dev_test_linux_virtual_machine = {
      name        = substr(join("-", compact([local.legacy_prefix, "labvm", local.legacy_suffix])), 0, 64)
      name_unique = substr(join("-", compact([local.legacy_prefix, "labvm", local.legacy_suffix_unique])), 0, 64)
      dashes      = true
      slug        = "labvm"
      min_length  = 1
      max_length  = 64
      scope       = "parent"
      regex       = "^[a-zA-Z0-9-]+$"
    }
    dev_test_windows_virtual_machine = {
      name        = substr(join("-", compact([local.legacy_prefix, "labvm", local.legacy_suffix])), 0, 15)
      name_unique = substr(join("-", compact([local.legacy_prefix, "labvm", local.legacy_suffix_unique])), 0, 15)
      dashes      = true
      slug        = "labvm"
      min_length  = 1
      max_length  = 15
      scope       = "parent"
      regex       = "^[a-zA-Z0-9-]+$"
    }
    disk_encryption_set = {
      name        = substr(join("-", compact([local.legacy_prefix, "des", local.legacy_suffix])), 0, 80)
      name_unique = substr(join("-", compact([local.legacy_prefix, "des", local.legacy_suffix_unique])), 0, 80)
      dashes      = true
      slug        = "des"
      min_length  = 1
      max_length  = 80
      scope       = "resourceGroup"
      regex       = "^[a-zA-Z0-9_]+$"
    }
    dns_a_record = {
      name        = substr(join("-", compact([local.legacy_prefix, "dnsrec", local.legacy_suffix])), 0, 80)
      name_unique = substr(join("-", compact([local.legacy_prefix, "dnsrec", local.legacy_suffix_unique])), 0, 80)
      dashes      = true
      slug        = "dnsrec"
      min_length  = 1
      max_length  = 80
      scope       = "parent"
      regex       = "^[a-zA-Z0-9][a-zA-Z0-9-._]+[a-zA-Z0-9_]$"
    }
    dns_aaaa_record = {
      name        = substr(join("-", compact([local.legacy_prefix, "dnsrec", local.legacy_suffix])), 0, 80)
      name_unique = substr(join("-", compact([local.legacy_prefix, "dnsrec", local.legacy_suffix_unique])), 0, 80)
      dashes      = true
      slug        = "dnsrec"
      min_length  = 1
      max_length  = 80
      scope       = "parent"
      regex       = "^[a-zA-Z0-9][a-zA-Z0-9-._]+[a-zA-Z0-9_]$"
    }
    dns_caa_record = {
      name        = substr(join("-", compact([local.legacy_prefix, "dnsrec", local.legacy_suffix])), 0, 80)
      name_unique = substr(join("-", compact([local.legacy_prefix, "dnsrec", local.legacy_suffix_unique])), 0, 80)
      dashes      = true
      slug        = "dnsrec"
      min_length  = 1
      max_length  = 80
      scope       = "parent"
      regex       = "^[a-zA-Z0-9][a-zA-Z0-9-._]+[a-zA-Z0-9_]$"
    }
    dns_cname_record = {
      name        = substr(join("-", compact([local.legacy_prefix, "dnsrec", local.legacy_suffix])), 0, 80)
      name_unique = substr(join("-", compact([local.legacy_prefix, "dnsrec", local.legacy_suffix_unique])), 0, 80)
      dashes      = true
      slug        = "dnsrec"
      min_length  = 1
      max_length  = 80
      scope       = "parent"
      regex       = "^[a-zA-Z0-9][a-zA-Z0-9-._]+[a-zA-Z0-9_]$"
    }
    dns_mx_record = {
      name        = substr(join("-", compact([local.legacy_prefix, "dnsrec", local.legacy_suffix])), 0, 80)
      name_unique = substr(join("-", compact([local.legacy_prefix, "dnsrec", local.legacy_suffix_unique])), 0, 80)
      dashes      = true
      slug        = "dnsrec"
      min_length  = 1
      max_length  = 80
      scope       = "parent"
      regex       = "^[a-zA-Z0-9][a-zA-Z0-9-._]+[a-zA-Z0-9_]$"
    }
    dns_ns_record = {
      name        = substr(join("-", compact([local.legacy_prefix, "dnsrec", local.legacy_suffix])), 0, 80)
      name_unique = substr(join("-", compact([local.legacy_prefix, "dnsrec", local.legacy_suffix_unique])), 0, 80)
      dashes      = true
      slug        = "dnsrec"
      min_length  = 1
      max_length  = 80
      scope       = "parent"
      regex       = "^[a-zA-Z0-9][a-zA-Z0-9-._]+[a-zA-Z0-9_]$"
    }
    dns_private_resolver = {
      name        = substr(join("-", compact([local.legacy_prefix, "dnspr", local.legacy_suffix])), 0, 80)
      name_unique = substr(join("-", compact([local.legacy_prefix, "dnspr", local.legacy_suffix_unique])), 0, 80)
      dashes      = true
      slug        = "dnspr"
      min_length  = 1
      max_length  = 80
      scope       = "resourceGroup"
      regex       = "^[a-zA-Z0-9][a-zA-Z0-9-_]+[a-zA-Z0-9]$"
    }
    dns_ptr_record = {
      name        = substr(join("-", compact([local.legacy_prefix, "dnsrec", local.legacy_suffix])), 0, 80)
      name_unique = substr(join("-", compact([local.legacy_prefix, "dnsrec", local.legacy_suffix_unique])), 0, 80)
      dashes      = true
      slug        = "dnsrec"
      min_length  = 1
      max_length  = 80
      scope       = "parent"
      regex       = "^[a-zA-Z0-9][a-zA-Z0-9-._]+[a-zA-Z0-9_]$"
    }
    dns_txt_record = {
      name        = substr(join("-", compact([local.legacy_prefix, "dnsrec", local.legacy_suffix])), 0, 80)
      name_unique = substr(join("-", compact([local.legacy_prefix, "dnsrec", local.legacy_suffix_unique])), 0, 80)
      dashes      = true
      slug        = "dnsrec"
      min_length  = 1
      max_length  = 80
      scope       = "parent"
      regex       = "^[a-zA-Z0-9][a-zA-Z0-9-._]+[a-zA-Z0-9_]$"
    }
    dns_zone = {
      name        = substr(join("-", compact([local.legacy_prefix, "dns", local.legacy_suffix])), 0, 63)
      name_unique = substr(join("-", compact([local.legacy_prefix, "dns", local.legacy_suffix_unique])), 0, 63)
      dashes      = true
      slug        = "dns"
      min_length  = 1
      max_length  = 63
      scope       = "resourceGroup"
      regex       = "^[a-zA-Z0-9][a-zA-Z0-9-._]+[a-zA-Z0-9_]$"
    }
    eventgrid_domain = {
      name        = substr(join("-", compact([local.legacy_prefix, "egd", local.legacy_suffix])), 0, 50)
      name_unique = substr(join("-", compact([local.legacy_prefix, "egd", local.legacy_suffix_unique])), 0, 50)
      dashes      = true
      slug        = "egd"
      min_length  = 3
      max_length  = 50
      scope       = "resourceGroup"
      regex       = "^[a-zA-Z0-9-]+$"
    }
    eventgrid_domain_topic = {
      name        = substr(join("-", compact([local.legacy_prefix, "egdt", local.legacy_suffix])), 0, 50)
      name_unique = substr(join("-", compact([local.legacy_prefix, "egdt", local.legacy_suffix_unique])), 0, 50)
      dashes      = true
      slug        = "egdt"
      min_length  = 3
      max_length  = 50
      scope       = "parent"
      regex       = "^[a-zA-Z0-9-]+$"
    }
    eventgrid_event_subscription = {
      name        = substr(join("-", compact([local.legacy_prefix, "egs", local.legacy_suffix])), 0, 64)
      name_unique = substr(join("-", compact([local.legacy_prefix, "egs", local.legacy_suffix_unique])), 0, 64)
      dashes      = true
      slug        = "egs"
      min_length  = 3
      max_length  = 64
      scope       = "resourceGroup"
      regex       = "^[a-zA-Z0-9-]+$"
    }
    eventgrid_namespace = {
      name        = substr(join("-", compact([local.legacy_prefix, "evgns", local.legacy_suffix])), 0, 50)
      name_unique = substr(join("-", compact([local.legacy_prefix, "evgns", local.legacy_suffix_unique])), 0, 50)
      dashes      = true
      slug        = "evgns"
      min_length  = 3
      max_length  = 50
      scope       = "resourceGroup"
      regex       = "^[a-zA-Z0-9-]+$"
    }
    eventgrid_system_topic = {
      name        = substr(join("-", compact([local.legacy_prefix, "egst", local.legacy_suffix])), 0, 50)
      name_unique = substr(join("-", compact([local.legacy_prefix, "egst", local.legacy_suffix_unique])), 0, 50)
      dashes      = true
      slug        = "egst"
      min_length  = 3
      max_length  = 50
      scope       = "resourceGroup"
      regex       = "^[a-zA-Z0-9-]+$"
    }
    eventgrid_topic = {
      name        = substr(join("-", compact([local.legacy_prefix, "egt", local.legacy_suffix])), 0, 50)
      name_unique = substr(join("-", compact([local.legacy_prefix, "egt", local.legacy_suffix_unique])), 0, 50)
      dashes      = true
      slug        = "egt"
      min_length  = 3
      max_length  = 50
      scope       = "resourceGroup"
      regex       = "^[a-zA-Z0-9-]+$"
    }
    eventhub = {
      name        = substr(join("-", compact([local.legacy_prefix, "evh", local.legacy_suffix])), 0, 50)
      name_unique = substr(join("-", compact([local.legacy_prefix, "evh", local.legacy_suffix_unique])), 0, 50)
      dashes      = true
      slug        = "evh"
      min_length  = 1
      max_length  = 50
      scope       = "parent"
      regex       = "^[a-zA-Z0-9][a-zA-Z0-9-._]+[a-zA-Z0-9]$"
    }
    eventhub_authorization_rule = {
      name        = substr(join("-", compact([local.legacy_prefix, "ehar", local.legacy_suffix])), 0, 50)
      name_unique = substr(join("-", compact([local.legacy_prefix, "ehar", local.legacy_suffix_unique])), 0, 50)
      dashes      = true
      slug        = "ehar"
      min_length  = 1
      max_length  = 50
      scope       = "parent"
      regex       = "^[a-zA-Z0-9][a-zA-Z0-9-._]+[a-zA-Z0-9]$"
    }
    eventhub_cluster = {
      name        = substr(join("-", compact([local.legacy_prefix, "evhcl", local.legacy_suffix])), 0, 50)
      name_unique = substr(join("-", compact([local.legacy_prefix, "evhcl", local.legacy_suffix_unique])), 0, 50)
      dashes      = true
      slug        = "evhcl"
      min_length  = 6
      max_length  = 50
      scope       = "resourceGroup"
      regex       = "^[a-zA-Z][a-zA-Z0-9-]+[a-zA-Z0-9]$"
    }
    eventhub_consumer_group = {
      name        = substr(join("-", compact([local.legacy_prefix, "ehcg", local.legacy_suffix])), 0, 50)
      name_unique = substr(join("-", compact([local.legacy_prefix, "ehcg", local.legacy_suffix_unique])), 0, 50)
      dashes      = true
      slug        = "ehcg"
      min_length  = 1
      max_length  = 50
      scope       = "parent"
      regex       = "^[a-zA-Z0-9][a-zA-Z0-9-._]+[a-zA-Z0-9]$"
    }
    eventhub_namespace = {
      name        = substr(join("-", compact([local.legacy_prefix, "ehn", local.legacy_suffix])), 0, 50)
      name_unique = substr(join("-", compact([local.legacy_prefix, "ehn", local.legacy_suffix_unique])), 0, 50)
      dashes      = true
      slug        = "ehn"
      min_length  = 1
      max_length  = 50
      scope       = "global"
      regex       = "^[a-zA-Z][a-zA-Z0-9-]+[a-zA-Z0-9]$"
    }
    eventhub_namespace_authorization_rule = {
      name        = substr(join("-", compact([local.legacy_prefix, "ehnar", local.legacy_suffix])), 0, 50)
      name_unique = substr(join("-", compact([local.legacy_prefix, "ehnar", local.legacy_suffix_unique])), 0, 50)
      dashes      = true
      slug        = "ehnar"
      min_length  = 1
      max_length  = 50
      scope       = "parent"
      regex       = "^[a-zA-Z0-9][a-zA-Z0-9-._]+[a-zA-Z0-9]$"
    }
    eventhub_namespace_disaster_recovery_config = {
      name        = substr(join("-", compact([local.legacy_prefix, "ehdr", local.legacy_suffix])), 0, 50)
      name_unique = substr(join("-", compact([local.legacy_prefix, "ehdr", local.legacy_suffix_unique])), 0, 50)
      dashes      = true
      slug        = "ehdr"
      min_length  = 1
      max_length  = 50
      scope       = "parent"
      regex       = "^[a-zA-Z0-9][a-zA-Z0-9-._]+[a-zA-Z0-9]$"
    }
    express_route_circuit = {
      name        = substr(join("-", compact([local.legacy_prefix, "erc", local.legacy_suffix])), 0, 80)
      name_unique = substr(join("-", compact([local.legacy_prefix, "erc", local.legacy_suffix_unique])), 0, 80)
      dashes      = true
      slug        = "erc"
      min_length  = 1
      max_length  = 80
      scope       = "resourceGroup"
      regex       = "^[a-zA-Z0-9][a-zA-Z0-9-._]+[a-zA-Z0-9_]$"
    }
    express_route_gateway = {
      name        = substr(join("-", compact([local.legacy_prefix, "ergw", local.legacy_suffix])), 0, 80)
      name_unique = substr(join("-", compact([local.legacy_prefix, "ergw", local.legacy_suffix_unique])), 0, 80)
      dashes      = true
      slug        = "ergw"
      min_length  = 1
      max_length  = 80
      scope       = "resourceGroup"
      regex       = "^[a-zA-Z0-9][a-zA-Z0-9-._]+[a-zA-Z0-9_]$"
    }
    fabric_capacity = {
      name        = substr(join("", compact([local.legacy_prefix_safe, "fc", local.legacy_suffix_safe])), 0, 63)
      name_unique = substr(join("", compact([local.legacy_prefix_safe, "fc", local.legacy_suffix_unique_safe])), 0, 63)
      dashes      = false
      slug        = "fc"
      min_length  = 3
      max_length  = 63
      scope       = "region"
      regex       = "^[a-z][a-z0-9]+$"
    }
    firewall = {
      name        = substr(join("-", compact([local.legacy_prefix, "fw", local.legacy_suffix])), 0, 80)
      name_unique = substr(join("-", compact([local.legacy_prefix, "fw", local.legacy_suffix_unique])), 0, 80)
      dashes      = true
      slug        = "fw"
      min_length  = 1
      max_length  = 80
      scope       = "resourceGroup"
      regex       = "^[a-zA-Z0-9][a-zA-Z0-9-._]+[a-zA-Z0-9_]$"
    }
    firewall_application_rule_collection = {
      name        = substr(join("-", compact([local.legacy_prefix, "fwapp", local.legacy_suffix])), 0, 80)
      name_unique = substr(join("-", compact([local.legacy_prefix, "fwapp", local.legacy_suffix_unique])), 0, 80)
      dashes      = true
      slug        = "fwapp"
      min_length  = 1
      max_length  = 80
      scope       = "parent"
      regex       = "^[a-zA-Z0-9][a-zA-Z0-9\\-\\._]+[a-zA-Z0-9_]$"
    }
    firewall_ip_configuration = {
      name        = substr(join("-", compact([local.legacy_prefix, "fwipconf", local.legacy_suffix])), 0, 80)
      name_unique = substr(join("-", compact([local.legacy_prefix, "fwipconf", local.legacy_suffix_unique])), 0, 80)
      dashes      = true
      slug        = "fwipconf"
      min_length  = 1
      max_length  = 80
      scope       = "resourceGroup"
      regex       = "^[a-zA-Z0-9][a-zA-Z0-9\\-\\._]+[a-zA-Z0-9_]$"
    }
    firewall_nat_rule_collection = {
      name        = substr(join("-", compact([local.legacy_prefix, "fwnatrc", local.legacy_suffix])), 0, 80)
      name_unique = substr(join("-", compact([local.legacy_prefix, "fwnatrc", local.legacy_suffix_unique])), 0, 80)
      dashes      = true
      slug        = "fwnatrc"
      min_length  = 1
      max_length  = 80
      scope       = "parent"
      regex       = "^[a-zA-Z0-9][a-zA-Z0-9\\-\\._]+[a-zA-Z0-9_]$"
    }
    firewall_network_rule_collection = {
      name        = substr(join("-", compact([local.legacy_prefix, "fwnetrc", local.legacy_suffix])), 0, 80)
      name_unique = substr(join("-", compact([local.legacy_prefix, "fwnetrc", local.legacy_suffix_unique])), 0, 80)
      dashes      = true
      slug        = "fwnetrc"
      min_length  = 1
      max_length  = 80
      scope       = "parent"
      regex       = "^[a-zA-Z0-9][a-zA-Z0-9\\-\\._]+[a-zA-Z0-9_]$"
    }
    firewall_policy = {
      name        = substr(join("-", compact([local.legacy_prefix, "afwp", local.legacy_suffix])), 0, 80)
      name_unique = substr(join("-", compact([local.legacy_prefix, "afwp", local.legacy_suffix_unique])), 0, 80)
      dashes      = true
      slug        = "afwp"
      min_length  = 1
      max_length  = 80
      scope       = "resourceGroup"
      regex       = "^[a-zA-Z0-9][a-zA-Z0-9-._]+[a-zA-Z0-9_]$"
    }
    firewall_policy_rule_collection_group = {
      name        = substr(join("-", compact([local.legacy_prefix, "fwprcg", local.legacy_suffix])), 0, 80)
      name_unique = substr(join("-", compact([local.legacy_prefix, "fwprcg", local.legacy_suffix_unique])), 0, 80)
      dashes      = true
      slug        = "fwprcg"
      min_length  = 1
      max_length  = 80
      scope       = "parent"
      regex       = "^[a-zA-Z0-9][a-zA-Z0-9\\-\\._]+[a-zA-Z0-9_]$"
    }
    frontdoor = {
      name        = substr(join("-", compact([local.legacy_prefix, "fd", local.legacy_suffix])), 0, 64)
      name_unique = substr(join("-", compact([local.legacy_prefix, "fd", local.legacy_suffix_unique])), 0, 64)
      dashes      = true
      slug        = "fd"
      min_length  = 5
      max_length  = 64
      scope       = "global"
      regex       = "^[a-zA-Z0-9][a-zA-Z0-9-]+[a-zA-Z0-9]$"
    }
    frontdoor_firewall_policy = {
      name        = substr(join("-", compact([local.legacy_prefix, "fdfw", local.legacy_suffix])), 0, 80)
      name_unique = substr(join("-", compact([local.legacy_prefix, "fdfw", local.legacy_suffix_unique])), 0, 80)
      dashes      = true
      slug        = "fdfw"
      min_length  = 1
      max_length  = 80
      scope       = "global"
      regex       = "^[a-zA-Z0-9][a-zA-Z0-9-._]+[a-zA-Z0-9_]$"
    }
    function_app = {
      name        = substr(join("-", compact([local.legacy_prefix, "func", local.legacy_suffix])), 0, 60)
      name_unique = substr(join("-", compact([local.legacy_prefix, "func", local.legacy_suffix_unique])), 0, 60)
      dashes      = true
      slug        = "func"
      min_length  = 2
      max_length  = 60
      scope       = "global"
      regex       = "^[a-zA-Z0-9][a-zA-Z0-9-]+[a-zA-Z0-9]$"
    }
    hdinsight_hadoop_cluster = {
      name        = substr(join("-", compact([local.legacy_prefix, "hadoop", local.legacy_suffix])), 0, 59)
      name_unique = substr(join("-", compact([local.legacy_prefix, "hadoop", local.legacy_suffix_unique])), 0, 59)
      dashes      = true
      slug        = "hadoop"
      min_length  = 3
      max_length  = 59
      scope       = "global"
      regex       = "^[a-zA-Z0-9][a-zA-Z0-9-]+[a-zA-Z0-9]$"
    }
    hdinsight_hbase_cluster = {
      name        = substr(join("-", compact([local.legacy_prefix, "hbase", local.legacy_suffix])), 0, 59)
      name_unique = substr(join("-", compact([local.legacy_prefix, "hbase", local.legacy_suffix_unique])), 0, 59)
      dashes      = true
      slug        = "hbase"
      min_length  = 3
      max_length  = 59
      scope       = "global"
      regex       = "^[a-zA-Z0-9][a-zA-Z0-9-]+[a-zA-Z0-9]$"
    }
    hdinsight_interactive_query_cluster = {
      name        = substr(join("-", compact([local.legacy_prefix, "iqr", local.legacy_suffix])), 0, 59)
      name_unique = substr(join("-", compact([local.legacy_prefix, "iqr", local.legacy_suffix_unique])), 0, 59)
      dashes      = true
      slug        = "iqr"
      min_length  = 3
      max_length  = 59
      scope       = "global"
      regex       = "^[a-zA-Z0-9][a-zA-Z0-9-]+[a-zA-Z0-9]$"
    }
    hdinsight_kafka_cluster = {
      name        = substr(join("-", compact([local.legacy_prefix, "kafka", local.legacy_suffix])), 0, 59)
      name_unique = substr(join("-", compact([local.legacy_prefix, "kafka", local.legacy_suffix_unique])), 0, 59)
      dashes      = true
      slug        = "kafka"
      min_length  = 3
      max_length  = 59
      scope       = "global"
      regex       = "^[a-zA-Z0-9][a-zA-Z0-9-]+[a-zA-Z0-9]$"
    }
    hdinsight_ml_services_cluster = {
      name        = substr(join("-", compact([local.legacy_prefix, "mls", local.legacy_suffix])), 0, 59)
      name_unique = substr(join("-", compact([local.legacy_prefix, "mls", local.legacy_suffix_unique])), 0, 59)
      dashes      = true
      slug        = "mls"
      min_length  = 3
      max_length  = 59
      scope       = "global"
      regex       = "^[a-zA-Z0-9][a-zA-Z0-9-]+[a-zA-Z0-9]$"
    }
    hdinsight_rserver_cluster = {
      name        = substr(join("-", compact([local.legacy_prefix, "rsv", local.legacy_suffix])), 0, 59)
      name_unique = substr(join("-", compact([local.legacy_prefix, "rsv", local.legacy_suffix_unique])), 0, 59)
      dashes      = true
      slug        = "rsv"
      min_length  = 3
      max_length  = 59
      scope       = "global"
      regex       = "^[a-zA-Z0-9][a-zA-Z0-9-]+[a-zA-Z0-9]$"
    }
    hdinsight_spark_cluster = {
      name        = substr(join("-", compact([local.legacy_prefix, "spark", local.legacy_suffix])), 0, 59)
      name_unique = substr(join("-", compact([local.legacy_prefix, "spark", local.legacy_suffix_unique])), 0, 59)
      dashes      = true
      slug        = "spark"
      min_length  = 3
      max_length  = 59
      scope       = "global"
      regex       = "^[a-zA-Z0-9][a-zA-Z0-9-]+[a-zA-Z0-9]$"
    }
    hdinsight_storm_cluster = {
      name        = substr(join("-", compact([local.legacy_prefix, "storm", local.legacy_suffix])), 0, 59)
      name_unique = substr(join("-", compact([local.legacy_prefix, "storm", local.legacy_suffix_unique])), 0, 59)
      dashes      = true
      slug        = "storm"
      min_length  = 3
      max_length  = 59
      scope       = "global"
      regex       = "^[a-zA-Z0-9][a-zA-Z0-9-]+[a-zA-Z0-9]$"
    }
    image = {
      name        = substr(join("-", compact([local.legacy_prefix, "img", local.legacy_suffix])), 0, 80)
      name_unique = substr(join("-", compact([local.legacy_prefix, "img", local.legacy_suffix_unique])), 0, 80)
      dashes      = true
      slug        = "img"
      min_length  = 1
      max_length  = 80
      scope       = "resourceGroup"
      regex       = "^[a-zA-Z0-9][a-zA-Z0-9-_.]+[a-zA-Z0-9_]$"
    }
    iotcentral_application = {
      name        = substr(join("-", compact([local.legacy_prefix, "iotapp", local.legacy_suffix])), 0, 63)
      name_unique = substr(join("-", compact([local.legacy_prefix, "iotapp", local.legacy_suffix_unique])), 0, 63)
      dashes      = true
      slug        = "iotapp"
      min_length  = 2
      max_length  = 63
      scope       = "global"
      regex       = "^[a-z0-9][a-z0-9-]+[a-z0-9]$"
    }
    iothub = {
      name        = substr(join("-", compact([local.legacy_prefix, "iot", local.legacy_suffix])), 0, 50)
      name_unique = substr(join("-", compact([local.legacy_prefix, "iot", local.legacy_suffix_unique])), 0, 50)
      dashes      = true
      slug        = "iot"
      min_length  = 3
      max_length  = 50
      scope       = "global"
      regex       = "^[a-zA-Z0-9][a-zA-Z0-9-]+[a-z0-9]$"
    }
    iothub_consumer_group = {
      name        = substr(join("-", compact([local.legacy_prefix, "iotcg", local.legacy_suffix])), 0, 50)
      name_unique = substr(join("-", compact([local.legacy_prefix, "iotcg", local.legacy_suffix_unique])), 0, 50)
      dashes      = true
      slug        = "iotcg"
      min_length  = 1
      max_length  = 50
      scope       = "parent"
      regex       = "^[a-zA-Z0-9-._]+$"
    }
    iothub_dps = {
      name        = substr(join("-", compact([local.legacy_prefix, "dps", local.legacy_suffix])), 0, 64)
      name_unique = substr(join("-", compact([local.legacy_prefix, "dps", local.legacy_suffix_unique])), 0, 64)
      dashes      = true
      slug        = "dps"
      min_length  = 3
      max_length  = 64
      scope       = "resoureceGroup"
      regex       = "^[a-zA-Z0-9-]+[a-zA-Z0-9]$"
    }
    iothub_dps_certificate = {
      name        = substr(join("-", compact([local.legacy_prefix, "dpscert", local.legacy_suffix])), 0, 64)
      name_unique = substr(join("-", compact([local.legacy_prefix, "dpscert", local.legacy_suffix_unique])), 0, 64)
      dashes      = true
      slug        = "dpscert"
      min_length  = 1
      max_length  = 64
      scope       = "parent"
      regex       = "^[a-zA-Z0-9-._]+$"
    }
    ip_group = {
      name        = substr(join("-", compact([local.legacy_prefix, "ipg", local.legacy_suffix])), 0, 80)
      name_unique = substr(join("-", compact([local.legacy_prefix, "ipg", local.legacy_suffix_unique])), 0, 80)
      dashes      = true
      slug        = "ipg"
      min_length  = 1
      max_length  = 80
      scope       = "resourceGroup"
      regex       = "^[a-zA-Z0-9][a-zA-Z0-9-._]+[a-zA-Z0-9_]$"
    }
    key_vault = {
      name        = substr(join("-", compact([local.legacy_prefix, "kv", local.legacy_suffix])), 0, 24)
      name_unique = substr(join("-", compact([local.legacy_prefix, "kv", local.legacy_suffix_unique])), 0, 24)
      dashes      = true
      slug        = "kv"
      min_length  = 3
      max_length  = 24
      scope       = "global"
      regex       = "^[a-zA-Z][a-zA-Z0-9-]+[a-zA-Z0-9]$"
    }
    key_vault_certificate = {
      name        = substr(join("-", compact([local.legacy_prefix, "kvc", local.legacy_suffix])), 0, 127)
      name_unique = substr(join("-", compact([local.legacy_prefix, "kvc", local.legacy_suffix_unique])), 0, 127)
      dashes      = true
      slug        = "kvc"
      min_length  = 1
      max_length  = 127
      scope       = "parent"
      regex       = "^[a-zA-Z0-9-]+$"
    }
    key_vault_key = {
      name        = substr(join("-", compact([local.legacy_prefix, "kvk", local.legacy_suffix])), 0, 127)
      name_unique = substr(join("-", compact([local.legacy_prefix, "kvk", local.legacy_suffix_unique])), 0, 127)
      dashes      = true
      slug        = "kvk"
      min_length  = 1
      max_length  = 127
      scope       = "parent"
      regex       = "^[a-zA-Z0-9-]+$"
    }
    key_vault_secret = {
      name        = substr(join("-", compact([local.legacy_prefix, "kvs", local.legacy_suffix])), 0, 127)
      name_unique = substr(join("-", compact([local.legacy_prefix, "kvs", local.legacy_suffix_unique])), 0, 127)
      dashes      = true
      slug        = "kvs"
      min_length  = 1
      max_length  = 127
      scope       = "parent"
      regex       = "^[a-zA-Z0-9-]+$"
    }
    kubernetes_cluster = {
      name        = substr(join("-", compact([local.legacy_prefix, "aks", local.legacy_suffix])), 0, 63)
      name_unique = substr(join("-", compact([local.legacy_prefix, "aks", local.legacy_suffix_unique])), 0, 63)
      dashes      = true
      slug        = "aks"
      min_length  = 1
      max_length  = 63
      scope       = "resourceGroup"
      regex       = "^[a-zA-Z0-9][a-zA-Z0-9-_.]+[a-zA-Z0-9]$"
    }
    kusto_cluster = {
      name        = substr(join("", compact([local.legacy_prefix_safe, "kc", local.legacy_suffix_safe])), 0, 22)
      name_unique = substr(join("", compact([local.legacy_prefix_safe, "kc", local.legacy_suffix_unique_safe])), 0, 22)
      dashes      = false
      slug        = "kc"
      min_length  = 4
      max_length  = 22
      scope       = "global"
      regex       = "^[a-z][a-z0-9]+$"
    }
    kusto_database = {
      name        = substr(join("-", compact([local.legacy_prefix, "kdb", local.legacy_suffix])), 0, 260)
      name_unique = substr(join("-", compact([local.legacy_prefix, "kdb", local.legacy_suffix_unique])), 0, 260)
      dashes      = true
      slug        = "kdb"
      min_length  = 1
      max_length  = 260
      scope       = "parent"
      regex       = "^[a-zA-Z0-9- .]+$"
    }
    kusto_eventhub_data_connection = {
      name        = substr(join("-", compact([local.legacy_prefix, "kehc", local.legacy_suffix])), 0, 40)
      name_unique = substr(join("-", compact([local.legacy_prefix, "kehc", local.legacy_suffix_unique])), 0, 40)
      dashes      = true
      slug        = "kehc"
      min_length  = 1
      max_length  = 40
      scope       = "parent"
      regex       = "^[a-zA-Z0-9- .]+$"
    }
    lb = {
      name        = substr(join("-", compact([local.legacy_prefix, "lb", local.legacy_suffix])), 0, 80)
      name_unique = substr(join("-", compact([local.legacy_prefix, "lb", local.legacy_suffix_unique])), 0, 80)
      dashes      = true
      slug        = "lb"
      min_length  = 1
      max_length  = 80
      scope       = "resourceGroup"
      regex       = "^[a-zA-Z0-9][a-zA-Z0-9-._]+[a-zA-Z0-9_]$"
    }
    lb_nat_rule = {
      name        = substr(join("-", compact([local.legacy_prefix, "lbnatrl", local.legacy_suffix])), 0, 80)
      name_unique = substr(join("-", compact([local.legacy_prefix, "lbnatrl", local.legacy_suffix_unique])), 0, 80)
      dashes      = true
      slug        = "lbnatrl"
      min_length  = 1
      max_length  = 80
      scope       = "parent"
      regex       = "^[a-zA-Z0-9][a-zA-Z0-9-._]+[a-zA-Z0-9_]$"
    }
    lb_rule = {
      name        = substr(join("-", compact([local.legacy_prefix, "rule", local.legacy_suffix])), 0, 80)
      name_unique = substr(join("-", compact([local.legacy_prefix, "rule", local.legacy_suffix_unique])), 0, 80)
      dashes      = true
      slug        = "rule"
      min_length  = 1
      max_length  = 80
      scope       = "parent"
      regex       = "^[a-zA-Z0-9][a-zA-Z0-9-._]+[a-zA-Z0-9_]$"
    }
    linux_virtual_machine = {
      name        = substr(join("-", compact([local.legacy_prefix, "vm", local.legacy_suffix])), 0, 64)
      name_unique = substr(join("-", compact([local.legacy_prefix, "vm", local.legacy_suffix_unique])), 0, 64)
      dashes      = true
      slug        = "vm"
      min_length  = 1
      max_length  = 64
      scope       = "resourceGroup"
      regex       = "^[^\\/\"\\[\\]:|<>+=;,?*@&_][^\\/\"\\[\\]:|<>+=;,?*@&]+[^\\/\"\\[\\]:|<>+=;,?*@&.-]$"
    }
    linux_virtual_machine_scale_set = {
      name        = substr(join("-", compact([local.legacy_prefix, "vmss", local.legacy_suffix])), 0, 64)
      name_unique = substr(join("-", compact([local.legacy_prefix, "vmss", local.legacy_suffix_unique])), 0, 64)
      dashes      = true
      slug        = "vmss"
      min_length  = 1
      max_length  = 64
      scope       = "resourceGroup"
      regex       = "^[^\\/\"\\[\\]:|<>+=;,?*@&_][^\\/\"\\[\\]:|<>+=;,?*@&]+[^\\/\"\\[\\]:|<>+=;,?*@&.-]$"
    }
    load_test = {
      name        = substr(join("-", compact([local.legacy_prefix, "lt", local.legacy_suffix])), 0, 64)
      name_unique = substr(join("-", compact([local.legacy_prefix, "lt", local.legacy_suffix_unique])), 0, 64)
      dashes      = true
      slug        = "lt"
      min_length  = 1
      max_length  = 64
      scope       = "resourceGroup"
      regex       = "^[a-zA-Z][a-zA-Z0-9-_]{0,62}[a-zA-Z0-9|]$"
    }
    local_network_gateway = {
      name        = substr(join("-", compact([local.legacy_prefix, "lgw", local.legacy_suffix])), 0, 80)
      name_unique = substr(join("-", compact([local.legacy_prefix, "lgw", local.legacy_suffix_unique])), 0, 80)
      dashes      = true
      slug        = "lgw"
      min_length  = 1
      max_length  = 80
      scope       = "resourceGroup"
      regex       = "^[a-zA-Z0-9][a-zA-Z0-9-._]+[a-zA-Z0-9_]$"
    }
    log_analytics_query_pack = {
      name        = substr(join("-", compact([local.legacy_prefix, "pack", local.legacy_suffix])), 0, 63)
      name_unique = substr(join("-", compact([local.legacy_prefix, "pack", local.legacy_suffix_unique])), 0, 63)
      dashes      = true
      slug        = "pack"
      min_length  = 4
      max_length  = 63
      scope       = "resourceGroup"
      regex       = "^[a-zA-Z0-9][a-zA-Z0-9-]+[a-zA-Z0-9]$"
    }
    log_analytics_workspace = {
      name        = substr(join("-", compact([local.legacy_prefix, "log", local.legacy_suffix])), 0, 63)
      name_unique = substr(join("-", compact([local.legacy_prefix, "log", local.legacy_suffix_unique])), 0, 63)
      dashes      = true
      slug        = "log"
      min_length  = 4
      max_length  = 63
      scope       = "parent"
      regex       = "^[a-zA-Z0-9][a-zA-Z0-9-]+[a-zA-Z0-9]$"
    }
    logic_app_integration_account = {
      name        = substr(join("-", compact([local.legacy_prefix, "ia", local.legacy_suffix])), 0, 80)
      name_unique = substr(join("-", compact([local.legacy_prefix, "ia", local.legacy_suffix_unique])), 0, 80)
      dashes      = true
      slug        = "ia"
      min_length  = 1
      max_length  = 80
      scope       = "resourceGroup"
      regex       = "^[a-zA-Z0-9][a-zA-Z0-9-._()]+[a-zA-Z0-9]$"
    }
    logic_app_workflow = {
      name        = substr(join("-", compact([local.legacy_prefix, "logic", local.legacy_suffix])), 0, 80)
      name_unique = substr(join("-", compact([local.legacy_prefix, "logic", local.legacy_suffix_unique])), 0, 80)
      dashes      = true
      slug        = "logic"
      min_length  = 1
      max_length  = 80
      scope       = "resourceGroup"
      regex       = "^[a-zA-Z0-9][a-zA-Z0-9-._]+[a-zA-Z0-9_]$"
    }
    machine_learning_registry = {
      name        = substr(join("-", compact([local.legacy_prefix, "mlr", local.legacy_suffix])), 0, 33)
      name_unique = substr(join("-", compact([local.legacy_prefix, "mlr", local.legacy_suffix_unique])), 0, 33)
      dashes      = true
      slug        = "mlr"
      min_length  = 3
      max_length  = 33
      scope       = "resourceGroup"
      regex       = "^[a-zA-Z0-9][a-zA-Z0-9_-]{2,32}$"
    }
    machine_learning_workspace = {
      name        = substr(join("-", compact([local.legacy_prefix, "mlw", local.legacy_suffix])), 0, 260)
      name_unique = substr(join("-", compact([local.legacy_prefix, "mlw", local.legacy_suffix_unique])), 0, 260)
      dashes      = true
      slug        = "mlw"
      min_length  = 1
      max_length  = 260
      scope       = "resourceGroup"
      regex       = "^[^<>*%:.?\\+\\/]+[^<>*%:.?\\+\\/ ]$"
    }
    maintenance_configuration = {
      name        = substr(join("-", compact([local.legacy_prefix, "mc", local.legacy_suffix])), 0, 80)
      name_unique = substr(join("-", compact([local.legacy_prefix, "mc", local.legacy_suffix_unique])), 0, 80)
      dashes      = true
      slug        = "mc"
      min_length  = 1
      max_length  = 80
      scope       = "resourceGroup"
      regex       = "^[a-zA-Z0-9][a-zA-Z0-9-._]+[a-zA-Z0-9_]$"
    }
    managed_disk = {
      name        = substr(join("-", compact([local.legacy_prefix, "dsk", local.legacy_suffix])), 0, 80)
      name_unique = substr(join("-", compact([local.legacy_prefix, "dsk", local.legacy_suffix_unique])), 0, 80)
      dashes      = true
      slug        = "dsk"
      min_length  = 1
      max_length  = 80
      scope       = "resourceGroup"
      regex       = "^[a-zA-Z0-9_]+$"
    }
    management_group = {
      name        = substr(join("-", compact([local.legacy_prefix, "mg", local.legacy_suffix])), 0, 90)
      name_unique = substr(join("-", compact([local.legacy_prefix, "mg", local.legacy_suffix_unique])), 0, 90)
      dashes      = true
      slug        = "mg"
      min_length  = 1
      max_length  = 90
      scope       = "tenant"
      regex       = "^[a-zA-Z0-9-_().]+$"
    }
    maps_account = {
      name        = substr(join("-", compact([local.legacy_prefix, "map", local.legacy_suffix])), 0, 98)
      name_unique = substr(join("-", compact([local.legacy_prefix, "map", local.legacy_suffix_unique])), 0, 98)
      dashes      = true
      slug        = "map"
      min_length  = 1
      max_length  = 98
      scope       = "resourceGroup"
      regex       = "^[a-zA-Z0-9][a-zA-Z0-9-._]+$"
    }
    mariadb_database = {
      name        = substr(join("-", compact([local.legacy_prefix, "mariadb", local.legacy_suffix])), 0, 63)
      name_unique = substr(join("-", compact([local.legacy_prefix, "mariadb", local.legacy_suffix_unique])), 0, 63)
      dashes      = true
      slug        = "mariadb"
      min_length  = 1
      max_length  = 63
      scope       = "parent"
      regex       = "^[a-zA-Z0-9-_]+$"
    }
    mariadb_firewall_rule = {
      name        = substr(join("-", compact([local.legacy_prefix, "mariafw", local.legacy_suffix])), 0, 128)
      name_unique = substr(join("-", compact([local.legacy_prefix, "mariafw", local.legacy_suffix_unique])), 0, 128)
      dashes      = true
      slug        = "mariafw"
      min_length  = 1
      max_length  = 128
      scope       = "parent"
      regex       = "^[a-zA-Z0-9-_]+$"
    }
    mariadb_server = {
      name        = substr(join("-", compact([local.legacy_prefix, "maria", local.legacy_suffix])), 0, 63)
      name_unique = substr(join("-", compact([local.legacy_prefix, "maria", local.legacy_suffix_unique])), 0, 63)
      dashes      = true
      slug        = "maria"
      min_length  = 3
      max_length  = 63
      scope       = "global"
      regex       = "^[a-z0-9][a-zA-Z0-9-]+[a-z0-9]$"
    }
    mariadb_virtual_network_rule = {
      name        = substr(join("-", compact([local.legacy_prefix, "mariavn", local.legacy_suffix])), 0, 128)
      name_unique = substr(join("-", compact([local.legacy_prefix, "mariavn", local.legacy_suffix_unique])), 0, 128)
      dashes      = true
      slug        = "mariavn"
      min_length  = 1
      max_length  = 128
      scope       = "parent"
      regex       = "^[a-zA-Z0-9-_]+$"
    }
    monitor_action_group = {
      name        = substr(join("-", compact([local.legacy_prefix, "mag", local.legacy_suffix])), 0, 260)
      name_unique = substr(join("-", compact([local.legacy_prefix, "mag", local.legacy_suffix_unique])), 0, 260)
      dashes      = true
      slug        = "mag"
      min_length  = 1
      max_length  = 260
      scope       = "resourceGroup"
      regex       = "^[^%&?\\+\\/]+[^^%&?\\+\\/ ]$"
    }
    monitor_alert_processing_rule_action_group = {
      name        = substr(join("-", compact([local.legacy_prefix, "apr", local.legacy_suffix])), 0, 260)
      name_unique = substr(join("-", compact([local.legacy_prefix, "apr", local.legacy_suffix_unique])), 0, 260)
      dashes      = true
      slug        = "apr"
      min_length  = 1
      max_length  = 260
      scope       = "resourceGroup"
      regex       = "^[^<>*{}%&:\\?+/#|]+[^<>*{}%&:\\?+/#| ]$"
    }
    monitor_autoscale_setting = {
      name        = substr(join("-", compact([local.legacy_prefix, "mas", local.legacy_suffix])), 0, 260)
      name_unique = substr(join("-", compact([local.legacy_prefix, "mas", local.legacy_suffix_unique])), 0, 260)
      dashes      = true
      slug        = "mas"
      min_length  = 1
      max_length  = 260
      scope       = "resourceGroup"
      regex       = "^[^<>%&#.,?\\+\\/]+[^<>%&#.,?\\+\\/ ]$"
    }
    monitor_data_collection_endpoint = {
      name        = substr(join("-", compact([local.legacy_prefix, "dce", local.legacy_suffix])), 0, 64)
      name_unique = substr(join("-", compact([local.legacy_prefix, "dce", local.legacy_suffix_unique])), 0, 64)
      dashes      = true
      slug        = "dce"
      min_length  = 1
      max_length  = 64
      scope       = "resourceGroup"
      regex       = "^[a-zA-Z0-9-_]+$"
    }
    monitor_data_collection_rule = {
      name        = substr(join("-", compact([local.legacy_prefix, "dcr", local.legacy_suffix])), 0, 64)
      name_unique = substr(join("-", compact([local.legacy_prefix, "dcr", local.legacy_suffix_unique])), 0, 64)
      dashes      = true
      slug        = "dcr"
      min_length  = 1
      max_length  = 64
      scope       = "resourceGroup"
      regex       = "^[a-zA-Z0-9-_]+$"
    }
    monitor_diagnostic_setting = {
      name        = substr(join("-", compact([local.legacy_prefix, "mds", local.legacy_suffix])), 0, 260)
      name_unique = substr(join("-", compact([local.legacy_prefix, "mds", local.legacy_suffix_unique])), 0, 260)
      dashes      = true
      slug        = "mds"
      min_length  = 1
      max_length  = 260
      scope       = "resourceGroup"
      regex       = "^[^*<>%:&?\\+\\/]+[^*<>%:&?\\+\\/ ]$"
    }
    monitor_scheduled_query_rules_alert = {
      name        = substr(join("-", compact([local.legacy_prefix, "msqa", local.legacy_suffix])), 0, 260)
      name_unique = substr(join("-", compact([local.legacy_prefix, "msqa", local.legacy_suffix_unique])), 0, 260)
      dashes      = true
      slug        = "msqa"
      min_length  = 1
      max_length  = 260
      scope       = "resourceGroup"
      regex       = "^[^*<>%:{}&#.,?\\+\\/]+[^*<>%:{}&#.,?\\+\\/ ]$"
    }
    mssql_database = {
      name        = substr(join("-", compact([local.legacy_prefix, "sqldb", local.legacy_suffix])), 0, 128)
      name_unique = substr(join("-", compact([local.legacy_prefix, "sqldb", local.legacy_suffix_unique])), 0, 128)
      dashes      = true
      slug        = "sqldb"
      min_length  = 1
      max_length  = 128
      scope       = "parent"
      regex       = "^[^<>*%:.?\\+\\/]+[^<>*%:.?\\+\\/ ]$"
    }
    mssql_elasticpool = {
      name        = substr(join("-", compact([local.legacy_prefix, "sqlep", local.legacy_suffix])), 0, 128)
      name_unique = substr(join("-", compact([local.legacy_prefix, "sqlep", local.legacy_suffix_unique])), 0, 128)
      dashes      = true
      slug        = "sqlep"
      min_length  = 1
      max_length  = 128
      scope       = "parent"
      regex       = "^[^<>*%:.?\\+\\/]+[^<>*%:.?\\+\\/ ]$"
    }
    mssql_job_agent = {
      name        = substr(join("-", compact([local.legacy_prefix, "sqlja", local.legacy_suffix])), 0, 128)
      name_unique = substr(join("-", compact([local.legacy_prefix, "sqlja", local.legacy_suffix_unique])), 0, 128)
      dashes      = true
      slug        = "sqlja"
      min_length  = 1
      max_length  = 128
      scope       = "parent"
      regex       = "^[^<>*%:.?\\+\\/]+[^<>*%:.?\\+\\/ ]$"
    }
    mssql_managed_instance = {
      name        = substr(join("-", compact([local.legacy_prefix, "sqlmi", local.legacy_suffix])), 0, 63)
      name_unique = substr(join("-", compact([local.legacy_prefix, "sqlmi", local.legacy_suffix_unique])), 0, 63)
      dashes      = true
      slug        = "sqlmi"
      min_length  = 1
      max_length  = 63
      scope       = "global"
      regex       = "^[a-z0-9][a-z0-9-]+[a-z0-9]$"
    }
    mssql_server = {
      name        = substr(join("-", compact([local.legacy_prefix, "sql", local.legacy_suffix])), 0, 63)
      name_unique = substr(join("-", compact([local.legacy_prefix, "sql", local.legacy_suffix_unique])), 0, 63)
      dashes      = true
      slug        = "sql"
      min_length  = 1
      max_length  = 63
      scope       = "global"
      regex       = "^[a-z0-9][a-z0-9-]+[a-z0-9]$"
    }
    mysql_database = {
      name        = substr(join("-", compact([local.legacy_prefix, "mysqldb", local.legacy_suffix])), 0, 63)
      name_unique = substr(join("-", compact([local.legacy_prefix, "mysqldb", local.legacy_suffix_unique])), 0, 63)
      dashes      = true
      slug        = "mysqldb"
      min_length  = 1
      max_length  = 63
      scope       = "parent"
      regex       = "^[a-zA-Z0-9-_]+$"
    }
    mysql_firewall_rule = {
      name        = substr(join("-", compact([local.legacy_prefix, "mysqlfw", local.legacy_suffix])), 0, 128)
      name_unique = substr(join("-", compact([local.legacy_prefix, "mysqlfw", local.legacy_suffix_unique])), 0, 128)
      dashes      = true
      slug        = "mysqlfw"
      min_length  = 1
      max_length  = 128
      scope       = "parent"
      regex       = "^[a-zA-Z0-9-_]+$"
    }
    mysql_server = {
      name        = substr(join("-", compact([local.legacy_prefix, "mysql", local.legacy_suffix])), 0, 63)
      name_unique = substr(join("-", compact([local.legacy_prefix, "mysql", local.legacy_suffix_unique])), 0, 63)
      dashes      = true
      slug        = "mysql"
      min_length  = 3
      max_length  = 63
      scope       = "global"
      regex       = "^[a-z0-9][a-zA-Z0-9-]+[a-z0-9]$"
    }
    mysql_virtual_network_rule = {
      name        = substr(join("-", compact([local.legacy_prefix, "mysqlvn", local.legacy_suffix])), 0, 128)
      name_unique = substr(join("-", compact([local.legacy_prefix, "mysqlvn", local.legacy_suffix_unique])), 0, 128)
      dashes      = true
      slug        = "mysqlvn"
      min_length  = 1
      max_length  = 128
      scope       = "parent"
      regex       = "^[a-zA-Z0-9-_]+$"
    }
    nat_gateway = {
      name        = substr(join("-", compact([local.legacy_prefix, "ng", local.legacy_suffix])), 0, 80)
      name_unique = substr(join("-", compact([local.legacy_prefix, "ng", local.legacy_suffix_unique])), 0, 80)
      dashes      = true
      slug        = "ng"
      min_length  = 1
      max_length  = 80
      scope       = "resourceGroup"
      regex       = "^[a-zA-Z0-9][a-zA-Z0-9-._]+[a-zA-Z0-9_]$"
    }
    network_ddos_protection_plan = {
      name        = substr(join("-", compact([local.legacy_prefix, "ddospp", local.legacy_suffix])), 0, 80)
      name_unique = substr(join("-", compact([local.legacy_prefix, "ddospp", local.legacy_suffix_unique])), 0, 80)
      dashes      = true
      slug        = "ddospp"
      min_length  = 1
      max_length  = 80
      scope       = "parent"
      regex       = "^[a-zA-Z0-9][a-zA-Z0-9-._]+[a-zA-Z0-9_]$"
    }
    network_interface = {
      name        = substr(join("-", compact([local.legacy_prefix, "nic", local.legacy_suffix])), 0, 80)
      name_unique = substr(join("-", compact([local.legacy_prefix, "nic", local.legacy_suffix_unique])), 0, 80)
      dashes      = true
      slug        = "nic"
      min_length  = 1
      max_length  = 80
      scope       = "resourceGroup"
      regex       = "^[a-zA-Z0-9][a-zA-Z0-9-._]+[a-zA-Z0-9_]$"
    }
    network_manager = {
      name        = substr(join("-", compact([local.legacy_prefix, "vnm", local.legacy_suffix])), 0, 80)
      name_unique = substr(join("-", compact([local.legacy_prefix, "vnm", local.legacy_suffix_unique])), 0, 80)
      dashes      = true
      slug        = "vnm"
      min_length  = 1
      max_length  = 80
      scope       = "resourceGroup"
      regex       = "^[a-zA-Z0-9][a-zA-Z0-9-._]+[a-zA-Z0-9_]$"
    }
    network_security_group = {
      name        = substr(join("-", compact([local.legacy_prefix, "nsg", local.legacy_suffix])), 0, 80)
      name_unique = substr(join("-", compact([local.legacy_prefix, "nsg", local.legacy_suffix_unique])), 0, 80)
      dashes      = true
      slug        = "nsg"
      min_length  = 1
      max_length  = 80
      scope       = "resourceGroup"
      regex       = "^[a-zA-Z0-9][a-zA-Z0-9-._]+[a-zA-Z0-9_]$"
    }
    network_security_group_rule = {
      name        = substr(join("-", compact([local.legacy_prefix, "nsgr", local.legacy_suffix])), 0, 80)
      name_unique = substr(join("-", compact([local.legacy_prefix, "nsgr", local.legacy_suffix_unique])), 0, 80)
      dashes      = true
      slug        = "nsgr"
      min_length  = 1
      max_length  = 80
      scope       = "parent"
      regex       = "^[a-zA-Z0-9][a-zA-Z0-9-._]+[a-zA-Z0-9_]$"
    }
    network_security_rule = {
      name        = substr(join("-", compact([local.legacy_prefix, "nsgr", local.legacy_suffix])), 0, 80)
      name_unique = substr(join("-", compact([local.legacy_prefix, "nsgr", local.legacy_suffix_unique])), 0, 80)
      dashes      = true
      slug        = "nsgr"
      min_length  = 1
      max_length  = 80
      scope       = "parent"
      regex       = "^[a-zA-Z0-9][a-zA-Z0-9-._]+[a-zA-Z0-9_]$"
    }
    network_watcher = {
      name        = substr(join("-", compact([local.legacy_prefix, "nw", local.legacy_suffix])), 0, 80)
      name_unique = substr(join("-", compact([local.legacy_prefix, "nw", local.legacy_suffix_unique])), 0, 80)
      dashes      = true
      slug        = "nw"
      min_length  = 1
      max_length  = 80
      scope       = "resourceGroup"
      regex       = "^[a-zA-Z0-9][a-zA-Z0-9-._]+[a-zA-Z0-9_]$"
    }
    notification_hub = {
      name        = substr(join("-", compact([local.legacy_prefix, "nh", local.legacy_suffix])), 0, 260)
      name_unique = substr(join("-", compact([local.legacy_prefix, "nh", local.legacy_suffix_unique])), 0, 260)
      dashes      = true
      slug        = "nh"
      min_length  = 1
      max_length  = 260
      scope       = "parent"
      regex       = "^[a-zA-Z0-9][a-zA-Z0-9-._]+$"
    }
    notification_hub_authorization_rule = {
      name        = substr(join("-", compact([local.legacy_prefix, "dnsrec", local.legacy_suffix])), 0, 256)
      name_unique = substr(join("-", compact([local.legacy_prefix, "dnsrec", local.legacy_suffix_unique])), 0, 256)
      dashes      = true
      slug        = "dnsrec"
      min_length  = 1
      max_length  = 256
      scope       = "parent"
      regex       = "^[a-zA-Z0-9][a-zA-Z0-9-._]+$"
    }
    notification_hub_namespace = {
      name        = substr(join("-", compact([local.legacy_prefix, "dnsrec", local.legacy_suffix])), 0, 50)
      name_unique = substr(join("-", compact([local.legacy_prefix, "dnsrec", local.legacy_suffix_unique])), 0, 50)
      dashes      = true
      slug        = "dnsrec"
      min_length  = 6
      max_length  = 50
      scope       = "global"
      regex       = "^[a-zA-Z][a-zA-Z0-9-]+[a-zA-Z0-9]$"
    }
    point_to_site_vpn_gateway = {
      name        = substr(join("-", compact([local.legacy_prefix, "vpngw", local.legacy_suffix])), 0, 80)
      name_unique = substr(join("-", compact([local.legacy_prefix, "vpngw", local.legacy_suffix_unique])), 0, 80)
      dashes      = true
      slug        = "vpngw"
      min_length  = 1
      max_length  = 80
      scope       = "resourceGroup"
      regex       = "^[a-zA-Z0-9][a-zA-Z0-9-._]+[a-zA-Z0-9_]$"
    }
    policy_definition = {
      name        = substr(join("-", compact([local.legacy_prefix, "pdef", local.legacy_suffix])), 0, 128)
      name_unique = substr(join("-", compact([local.legacy_prefix, "pdef", local.legacy_suffix_unique])), 0, 128)
      dashes      = true
      slug        = "pdef"
      min_length  = 1
      max_length  = 128
      scope       = "tenant"
      regex       = "^[^<>*%&:?./+]+[^<>*%&:?./+ ]$"
    }
    postgresql_database = {
      name        = substr(join("-", compact([local.legacy_prefix, "psqldb", local.legacy_suffix])), 0, 63)
      name_unique = substr(join("-", compact([local.legacy_prefix, "psqldb", local.legacy_suffix_unique])), 0, 63)
      dashes      = true
      slug        = "psqldb"
      min_length  = 1
      max_length  = 63
      scope       = "parent"
      regex       = "^[a-zA-Z0-9-_]+$"
    }
    postgresql_firewall_rule = {
      name        = substr(join("-", compact([local.legacy_prefix, "psqlfw", local.legacy_suffix])), 0, 128)
      name_unique = substr(join("-", compact([local.legacy_prefix, "psqlfw", local.legacy_suffix_unique])), 0, 128)
      dashes      = true
      slug        = "psqlfw"
      min_length  = 1
      max_length  = 128
      scope       = "parent"
      regex       = "^[a-zA-Z0-9-_]+$"
    }
    postgresql_server = {
      name        = substr(join("-", compact([local.legacy_prefix, "psql", local.legacy_suffix])), 0, 63)
      name_unique = substr(join("-", compact([local.legacy_prefix, "psql", local.legacy_suffix_unique])), 0, 63)
      dashes      = true
      slug        = "psql"
      min_length  = 3
      max_length  = 63
      scope       = "global"
      regex       = "^[a-z0-9][a-zA-Z0-9-]+[a-z0-9]$"
    }
    postgresql_virtual_network_rule = {
      name        = substr(join("-", compact([local.legacy_prefix, "psqlvn", local.legacy_suffix])), 0, 128)
      name_unique = substr(join("-", compact([local.legacy_prefix, "psqlvn", local.legacy_suffix_unique])), 0, 128)
      dashes      = true
      slug        = "psqlvn"
      min_length  = 1
      max_length  = 128
      scope       = "parent"
      regex       = "^[a-zA-Z0-9-_]+$"
    }
    powerbi_embedded = {
      name        = substr(join("-", compact([local.legacy_prefix, "pbi", local.legacy_suffix])), 0, 63)
      name_unique = substr(join("-", compact([local.legacy_prefix, "pbi", local.legacy_suffix_unique])), 0, 63)
      dashes      = true
      slug        = "pbi"
      min_length  = 3
      max_length  = 63
      scope       = "region"
      regex       = "^[a-zA-Z0-9][a-zA-Z0-9-]+$"
    }
    private_dns_a_record = {
      name        = substr(join("-", compact([local.legacy_prefix, "pdnsrec", local.legacy_suffix])), 0, 80)
      name_unique = substr(join("-", compact([local.legacy_prefix, "pdnsrec", local.legacy_suffix_unique])), 0, 80)
      dashes      = true
      slug        = "pdnsrec"
      min_length  = 1
      max_length  = 80
      scope       = "parent"
      regex       = "^[a-zA-Z0-9][a-zA-Z0-9-._]+[a-zA-Z0-9_]$"
    }
    private_dns_aaaa_record = {
      name        = substr(join("-", compact([local.legacy_prefix, "pdnsrec", local.legacy_suffix])), 0, 80)
      name_unique = substr(join("-", compact([local.legacy_prefix, "pdnsrec", local.legacy_suffix_unique])), 0, 80)
      dashes      = true
      slug        = "pdnsrec"
      min_length  = 1
      max_length  = 80
      scope       = "parent"
      regex       = "^[a-zA-Z0-9][a-zA-Z0-9-._]+[a-zA-Z0-9_]$"
    }
    private_dns_cname_record = {
      name        = substr(join("-", compact([local.legacy_prefix, "pdnsrec", local.legacy_suffix])), 0, 80)
      name_unique = substr(join("-", compact([local.legacy_prefix, "pdnsrec", local.legacy_suffix_unique])), 0, 80)
      dashes      = true
      slug        = "pdnsrec"
      min_length  = 1
      max_length  = 80
      scope       = "parent"
      regex       = "^[a-zA-Z0-9][a-zA-Z0-9-._]+[a-zA-Z0-9_]$"
    }
    private_dns_mx_record = {
      name        = substr(join("-", compact([local.legacy_prefix, "pdnsrec", local.legacy_suffix])), 0, 80)
      name_unique = substr(join("-", compact([local.legacy_prefix, "pdnsrec", local.legacy_suffix_unique])), 0, 80)
      dashes      = true
      slug        = "pdnsrec"
      min_length  = 1
      max_length  = 80
      scope       = "parent"
      regex       = "^[a-zA-Z0-9][a-zA-Z0-9-._]+[a-zA-Z0-9_]$"
    }
    private_dns_ptr_record = {
      name        = substr(join("-", compact([local.legacy_prefix, "pdnsrec", local.legacy_suffix])), 0, 80)
      name_unique = substr(join("-", compact([local.legacy_prefix, "pdnsrec", local.legacy_suffix_unique])), 0, 80)
      dashes      = true
      slug        = "pdnsrec"
      min_length  = 1
      max_length  = 80
      scope       = "parent"
      regex       = "^[a-zA-Z0-9][a-zA-Z0-9-._]+[a-zA-Z0-9_]$"
    }
    private_dns_srv_record = {
      name        = substr(join("-", compact([local.legacy_prefix, "pdnsrec", local.legacy_suffix])), 0, 80)
      name_unique = substr(join("-", compact([local.legacy_prefix, "pdnsrec", local.legacy_suffix_unique])), 0, 80)
      dashes      = true
      slug        = "pdnsrec"
      min_length  = 1
      max_length  = 80
      scope       = "parent"
      regex       = "^[a-zA-Z0-9][a-zA-Z0-9-._]+[a-zA-Z0-9_]$"
    }
    private_dns_txt_record = {
      name        = substr(join("-", compact([local.legacy_prefix, "pdnsrec", local.legacy_suffix])), 0, 80)
      name_unique = substr(join("-", compact([local.legacy_prefix, "pdnsrec", local.legacy_suffix_unique])), 0, 80)
      dashes      = true
      slug        = "pdnsrec"
      min_length  = 1
      max_length  = 80
      scope       = "parent"
      regex       = "^[a-zA-Z0-9][a-zA-Z0-9-._]+[a-zA-Z0-9_]$"
    }
    private_dns_zone = {
      name        = substr(join("-", compact([local.legacy_prefix, "pdns", local.legacy_suffix])), 0, 63)
      name_unique = substr(join("-", compact([local.legacy_prefix, "pdns", local.legacy_suffix_unique])), 0, 63)
      dashes      = true
      slug        = "pdns"
      min_length  = 1
      max_length  = 63
      scope       = "resourceGroup"
      regex       = "^[a-zA-Z0-9][a-zA-Z0-9-._]+[a-zA-Z0-9_]$"
    }
    private_dns_zone_group = {
      name        = substr(join("-", compact([local.legacy_prefix, "pdnszg", local.legacy_suffix])), 0, 80)
      name_unique = substr(join("-", compact([local.legacy_prefix, "pdnszg", local.legacy_suffix_unique])), 0, 80)
      dashes      = true
      slug        = "pdnszg"
      min_length  = 1
      max_length  = 80
      scope       = "resourceGroup"
      regex       = "^[a-zA-Z0-9][a-zA-Z0-9\\-\\._]+[a-zA-Z0-9_]$"
    }
    private_endpoint = {
      name        = substr(join("-", compact([local.legacy_prefix, "pe", local.legacy_suffix])), 0, 80)
      name_unique = substr(join("-", compact([local.legacy_prefix, "pe", local.legacy_suffix_unique])), 0, 80)
      dashes      = true
      slug        = "pe"
      min_length  = 1
      max_length  = 80
      scope       = "resourceGroup"
      regex       = "^[a-zA-Z0-9][a-zA-Z0-9\\-\\._]+[a-zA-Z0-9_]$"
    }
    private_link_service = {
      name        = substr(join("-", compact([local.legacy_prefix, "pls", local.legacy_suffix])), 0, 80)
      name_unique = substr(join("-", compact([local.legacy_prefix, "pls", local.legacy_suffix_unique])), 0, 80)
      dashes      = true
      slug        = "pls"
      min_length  = 1
      max_length  = 80
      scope       = "resourceGroup"
      regex       = "^[a-zA-Z0-9][a-zA-Z0-9-._]+[a-zA-Z0-9_]$"
    }
    private_service_connection = {
      name        = substr(join("-", compact([local.legacy_prefix, "psc", local.legacy_suffix])), 0, 80)
      name_unique = substr(join("-", compact([local.legacy_prefix, "psc", local.legacy_suffix_unique])), 0, 80)
      dashes      = true
      slug        = "psc"
      min_length  = 1
      max_length  = 80
      scope       = "resourceGroup"
      regex       = "^[a-zA-Z0-9][a-zA-Z0-9\\-\\._]+[a-zA-Z0-9_]$"
    }
    proximity_placement_group = {
      name        = substr(join("-", compact([local.legacy_prefix, "ppg", local.legacy_suffix])), 0, 80)
      name_unique = substr(join("-", compact([local.legacy_prefix, "ppg", local.legacy_suffix_unique])), 0, 80)
      dashes      = true
      slug        = "ppg"
      min_length  = 1
      max_length  = 80
      scope       = "resourceGroup"
      regex       = "^[a-zA-Z0-9][a-zA-Z0-9-._]+[a-zA-Z0-9_]$"
    }
    public_ip = {
      name        = substr(join("-", compact([local.legacy_prefix, "pip", local.legacy_suffix])), 0, 80)
      name_unique = substr(join("-", compact([local.legacy_prefix, "pip", local.legacy_suffix_unique])), 0, 80)
      dashes      = true
      slug        = "pip"
      min_length  = 1
      max_length  = 80
      scope       = "parent"
      regex       = "^[a-zA-Z0-9][a-zA-Z0-9-._]+[a-zA-Z0-9_]$"
    }
    public_ip_prefix = {
      name        = substr(join("-", compact([local.legacy_prefix, "pippf", local.legacy_suffix])), 0, 80)
      name_unique = substr(join("-", compact([local.legacy_prefix, "pippf", local.legacy_suffix_unique])), 0, 80)
      dashes      = true
      slug        = "pippf"
      min_length  = 1
      max_length  = 80
      scope       = "parent"
      regex       = "^[a-zA-Z0-9][a-zA-Z0-9-._]+[a-zA-Z0-9_]$"
    }
    purview_account = {
      name        = substr(join("-", compact([local.legacy_prefix, "pview", local.legacy_suffix])), 0, 63)
      name_unique = substr(join("-", compact([local.legacy_prefix, "pview", local.legacy_suffix_unique])), 0, 63)
      dashes      = true
      slug        = "pview"
      min_length  = 3
      max_length  = 63
      scope       = "global"
      regex       = "^[a-zA-Z0-9][a-zA-Z0-9-]+[a-zA-Z0-9]$"
    }
    recovery_services_vault = {
      name        = substr(join("-", compact([local.legacy_prefix, "rsv", local.legacy_suffix])), 0, 50)
      name_unique = substr(join("-", compact([local.legacy_prefix, "rsv", local.legacy_suffix_unique])), 0, 50)
      dashes      = true
      slug        = "rsv"
      min_length  = 2
      max_length  = 50
      scope       = "global"
      regex       = "^[a-zA-Z][a-zA-Z0-9-]+[a-zA-Z0-9]$"
    }
    redhat_openshift_cluster = {
      name        = substr(join("-", compact([local.legacy_prefix, "aro", local.legacy_suffix])), 0, 63)
      name_unique = substr(join("-", compact([local.legacy_prefix, "aro", local.legacy_suffix_unique])), 0, 63)
      dashes      = true
      slug        = "aro"
      min_length  = 1
      max_length  = 63
      scope       = "resourceGroup"
      regex       = "^[a-zA-Z0-9][a-zA-Z0-9-_.]+[a-zA-Z0-9]$"
    }
    redis_cache = {
      name        = substr(join("-", compact([local.legacy_prefix, "redis", local.legacy_suffix])), 0, 63)
      name_unique = substr(join("-", compact([local.legacy_prefix, "redis", local.legacy_suffix_unique])), 0, 63)
      dashes      = true
      slug        = "redis"
      min_length  = 1
      max_length  = 63
      scope       = "global"
      regex       = "^[a-zA-Z0-9][a-zA-Z0-9-]+[a-zA-Z0-9]$"
    }
    redis_firewall_rule = {
      name        = substr(join("", compact([local.legacy_prefix_safe, "redisfw", local.legacy_suffix_safe])), 0, 256)
      name_unique = substr(join("", compact([local.legacy_prefix_safe, "redisfw", local.legacy_suffix_unique_safe])), 0, 256)
      dashes      = false
      slug        = "redisfw"
      min_length  = 1
      max_length  = 256
      scope       = "parent"
      regex       = "^[a-zA-Z0-9]+$"
    }
    relay_hybrid_connection = {
      name        = substr(join("-", compact([local.legacy_prefix, "rlhc", local.legacy_suffix])), 0, 260)
      name_unique = substr(join("-", compact([local.legacy_prefix, "rlhc", local.legacy_suffix_unique])), 0, 260)
      dashes      = true
      slug        = "rlhc"
      min_length  = 1
      max_length  = 260
      scope       = "parent"
      regex       = "^[a-zA-Z0-9][a-zA-Z0-9-._]+[a-zA-Z0-9]$"
    }
    relay_namespace = {
      name        = substr(join("-", compact([local.legacy_prefix, "rln", local.legacy_suffix])), 0, 50)
      name_unique = substr(join("-", compact([local.legacy_prefix, "rln", local.legacy_suffix_unique])), 0, 50)
      dashes      = true
      slug        = "rln"
      min_length  = 6
      max_length  = 50
      scope       = "global"
      regex       = "^[a-zA-Z][a-zA-Z0-9-]+[a-zA-Z0-9]$"
    }
    resource_group = {
      name        = substr(join("-", compact([local.legacy_prefix, "rg", local.legacy_suffix])), 0, 90)
      name_unique = substr(join("-", compact([local.legacy_prefix, "rg", local.legacy_suffix_unique])), 0, 90)
      dashes      = true
      slug        = "rg"
      min_length  = 1
      max_length  = 90
      scope       = "subscription"
      regex       = "^[a-zA-Z0-9-._\\(\\)]+[a-zA-Z0-9-_\\(\\)]$"
    }
    resource_group_template_deployment = {
      name        = substr(join("-", compact([local.legacy_prefix, "ts", local.legacy_suffix])), 0, 90)
      name_unique = substr(join("-", compact([local.legacy_prefix, "ts", local.legacy_suffix_unique])), 0, 90)
      dashes      = true
      slug        = "ts"
      min_length  = 1
      max_length  = 90
      scope       = "resourceGroup"
      regex       = "^[a-zA-Z0-9-._()]+$"
    }
    role_assignment = {
      name        = substr(join("-", compact([local.legacy_prefix, "ra", local.legacy_suffix])), 0, 64)
      name_unique = substr(join("-", compact([local.legacy_prefix, "ra", local.legacy_suffix_unique])), 0, 64)
      dashes      = true
      slug        = "ra"
      min_length  = 1
      max_length  = 64
      scope       = "assignment"
      regex       = "^[^%]+[^ %.]$"
    }
    role_definition = {
      name        = substr(join("-", compact([local.legacy_prefix, "rd", local.legacy_suffix])), 0, 64)
      name_unique = substr(join("-", compact([local.legacy_prefix, "rd", local.legacy_suffix_unique])), 0, 64)
      dashes      = true
      slug        = "rd"
      min_length  = 1
      max_length  = 64
      scope       = "definition"
      regex       = "^[^%]+[^ %.]$"
    }
    route = {
      name        = substr(join("-", compact([local.legacy_prefix, "rt", local.legacy_suffix])), 0, 80)
      name_unique = substr(join("-", compact([local.legacy_prefix, "rt", local.legacy_suffix_unique])), 0, 80)
      dashes      = true
      slug        = "rt"
      min_length  = 1
      max_length  = 80
      scope       = "parent"
      regex       = "^[a-zA-Z0-9][a-zA-Z0-9-._]+[a-zA-Z0-9_]$"
    }
    route_filter = {
      name        = substr(join("-", compact([local.legacy_prefix, "rf", local.legacy_suffix])), 0, 80)
      name_unique = substr(join("-", compact([local.legacy_prefix, "rf", local.legacy_suffix_unique])), 0, 80)
      dashes      = true
      slug        = "rf"
      min_length  = 1
      max_length  = 80
      scope       = "resourceGroup"
      regex       = "^[a-zA-Z0-9][a-zA-Z0-9-._]+[a-zA-Z0-9_]$"
    }
    route_server = {
      name        = substr(join("-", compact([local.legacy_prefix, "rtserv", local.legacy_suffix])), 0, 80)
      name_unique = substr(join("-", compact([local.legacy_prefix, "rtserv", local.legacy_suffix_unique])), 0, 80)
      dashes      = true
      slug        = "rtserv"
      min_length  = 1
      max_length  = 80
      scope       = "resourceGroup"
      regex       = "^[a-zA-Z0-9][a-zA-Z0-9-._]+[a-zA-Z0-9_]$"
    }
    route_table = {
      name        = substr(join("-", compact([local.legacy_prefix, "route", local.legacy_suffix])), 0, 80)
      name_unique = substr(join("-", compact([local.legacy_prefix, "route", local.legacy_suffix_unique])), 0, 80)
      dashes      = true
      slug        = "route"
      min_length  = 1
      max_length  = 80
      scope       = "resourceGroup"
      regex       = "^[a-zA-Z0-9][a-zA-Z0-9-._]+[a-zA-Z0-9_]$"
    }
    search_service = {
      name        = substr(join("-", compact([local.legacy_prefix, "srch", local.legacy_suffix])), 0, 64)
      name_unique = substr(join("-", compact([local.legacy_prefix, "srch", local.legacy_suffix_unique])), 0, 64)
      dashes      = true
      slug        = "srch"
      min_length  = 2
      max_length  = 64
      scope       = "global"
      regex       = "^[a-zA-Z0-9][a-zA-Z0-9-]+$"
    }
    service_fabric_cluster = {
      name        = substr(join("-", compact([local.legacy_prefix, "sf", local.legacy_suffix])), 0, 23)
      name_unique = substr(join("-", compact([local.legacy_prefix, "sf", local.legacy_suffix_unique])), 0, 23)
      dashes      = true
      slug        = "sf"
      min_length  = 4
      max_length  = 23
      scope       = "region"
      regex       = "^[a-z][a-z0-9-]+[a-z0-9]$"
    }
    servicebus_namespace = {
      name        = substr(join("-", compact([local.legacy_prefix, "sb", local.legacy_suffix])), 0, 50)
      name_unique = substr(join("-", compact([local.legacy_prefix, "sb", local.legacy_suffix_unique])), 0, 50)
      dashes      = true
      slug        = "sb"
      min_length  = 6
      max_length  = 50
      scope       = "global"
      regex       = "^[a-zA-Z][a-zA-Z0-9-]+[a-zA-Z0-9]$"
    }
    servicebus_namespace_authorization_rule = {
      name        = substr(join("-", compact([local.legacy_prefix, "sbar", local.legacy_suffix])), 0, 50)
      name_unique = substr(join("-", compact([local.legacy_prefix, "sbar", local.legacy_suffix_unique])), 0, 50)
      dashes      = true
      slug        = "sbar"
      min_length  = 1
      max_length  = 50
      scope       = "parent"
      regex       = "^[a-zA-Z0-9][a-zA-Z0-9-._]+[a-zA-Z0-9]$"
    }
    servicebus_queue = {
      name        = substr(join("-", compact([local.legacy_prefix, "sbq", local.legacy_suffix])), 0, 260)
      name_unique = substr(join("-", compact([local.legacy_prefix, "sbq", local.legacy_suffix_unique])), 0, 260)
      dashes      = true
      slug        = "sbq"
      min_length  = 1
      max_length  = 260
      scope       = "parent"
      regex       = "^[a-zA-Z0-9][a-zA-Z0-9-._]+[a-zA-Z0-9_]$"
    }
    servicebus_queue_authorization_rule = {
      name        = substr(join("-", compact([local.legacy_prefix, "sbqar", local.legacy_suffix])), 0, 50)
      name_unique = substr(join("-", compact([local.legacy_prefix, "sbqar", local.legacy_suffix_unique])), 0, 50)
      dashes      = true
      slug        = "sbqar"
      min_length  = 1
      max_length  = 50
      scope       = "parent"
      regex       = "^[a-zA-Z0-9][a-zA-Z0-9-._]+[a-zA-Z0-9]$"
    }
    servicebus_subscription = {
      name        = substr(join("-", compact([local.legacy_prefix, "sbs", local.legacy_suffix])), 0, 50)
      name_unique = substr(join("-", compact([local.legacy_prefix, "sbs", local.legacy_suffix_unique])), 0, 50)
      dashes      = true
      slug        = "sbs"
      min_length  = 1
      max_length  = 50
      scope       = "parent"
      regex       = "^[a-zA-Z0-9][a-zA-Z0-9-._]+[a-zA-Z0-9]$"
    }
    servicebus_subscription_rule = {
      name        = substr(join("-", compact([local.legacy_prefix, "sbsr", local.legacy_suffix])), 0, 50)
      name_unique = substr(join("-", compact([local.legacy_prefix, "sbsr", local.legacy_suffix_unique])), 0, 50)
      dashes      = true
      slug        = "sbsr"
      min_length  = 1
      max_length  = 50
      scope       = "parent"
      regex       = "^[a-zA-Z0-9][a-zA-Z0-9-._]+[a-zA-Z0-9]$"
    }
    servicebus_topic = {
      name        = substr(join("-", compact([local.legacy_prefix, "sbt", local.legacy_suffix])), 0, 260)
      name_unique = substr(join("-", compact([local.legacy_prefix, "sbt", local.legacy_suffix_unique])), 0, 260)
      dashes      = true
      slug        = "sbt"
      min_length  = 1
      max_length  = 260
      scope       = "parent"
      regex       = "^[a-zA-Z0-9][a-zA-Z0-9-._]+[a-zA-Z0-9]$"
    }
    servicebus_topic_authorization_rule = {
      name        = substr(join("-", compact([local.legacy_prefix, "dnsrec", local.legacy_suffix])), 0, 50)
      name_unique = substr(join("-", compact([local.legacy_prefix, "dnsrec", local.legacy_suffix_unique])), 0, 50)
      dashes      = true
      slug        = "dnsrec"
      min_length  = 1
      max_length  = 50
      scope       = "parent"
      regex       = "^[a-zA-Z0-9][a-zA-Z0-9-._]+[a-zA-Z0-9]$"
    }
    shared_image = {
      name        = substr(join("-", compact([local.legacy_prefix, "si", local.legacy_suffix])), 0, 80)
      name_unique = substr(join("-", compact([local.legacy_prefix, "si", local.legacy_suffix_unique])), 0, 80)
      dashes      = true
      slug        = "si"
      min_length  = 1
      max_length  = 80
      scope       = "parent"
      regex       = "^[a-zA-Z0-9][a-zA-Z0-9-._]+[a-zA-Z0-9]$"
    }
    shared_image_gallery = {
      name        = substr(join("", compact([local.legacy_prefix_safe, "sig", local.legacy_suffix_safe])), 0, 80)
      name_unique = substr(join("", compact([local.legacy_prefix_safe, "sig", local.legacy_suffix_unique_safe])), 0, 80)
      dashes      = false
      slug        = "sig"
      min_length  = 1
      max_length  = 80
      scope       = "resourceGroup"
      regex       = "^[a-zA-Z0-9][a-zA-Z0-9.]+[a-zA-Z0-9]$"
    }
    signalr_service = {
      name        = substr(join("-", compact([local.legacy_prefix, "sgnlr", local.legacy_suffix])), 0, 63)
      name_unique = substr(join("-", compact([local.legacy_prefix, "sgnlr", local.legacy_suffix_unique])), 0, 63)
      dashes      = true
      slug        = "sgnlr"
      min_length  = 3
      max_length  = 63
      scope       = "global"
      regex       = "^[a-zA-Z0-9][a-zA-Z0-9-]+[a-zA-Z0-9]$"
    }
    snapshots = {
      name        = substr(join("-", compact([local.legacy_prefix, "snap", local.legacy_suffix])), 0, 80)
      name_unique = substr(join("-", compact([local.legacy_prefix, "snap", local.legacy_suffix_unique])), 0, 80)
      dashes      = true
      slug        = "snap"
      min_length  = 1
      max_length  = 80
      scope       = "parent"
      regex       = "^[a-zA-Z0-9][a-zA-Z0-9-._]+[a-zA-Z0-9_]$"
    }
    sql_elasticpool = {
      name        = substr(join("-", compact([local.legacy_prefix, "sqlep", local.legacy_suffix])), 0, 128)
      name_unique = substr(join("-", compact([local.legacy_prefix, "sqlep", local.legacy_suffix_unique])), 0, 128)
      dashes      = true
      slug        = "sqlep"
      min_length  = 1
      max_length  = 128
      scope       = "parent"
      regex       = "^[^<>*%:.?\\+\\/]+[^<>*%:.?\\+\\/ ]$"
    }
    sql_failover_group = {
      name        = substr(join("-", compact([local.legacy_prefix, "sqlfg", local.legacy_suffix])), 0, 63)
      name_unique = substr(join("-", compact([local.legacy_prefix, "sqlfg", local.legacy_suffix_unique])), 0, 63)
      dashes      = true
      slug        = "sqlfg"
      min_length  = 1
      max_length  = 63
      scope       = "global"
      regex       = "^[a-z0-9][a-z0-9-]+[a-z0-9]$"
    }
    sql_firewall_rule = {
      name        = substr(join("-", compact([local.legacy_prefix, "sqlfw", local.legacy_suffix])), 0, 128)
      name_unique = substr(join("-", compact([local.legacy_prefix, "sqlfw", local.legacy_suffix_unique])), 0, 128)
      dashes      = true
      slug        = "sqlfw"
      min_length  = 1
      max_length  = 128
      scope       = "parent"
      regex       = "^[^<>*%:?\\+\\/]+[^<>*%:.?\\+\\/]$"
    }
    sql_server = {
      name        = substr(join("-", compact([local.legacy_prefix, "sql", local.legacy_suffix])), 0, 63)
      name_unique = substr(join("-", compact([local.legacy_prefix, "sql", local.legacy_suffix_unique])), 0, 63)
      dashes      = true
      slug        = "sql"
      min_length  = 1
      max_length  = 63
      scope       = "global"
      regex       = "^[a-z0-9][a-z0-9-]+[a-z0-9]$"
    }
    ssh_public_key = {
      name        = substr(join("-", compact([local.legacy_prefix, "sshkey", local.legacy_suffix])), 0, 80)
      name_unique = substr(join("-", compact([local.legacy_prefix, "sshkey", local.legacy_suffix_unique])), 0, 80)
      dashes      = true
      slug        = "sshkey"
      min_length  = 1
      max_length  = 80
      scope       = "resourceGroup"
      regex       = "^[a-zA-Z0-9][a-zA-Z0-9-._]+[a-zA-Z0-9_]$"
    }
    static_web_app = {
      name        = substr(join("-", compact([local.legacy_prefix, "stapp", local.legacy_suffix])), 0, 40)
      name_unique = substr(join("-", compact([local.legacy_prefix, "stapp", local.legacy_suffix_unique])), 0, 40)
      dashes      = true
      slug        = "stapp"
      min_length  = 1
      max_length  = 40
      scope       = "resourceGroup"
      regex       = "^[a-zA-Z0-9][a-zA-Z0-9-]+[a-zA-Z0-9]$"
    }
    storage_account = {
      name        = substr(join("", compact([local.legacy_prefix_safe, "st", local.legacy_suffix_safe])), 0, 24)
      name_unique = substr(join("", compact([local.legacy_prefix_safe, "st", local.legacy_suffix_unique_safe])), 0, 24)
      dashes      = false
      slug        = "st"
      min_length  = 3
      max_length  = 24
      scope       = "global"
      regex       = "^[a-z0-9]+$"
    }
    storage_blob = {
      name        = substr(join("-", compact([local.legacy_prefix, "blob", local.legacy_suffix])), 0, 1024)
      name_unique = substr(join("-", compact([local.legacy_prefix, "blob", local.legacy_suffix_unique])), 0, 1024)
      dashes      = true
      slug        = "blob"
      min_length  = 1
      max_length  = 1024
      scope       = "parent"
      regex       = "^[^\\s\\/$#&]+$"
    }
    storage_container = {
      name        = substr(join("-", compact([local.legacy_prefix, "stct", local.legacy_suffix])), 0, 63)
      name_unique = substr(join("-", compact([local.legacy_prefix, "stct", local.legacy_suffix_unique])), 0, 63)
      dashes      = true
      slug        = "stct"
      min_length  = 3
      max_length  = 63
      scope       = "parent"
      regex       = "^[a-z0-9][a-z0-9-]+$"
    }
    storage_data_lake_gen2_filesystem = {
      name        = substr(join("-", compact([local.legacy_prefix, "stdl", local.legacy_suffix])), 0, 63)
      name_unique = substr(join("-", compact([local.legacy_prefix, "stdl", local.legacy_suffix_unique])), 0, 63)
      dashes      = true
      slug        = "stdl"
      min_length  = 3
      max_length  = 63
      scope       = "parent"
      regex       = "^[a-z0-9][a-z0-9-]+[a-z0-9]$"
    }
    storage_queue = {
      name        = substr(join("-", compact([local.legacy_prefix, "stq", local.legacy_suffix])), 0, 63)
      name_unique = substr(join("-", compact([local.legacy_prefix, "stq", local.legacy_suffix_unique])), 0, 63)
      dashes      = true
      slug        = "stq"
      min_length  = 3
      max_length  = 63
      scope       = "parent"
      regex       = "^[a-z0-9][a-z0-9-]+[a-z0-9]$"
    }
    storage_share = {
      name        = substr(join("-", compact([local.legacy_prefix, "sts", local.legacy_suffix])), 0, 63)
      name_unique = substr(join("-", compact([local.legacy_prefix, "sts", local.legacy_suffix_unique])), 0, 63)
      dashes      = true
      slug        = "sts"
      min_length  = 3
      max_length  = 63
      scope       = "parent"
      regex       = "^[a-z0-9][a-z0-9-]+[a-z0-9]$"
    }
    storage_share_directory = {
      name        = substr(join("-", compact([local.legacy_prefix, "sts", local.legacy_suffix])), 0, 63)
      name_unique = substr(join("-", compact([local.legacy_prefix, "sts", local.legacy_suffix_unique])), 0, 63)
      dashes      = true
      slug        = "sts"
      min_length  = 3
      max_length  = 63
      scope       = "parent"
      regex       = "^[a-z0-9][a-z0-9-]+[a-z0-9]$"
    }
    storage_table = {
      name        = substr(join("-", compact([local.legacy_prefix, "stt", local.legacy_suffix])), 0, 63)
      name_unique = substr(join("-", compact([local.legacy_prefix, "stt", local.legacy_suffix_unique])), 0, 63)
      dashes      = true
      slug        = "stt"
      min_length  = 3
      max_length  = 63
      scope       = "parent"
      regex       = "^[a-z0-9][a-z0-9-]+[a-z0-9]$"
    }
    stream_analytics_function_javascript_udf = {
      name        = substr(join("-", compact([local.legacy_prefix, "asafunc", local.legacy_suffix])), 0, 63)
      name_unique = substr(join("-", compact([local.legacy_prefix, "asafunc", local.legacy_suffix_unique])), 0, 63)
      dashes      = true
      slug        = "asafunc"
      min_length  = 3
      max_length  = 63
      scope       = "parent"
      regex       = "^[a-zA-Z0-9-_]+$"
    }
    stream_analytics_job = {
      name        = substr(join("-", compact([local.legacy_prefix, "asa", local.legacy_suffix])), 0, 63)
      name_unique = substr(join("-", compact([local.legacy_prefix, "asa", local.legacy_suffix_unique])), 0, 63)
      dashes      = true
      slug        = "asa"
      min_length  = 3
      max_length  = 63
      scope       = "resourceGroup"
      regex       = "^[a-zA-Z0-9-_]+$"
    }
    stream_analytics_output_blob = {
      name        = substr(join("-", compact([local.legacy_prefix, "asaoblob", local.legacy_suffix])), 0, 63)
      name_unique = substr(join("-", compact([local.legacy_prefix, "asaoblob", local.legacy_suffix_unique])), 0, 63)
      dashes      = true
      slug        = "asaoblob"
      min_length  = 3
      max_length  = 63
      scope       = "parent"
      regex       = "^[a-zA-Z0-9-_]+$"
    }
    stream_analytics_output_eventhub = {
      name        = substr(join("-", compact([local.legacy_prefix, "asaoeh", local.legacy_suffix])), 0, 63)
      name_unique = substr(join("-", compact([local.legacy_prefix, "asaoeh", local.legacy_suffix_unique])), 0, 63)
      dashes      = true
      slug        = "asaoeh"
      min_length  = 3
      max_length  = 63
      scope       = "parent"
      regex       = "^[a-zA-Z0-9-_]+$"
    }
    stream_analytics_output_mssql = {
      name        = substr(join("-", compact([local.legacy_prefix, "asaomssql", local.legacy_suffix])), 0, 63)
      name_unique = substr(join("-", compact([local.legacy_prefix, "asaomssql", local.legacy_suffix_unique])), 0, 63)
      dashes      = true
      slug        = "asaomssql"
      min_length  = 3
      max_length  = 63
      scope       = "parent"
      regex       = "^[a-zA-Z0-9-_]+$"
    }
    stream_analytics_output_servicebus_queue = {
      name        = substr(join("-", compact([local.legacy_prefix, "asaosbq", local.legacy_suffix])), 0, 63)
      name_unique = substr(join("-", compact([local.legacy_prefix, "asaosbq", local.legacy_suffix_unique])), 0, 63)
      dashes      = true
      slug        = "asaosbq"
      min_length  = 3
      max_length  = 63
      scope       = "parent"
      regex       = "^[a-zA-Z0-9-_]+$"
    }
    stream_analytics_output_servicebus_topic = {
      name        = substr(join("-", compact([local.legacy_prefix, "asaosbt", local.legacy_suffix])), 0, 63)
      name_unique = substr(join("-", compact([local.legacy_prefix, "asaosbt", local.legacy_suffix_unique])), 0, 63)
      dashes      = true
      slug        = "asaosbt"
      min_length  = 3
      max_length  = 63
      scope       = "parent"
      regex       = "^[a-zA-Z0-9-_]+$"
    }
    stream_analytics_reference_input_blob = {
      name        = substr(join("-", compact([local.legacy_prefix, "asarblob", local.legacy_suffix])), 0, 63)
      name_unique = substr(join("-", compact([local.legacy_prefix, "asarblob", local.legacy_suffix_unique])), 0, 63)
      dashes      = true
      slug        = "asarblob"
      min_length  = 3
      max_length  = 63
      scope       = "parent"
      regex       = "^[a-zA-Z0-9-_]+$"
    }
    stream_analytics_stream_input_blob = {
      name        = substr(join("-", compact([local.legacy_prefix, "asaiblob", local.legacy_suffix])), 0, 63)
      name_unique = substr(join("-", compact([local.legacy_prefix, "asaiblob", local.legacy_suffix_unique])), 0, 63)
      dashes      = true
      slug        = "asaiblob"
      min_length  = 3
      max_length  = 63
      scope       = "parent"
      regex       = "^[a-zA-Z0-9-_]+$"
    }
    stream_analytics_stream_input_eventhub = {
      name        = substr(join("-", compact([local.legacy_prefix, "asaieh", local.legacy_suffix])), 0, 63)
      name_unique = substr(join("-", compact([local.legacy_prefix, "asaieh", local.legacy_suffix_unique])), 0, 63)
      dashes      = true
      slug        = "asaieh"
      min_length  = 3
      max_length  = 63
      scope       = "parent"
      regex       = "^[a-zA-Z0-9-_]+$"
    }
    stream_analytics_stream_input_iothub = {
      name        = substr(join("-", compact([local.legacy_prefix, "asaiiot", local.legacy_suffix])), 0, 63)
      name_unique = substr(join("-", compact([local.legacy_prefix, "asaiiot", local.legacy_suffix_unique])), 0, 63)
      dashes      = true
      slug        = "asaiiot"
      min_length  = 3
      max_length  = 63
      scope       = "parent"
      regex       = "^[a-zA-Z0-9-_]+$"
    }
    subnet = {
      name        = substr(join("-", compact([local.legacy_prefix, "snet", local.legacy_suffix])), 0, 80)
      name_unique = substr(join("-", compact([local.legacy_prefix, "snet", local.legacy_suffix_unique])), 0, 80)
      dashes      = true
      slug        = "snet"
      min_length  = 1
      max_length  = 80
      scope       = "parent"
      regex       = "^[a-zA-Z0-9][a-zA-Z0-9-._]+[a-zA-Z0-9_]$"
    }
    subnet_service_endpoint_storage_policy = {
      name        = substr(join("-", compact([local.legacy_prefix, "se", local.legacy_suffix])), 0, 80)
      name_unique = substr(join("-", compact([local.legacy_prefix, "se", local.legacy_suffix_unique])), 0, 80)
      dashes      = true
      slug        = "se"
      min_length  = 1
      max_length  = 80
      scope       = "resourceGroup"
      regex       = "^[a-zA-Z0-9][a-zA-Z0-9-._]+[a-zA-Z0-9_]$"
    }
    synapse_private_link_hub = {
      name        = substr(join("-", compact([local.legacy_prefix, "synplh", local.legacy_suffix])), 0, 50)
      name_unique = substr(join("-", compact([local.legacy_prefix, "synplh", local.legacy_suffix_unique])), 0, 50)
      dashes      = true
      slug        = "synplh"
      min_length  = 1
      max_length  = 50
      scope       = "resourceGroup"
      regex       = "^[a-z0-9][a-z0-9-]+[a-z0-9]$"
    }
    synapse_spark_pool = {
      name        = substr(join("", compact([local.legacy_prefix_safe, "synsp", local.legacy_suffix_safe])), 0, 32)
      name_unique = substr(join("", compact([local.legacy_prefix_safe, "synsp", local.legacy_suffix_unique_safe])), 0, 32)
      dashes      = false
      slug        = "synsp"
      min_length  = 3
      max_length  = 32
      scope       = "parent"
      regex       = "^[a-zA-Z0-9]+$"
    }
    synapse_sql_pool = {
      name        = substr(join("", compact([local.legacy_prefix_safe, "syndp", local.legacy_suffix_safe])), 0, 60)
      name_unique = substr(join("", compact([local.legacy_prefix_safe, "syndp", local.legacy_suffix_unique_safe])), 0, 60)
      dashes      = false
      slug        = "syndp"
      min_length  = 1
      max_length  = 60
      scope       = "parent"
      regex       = "^[a-zA-Z0-9]+$"
    }
    synapse_workspace = {
      name        = substr(join("-", compact([local.legacy_prefix, "synw", local.legacy_suffix])), 0, 50)
      name_unique = substr(join("-", compact([local.legacy_prefix, "synw", local.legacy_suffix_unique])), 0, 50)
      dashes      = true
      slug        = "synw"
      min_length  = 1
      max_length  = 50
      scope       = "global"
      regex       = "^[a-z0-9][a-z0-9-]+[a-z0-9]$"
    }
    template_deployment = {
      name        = substr(join("-", compact([local.legacy_prefix, "deploy", local.legacy_suffix])), 0, 64)
      name_unique = substr(join("-", compact([local.legacy_prefix, "deploy", local.legacy_suffix_unique])), 0, 64)
      dashes      = true
      slug        = "deploy"
      min_length  = 1
      max_length  = 64
      scope       = "resourceGroup"
      regex       = "^[a-zA-Z0-9-._\\(\\)]+$"
    }
    traffic_manager_profile = {
      name        = substr(join("-", compact([local.legacy_prefix, "traf", local.legacy_suffix])), 0, 63)
      name_unique = substr(join("-", compact([local.legacy_prefix, "traf", local.legacy_suffix_unique])), 0, 63)
      dashes      = true
      slug        = "traf"
      min_length  = 1
      max_length  = 63
      scope       = "global"
      regex       = "^[a-zA-Z0-9][a-zA-Z0-9-.]+[a-zA-Z0-9_]$"
    }
    user_assigned_identity = {
      name        = substr(join("-", compact([local.legacy_prefix, "uai", local.legacy_suffix])), 0, 128)
      name_unique = substr(join("-", compact([local.legacy_prefix, "uai", local.legacy_suffix_unique])), 0, 128)
      dashes      = true
      slug        = "uai"
      min_length  = 3
      max_length  = 128
      scope       = "resourceGroup"
      regex       = "^[a-zA-Z0-9-_]+$"
    }
    virtual_desktop_application_group = {
      name        = substr(join("-", compact([local.legacy_prefix, "vdag", local.legacy_suffix])), 0, 63)
      name_unique = substr(join("-", compact([local.legacy_prefix, "vdag", local.legacy_suffix_unique])), 0, 63)
      dashes      = true
      slug        = "vdag"
      min_length  = 3
      max_length  = 63
      scope       = "resourceGroup"
      regex       = "^[a-zA-Z0-9][a-zA-Z0-9-.]+[a-zA-Z0-9_]$"
    }
    virtual_desktop_host_pool = {
      name        = substr(join("-", compact([local.legacy_prefix, "vdpool", local.legacy_suffix])), 0, 63)
      name_unique = substr(join("-", compact([local.legacy_prefix, "vdpool", local.legacy_suffix_unique])), 0, 63)
      dashes      = true
      slug        = "vdpool"
      min_length  = 3
      max_length  = 63
      scope       = "resourceGroup"
      regex       = "^[a-zA-Z0-9][a-zA-Z0-9-.]+[a-zA-Z0-9_]$"
    }
    virtual_desktop_scaling_plan = {
      name        = substr(join("-", compact([local.legacy_prefix, "vdscaling", local.legacy_suffix])), 0, 63)
      name_unique = substr(join("-", compact([local.legacy_prefix, "vdscaling", local.legacy_suffix_unique])), 0, 63)
      dashes      = true
      slug        = "vdscaling"
      min_length  = 3
      max_length  = 63
      scope       = "resourceGroup"
      regex       = "^[a-zA-Z0-9][a-zA-Z0-9-.]+[a-zA-Z0-9_]$"
    }
    virtual_desktop_workspace = {
      name        = substr(join("-", compact([local.legacy_prefix, "vdws", local.legacy_suffix])), 0, 63)
      name_unique = substr(join("-", compact([local.legacy_prefix, "vdws", local.legacy_suffix_unique])), 0, 63)
      dashes      = true
      slug        = "vdws"
      min_length  = 3
      max_length  = 63
      scope       = "resourceGroup"
      regex       = "^[a-zA-Z0-9][a-zA-Z0-9-.]+[a-zA-Z0-9_]$"
    }
    virtual_hub = {
      name        = substr(join("-", compact([local.legacy_prefix, "vhub", local.legacy_suffix])), 0, 80)
      name_unique = substr(join("-", compact([local.legacy_prefix, "vhub", local.legacy_suffix_unique])), 0, 80)
      dashes      = true
      slug        = "vhub"
      min_length  = 1
      max_length  = 80
      scope       = "resourceGroup"
      regex       = "^[a-zA-Z0-9][a-zA-Z0-9-._]+[a-zA-Z0-9_]$"
    }
    virtual_machine = {
      name        = substr(join("-", compact([local.legacy_prefix, "vm", local.legacy_suffix])), 0, 15)
      name_unique = substr(join("-", compact([local.legacy_prefix, "vm", local.legacy_suffix_unique])), 0, 15)
      dashes      = true
      slug        = "vm"
      min_length  = 1
      max_length  = 15
      scope       = "resourceGroup"
      regex       = "^[^\\/\"\\[\\]:|<>+=;,?*@&_][^\\/\"\\[\\]:|<>+=;,?*@&]+[^\\/\"\\[\\]:|<>+=;,?*@&.-]$"
    }
    virtual_machine_extension = {
      name        = substr(join("-", compact([local.legacy_prefix, "vmx", local.legacy_suffix])), 0, 80)
      name_unique = substr(join("-", compact([local.legacy_prefix, "vmx", local.legacy_suffix_unique])), 0, 80)
      dashes      = true
      slug        = "vmx"
      min_length  = 1
      max_length  = 80
      scope       = "parent"
      regex       = "^[a-zA-Z0-9][a-zA-Z0-9-._]+[a-zA-Z0-9_]$"
    }
    virtual_machine_restore_point_collection = {
      name        = substr(join("-", compact([local.legacy_prefix, "rpc", local.legacy_suffix])), 0, 80)
      name_unique = substr(join("-", compact([local.legacy_prefix, "rpc", local.legacy_suffix_unique])), 0, 80)
      dashes      = true
      slug        = "rpc"
      min_length  = 1
      max_length  = 80
      scope       = "resourceGroup"
      regex       = "^[a-zA-Z0-9][a-zA-Z0-9-._]+[a-zA-Z0-9_]$"
    }
    virtual_machine_scale_set = {
      name        = substr(join("-", compact([local.legacy_prefix, "vmss", local.legacy_suffix])), 0, 15)
      name_unique = substr(join("-", compact([local.legacy_prefix, "vmss", local.legacy_suffix_unique])), 0, 15)
      dashes      = true
      slug        = "vmss"
      min_length  = 1
      max_length  = 15
      scope       = "resourceGroup"
      regex       = "^[^\\/\"\\[\\]:|<>+=;,?*@&_][^\\/\"\\[\\]:|<>+=;,?*@&]+[^\\/\"\\[\\]:|<>+=;,?*@&.-]$"
    }
    virtual_machine_scale_set_extension = {
      name        = substr(join("-", compact([local.legacy_prefix, "vmssx", local.legacy_suffix])), 0, 80)
      name_unique = substr(join("-", compact([local.legacy_prefix, "vmssx", local.legacy_suffix_unique])), 0, 80)
      dashes      = true
      slug        = "vmssx"
      min_length  = 1
      max_length  = 80
      scope       = "parent"
      regex       = "^[a-zA-Z0-9][a-zA-Z0-9-._]+[a-zA-Z0-9_]$"
    }
    virtual_network = {
      name        = substr(join("-", compact([local.legacy_prefix, "vnet", local.legacy_suffix])), 0, 64)
      name_unique = substr(join("-", compact([local.legacy_prefix, "vnet", local.legacy_suffix_unique])), 0, 64)
      dashes      = true
      slug        = "vnet"
      min_length  = 2
      max_length  = 64
      scope       = "resourceGroup"
      regex       = "^[a-zA-Z0-9][a-zA-Z0-9-._]+[a-zA-Z0-9_]$"
    }
    virtual_network_gateway = {
      name        = substr(join("-", compact([local.legacy_prefix, "vgw", local.legacy_suffix])), 0, 80)
      name_unique = substr(join("-", compact([local.legacy_prefix, "vgw", local.legacy_suffix_unique])), 0, 80)
      dashes      = true
      slug        = "vgw"
      min_length  = 1
      max_length  = 80
      scope       = "resourceGroup"
      regex       = "^[a-zA-Z0-9][a-zA-Z0-9-._]+[a-zA-Z0-9_]$"
    }
    virtual_network_gateway_connection = {
      name        = substr(join("-", compact([local.legacy_prefix, "vcn", local.legacy_suffix])), 0, 80)
      name_unique = substr(join("-", compact([local.legacy_prefix, "vcn", local.legacy_suffix_unique])), 0, 80)
      dashes      = true
      slug        = "vcn"
      min_length  = 1
      max_length  = 80
      scope       = "resourceGroup"
      regex       = "^[a-zA-Z0-9][a-zA-Z0-9-._]+[a-zA-Z0-9_]$"
    }
    virtual_network_peering = {
      name        = substr(join("-", compact([local.legacy_prefix, "vpeer", local.legacy_suffix])), 0, 80)
      name_unique = substr(join("-", compact([local.legacy_prefix, "vpeer", local.legacy_suffix_unique])), 0, 80)
      dashes      = true
      slug        = "vpeer"
      min_length  = 1
      max_length  = 80
      scope       = "parent"
      regex       = "^[a-zA-Z0-9][a-zA-Z0-9-._]+[a-zA-Z0-9_]$"
    }
    virtual_wan = {
      name        = substr(join("-", compact([local.legacy_prefix, "vwan", local.legacy_suffix])), 0, 80)
      name_unique = substr(join("-", compact([local.legacy_prefix, "vwan", local.legacy_suffix_unique])), 0, 80)
      dashes      = true
      slug        = "vwan"
      min_length  = 1
      max_length  = 80
      scope       = "parent"
      regex       = "^[a-zA-Z0-9][a-zA-Z0-9-._]+[a-zA-Z0-9_]$"
    }
    vpn_gateway = {
      name        = substr(join("-", compact([local.legacy_prefix, "vpng", local.legacy_suffix])), 0, 80)
      name_unique = substr(join("-", compact([local.legacy_prefix, "vpng", local.legacy_suffix_unique])), 0, 80)
      dashes      = true
      slug        = "vpng"
      min_length  = 1
      max_length  = 80
      scope       = "resourceGroup"
      regex       = "^[a-zA-Z0-9][a-zA-Z0-9-._]+[a-zA-Z0-9_]$"
    }
    vpn_gateway_connection = {
      name        = substr(join("-", compact([local.legacy_prefix, "vcn", local.legacy_suffix])), 0, 80)
      name_unique = substr(join("-", compact([local.legacy_prefix, "vcn", local.legacy_suffix_unique])), 0, 80)
      dashes      = true
      slug        = "vcn"
      min_length  = 1
      max_length  = 80
      scope       = "parent"
      regex       = "^[a-zA-Z0-9][a-zA-Z0-9-._]+[a-zA-Z0-9_]$"
    }
    vpn_site = {
      name        = substr(join("-", compact([local.legacy_prefix, "vst", local.legacy_suffix])), 0, 80)
      name_unique = substr(join("-", compact([local.legacy_prefix, "vst", local.legacy_suffix_unique])), 0, 80)
      dashes      = true
      slug        = "vst"
      min_length  = 1
      max_length  = 80
      scope       = "resourceGroup"
      regex       = "^[a-zA-Z0-9][a-zA-Z0-9-._]+[a-zA-Z0-9_]$"
    }
    web_application_firewall_policy = {
      name        = substr(join("-", compact([local.legacy_prefix, "waf", local.legacy_suffix])), 0, 80)
      name_unique = substr(join("-", compact([local.legacy_prefix, "waf", local.legacy_suffix_unique])), 0, 80)
      dashes      = true
      slug        = "waf"
      min_length  = 1
      max_length  = 80
      scope       = "parent"
      regex       = "^[a-zA-Z0-9][a-zA-Z0-9-._]+[a-zA-Z0-9_]$"
    }
    web_application_firewall_policy_rule_group = {
      name        = substr(join("-", compact([local.legacy_prefix, "wafrg", local.legacy_suffix])), 0, 80)
      name_unique = substr(join("-", compact([local.legacy_prefix, "wafrg", local.legacy_suffix_unique])), 0, 80)
      dashes      = true
      slug        = "wafrg"
      min_length  = 1
      max_length  = 80
      scope       = "parent"
      regex       = "^[a-zA-Z0-9][a-zA-Z0-9-._]+[a-zA-Z0-9_]$"
    }
    windows_virtual_machine = {
      name        = substr(join("-", compact([local.legacy_prefix, "vm", local.legacy_suffix])), 0, 15)
      name_unique = substr(join("-", compact([local.legacy_prefix, "vm", local.legacy_suffix_unique])), 0, 15)
      dashes      = true
      slug        = "vm"
      min_length  = 1
      max_length  = 15
      scope       = "resourceGroup"
      regex       = "^[^\\/\"\\[\\]:|<>+=;,?*@&_][^\\/\"\\[\\]:|<>+=;,?*@&]+[^\\/\"\\[\\]:|<>+=;,?*@&.-]$"
    }
    windows_virtual_machine_scale_set = {
      name        = substr(join("-", compact([local.legacy_prefix, "vmss", local.legacy_suffix])), 0, 15)
      name_unique = substr(join("-", compact([local.legacy_prefix, "vmss", local.legacy_suffix_unique])), 0, 15)
      dashes      = true
      slug        = "vmss"
      min_length  = 1
      max_length  = 15
      scope       = "resourceGroup"
      regex       = "^[^\\/\"\\[\\]:|<>+=;,?*@&_][^\\/\"\\[\\]:|<>+=;,?*@&]+[^\\/\"\\[\\]:|<>+=;,?*@&.-]$"
    }
  }
  legacy_validation = {
    analysis_services_server = {
      valid_name        = length(regexall(local.legacy_az.analysis_services_server.regex, local.legacy_az.analysis_services_server.name)) > 0 && length(local.legacy_az.analysis_services_server.name) > local.legacy_az.analysis_services_server.min_length
      valid_name_unique = length(regexall(local.legacy_az.analysis_services_server.regex, local.legacy_az.analysis_services_server.name_unique)) > 0
    }
    api_management = {
      valid_name        = length(regexall(local.legacy_az.api_management.regex, local.legacy_az.api_management.name)) > 0 && length(local.legacy_az.api_management.name) > local.legacy_az.api_management.min_length
      valid_name_unique = length(regexall(local.legacy_az.api_management.regex, local.legacy_az.api_management.name_unique)) > 0
    }
    app_configuration = {
      valid_name        = length(regexall(local.legacy_az.app_configuration.regex, local.legacy_az.app_configuration.name)) > 0 && length(local.legacy_az.app_configuration.name) > local.legacy_az.app_configuration.min_length
      valid_name_unique = length(regexall(local.legacy_az.app_configuration.regex, local.legacy_az.app_configuration.name_unique)) > 0
    }
    app_service = {
      valid_name        = length(regexall(local.legacy_az.app_service.regex, local.legacy_az.app_service.name)) > 0 && length(local.legacy_az.app_service.name) > local.legacy_az.app_service.min_length
      valid_name_unique = length(regexall(local.legacy_az.app_service.regex, local.legacy_az.app_service.name_unique)) > 0
    }
    app_service_environment = {
      valid_name        = length(regexall(local.legacy_az.app_service_environment.regex, local.legacy_az.app_service_environment.name)) > 0 && length(local.legacy_az.app_service_environment.name) > local.legacy_az.app_service_environment.min_length
      valid_name_unique = length(regexall(local.legacy_az.app_service_environment.regex, local.legacy_az.app_service_environment.name_unique)) > 0
    }
    app_service_plan = {
      valid_name        = length(regexall(local.legacy_az.app_service_plan.regex, local.legacy_az.app_service_plan.name)) > 0 && length(local.legacy_az.app_service_plan.name) > local.legacy_az.app_service_plan.min_length
      valid_name_unique = length(regexall(local.legacy_az.app_service_plan.regex, local.legacy_az.app_service_plan.name_unique)) > 0
    }
    application_gateway = {
      valid_name        = length(regexall(local.legacy_az.application_gateway.regex, local.legacy_az.application_gateway.name)) > 0 && length(local.legacy_az.application_gateway.name) > local.legacy_az.application_gateway.min_length
      valid_name_unique = length(regexall(local.legacy_az.application_gateway.regex, local.legacy_az.application_gateway.name_unique)) > 0
    }
    application_insights = {
      valid_name        = length(regexall(local.legacy_az.application_insights.regex, local.legacy_az.application_insights.name)) > 0 && length(local.legacy_az.application_insights.name) > local.legacy_az.application_insights.min_length
      valid_name_unique = length(regexall(local.legacy_az.application_insights.regex, local.legacy_az.application_insights.name_unique)) > 0
    }
    application_security_group = {
      valid_name        = length(regexall(local.legacy_az.application_security_group.regex, local.legacy_az.application_security_group.name)) > 0 && length(local.legacy_az.application_security_group.name) > local.legacy_az.application_security_group.min_length
      valid_name_unique = length(regexall(local.legacy_az.application_security_group.regex, local.legacy_az.application_security_group.name_unique)) > 0
    }
    automation_account = {
      valid_name        = length(regexall(local.legacy_az.automation_account.regex, local.legacy_az.automation_account.name)) > 0 && length(local.legacy_az.automation_account.name) > local.legacy_az.automation_account.min_length
      valid_name_unique = length(regexall(local.legacy_az.automation_account.regex, local.legacy_az.automation_account.name_unique)) > 0
    }
    automation_certificate = {
      valid_name        = length(regexall(local.legacy_az.automation_certificate.regex, local.legacy_az.automation_certificate.name)) > 0 && length(local.legacy_az.automation_certificate.name) > local.legacy_az.automation_certificate.min_length
      valid_name_unique = length(regexall(local.legacy_az.automation_certificate.regex, local.legacy_az.automation_certificate.name_unique)) > 0
    }
    automation_credential = {
      valid_name        = length(regexall(local.legacy_az.automation_credential.regex, local.legacy_az.automation_credential.name)) > 0 && length(local.legacy_az.automation_credential.name) > local.legacy_az.automation_credential.min_length
      valid_name_unique = length(regexall(local.legacy_az.automation_credential.regex, local.legacy_az.automation_credential.name_unique)) > 0
    }
    automation_runbook = {
      valid_name        = length(regexall(local.legacy_az.automation_runbook.regex, local.legacy_az.automation_runbook.name)) > 0 && length(local.legacy_az.automation_runbook.name) > local.legacy_az.automation_runbook.min_length
      valid_name_unique = length(regexall(local.legacy_az.automation_runbook.regex, local.legacy_az.automation_runbook.name_unique)) > 0
    }
    automation_schedule = {
      valid_name        = length(regexall(local.legacy_az.automation_schedule.regex, local.legacy_az.automation_schedule.name)) > 0 && length(local.legacy_az.automation_schedule.name) > local.legacy_az.automation_schedule.min_length
      valid_name_unique = length(regexall(local.legacy_az.automation_schedule.regex, local.legacy_az.automation_schedule.name_unique)) > 0
    }
    automation_variable = {
      valid_name        = length(regexall(local.legacy_az.automation_variable.regex, local.legacy_az.automation_variable.name)) > 0 && length(local.legacy_az.automation_variable.name) > local.legacy_az.automation_variable.min_length
      valid_name_unique = length(regexall(local.legacy_az.automation_variable.regex, local.legacy_az.automation_variable.name_unique)) > 0
    }
    availability_set = {
      valid_name        = length(regexall(local.legacy_az.availability_set.regex, local.legacy_az.availability_set.name)) > 0 && length(local.legacy_az.availability_set.name) > local.legacy_az.availability_set.min_length
      valid_name_unique = length(regexall(local.legacy_az.availability_set.regex, local.legacy_az.availability_set.name_unique)) > 0
    }
    backup_policy_vm = {
      valid_name        = length(regexall(local.legacy_az.backup_policy_vm.regex, local.legacy_az.backup_policy_vm.name)) > 0 && length(local.legacy_az.backup_policy_vm.name) > local.legacy_az.backup_policy_vm.min_length
      valid_name_unique = length(regexall(local.legacy_az.backup_policy_vm.regex, local.legacy_az.backup_policy_vm.name_unique)) > 0
    }
    bastion_host = {
      valid_name        = length(regexall(local.legacy_az.bastion_host.regex, local.legacy_az.bastion_host.name)) > 0 && length(local.legacy_az.bastion_host.name) > local.legacy_az.bastion_host.min_length
      valid_name_unique = length(regexall(local.legacy_az.bastion_host.regex, local.legacy_az.bastion_host.name_unique)) > 0
    }
    batch_account = {
      valid_name        = length(regexall(local.legacy_az.batch_account.regex, local.legacy_az.batch_account.name)) > 0 && length(local.legacy_az.batch_account.name) > local.legacy_az.batch_account.min_length
      valid_name_unique = length(regexall(local.legacy_az.batch_account.regex, local.legacy_az.batch_account.name_unique)) > 0
    }
    batch_application = {
      valid_name        = length(regexall(local.legacy_az.batch_application.regex, local.legacy_az.batch_application.name)) > 0 && length(local.legacy_az.batch_application.name) > local.legacy_az.batch_application.min_length
      valid_name_unique = length(regexall(local.legacy_az.batch_application.regex, local.legacy_az.batch_application.name_unique)) > 0
    }
    batch_certificate = {
      valid_name        = length(regexall(local.legacy_az.batch_certificate.regex, local.legacy_az.batch_certificate.name)) > 0 && length(local.legacy_az.batch_certificate.name) > local.legacy_az.batch_certificate.min_length
      valid_name_unique = length(regexall(local.legacy_az.batch_certificate.regex, local.legacy_az.batch_certificate.name_unique)) > 0
    }
    batch_pool = {
      valid_name        = length(regexall(local.legacy_az.batch_pool.regex, local.legacy_az.batch_pool.name)) > 0 && length(local.legacy_az.batch_pool.name) > local.legacy_az.batch_pool.min_length
      valid_name_unique = length(regexall(local.legacy_az.batch_pool.regex, local.legacy_az.batch_pool.name_unique)) > 0
    }
    bot_channel_directline = {
      valid_name        = length(regexall(local.legacy_az.bot_channel_directline.regex, local.legacy_az.bot_channel_directline.name)) > 0 && length(local.legacy_az.bot_channel_directline.name) > local.legacy_az.bot_channel_directline.min_length
      valid_name_unique = length(regexall(local.legacy_az.bot_channel_directline.regex, local.legacy_az.bot_channel_directline.name_unique)) > 0
    }
    bot_channel_email = {
      valid_name        = length(regexall(local.legacy_az.bot_channel_email.regex, local.legacy_az.bot_channel_email.name)) > 0 && length(local.legacy_az.bot_channel_email.name) > local.legacy_az.bot_channel_email.min_length
      valid_name_unique = length(regexall(local.legacy_az.bot_channel_email.regex, local.legacy_az.bot_channel_email.name_unique)) > 0
    }
    bot_channel_ms_teams = {
      valid_name        = length(regexall(local.legacy_az.bot_channel_ms_teams.regex, local.legacy_az.bot_channel_ms_teams.name)) > 0 && length(local.legacy_az.bot_channel_ms_teams.name) > local.legacy_az.bot_channel_ms_teams.min_length
      valid_name_unique = length(regexall(local.legacy_az.bot_channel_ms_teams.regex, local.legacy_az.bot_channel_ms_teams.name_unique)) > 0
    }
    bot_channel_slack = {
      valid_name        = length(regexall(local.legacy_az.bot_channel_slack.regex, local.legacy_az.bot_channel_slack.name)) > 0 && length(local.legacy_az.bot_channel_slack.name) > local.legacy_az.bot_channel_slack.min_length
      valid_name_unique = length(regexall(local.legacy_az.bot_channel_slack.regex, local.legacy_az.bot_channel_slack.name_unique)) > 0
    }
    bot_channels_registration = {
      valid_name        = length(regexall(local.legacy_az.bot_channels_registration.regex, local.legacy_az.bot_channels_registration.name)) > 0 && length(local.legacy_az.bot_channels_registration.name) > local.legacy_az.bot_channels_registration.min_length
      valid_name_unique = length(regexall(local.legacy_az.bot_channels_registration.regex, local.legacy_az.bot_channels_registration.name_unique)) > 0
    }
    bot_connection = {
      valid_name        = length(regexall(local.legacy_az.bot_connection.regex, local.legacy_az.bot_connection.name)) > 0 && length(local.legacy_az.bot_connection.name) > local.legacy_az.bot_connection.min_length
      valid_name_unique = length(regexall(local.legacy_az.bot_connection.regex, local.legacy_az.bot_connection.name_unique)) > 0
    }
    bot_web_app = {
      valid_name        = length(regexall(local.legacy_az.bot_web_app.regex, local.legacy_az.bot_web_app.name)) > 0 && length(local.legacy_az.bot_web_app.name) > local.legacy_az.bot_web_app.min_length
      valid_name_unique = length(regexall(local.legacy_az.bot_web_app.regex, local.legacy_az.bot_web_app.name_unique)) > 0
    }
    cdn_endpoint = {
      valid_name        = length(regexall(local.legacy_az.cdn_endpoint.regex, local.legacy_az.cdn_endpoint.name)) > 0 && length(local.legacy_az.cdn_endpoint.name) > local.legacy_az.cdn_endpoint.min_length
      valid_name_unique = length(regexall(local.legacy_az.cdn_endpoint.regex, local.legacy_az.cdn_endpoint.name_unique)) > 0
    }
    cdn_frontdoor_endpoint = {
      valid_name        = length(regexall(local.legacy_az.cdn_frontdoor_endpoint.regex, local.legacy_az.cdn_frontdoor_endpoint.name)) > 0 && length(local.legacy_az.cdn_frontdoor_endpoint.name) > local.legacy_az.cdn_frontdoor_endpoint.min_length
      valid_name_unique = length(regexall(local.legacy_az.cdn_frontdoor_endpoint.regex, local.legacy_az.cdn_frontdoor_endpoint.name_unique)) > 0
    }
    cdn_frontdoor_origin = {
      valid_name        = length(regexall(local.legacy_az.cdn_frontdoor_origin.regex, local.legacy_az.cdn_frontdoor_origin.name)) > 0 && length(local.legacy_az.cdn_frontdoor_origin.name) > local.legacy_az.cdn_frontdoor_origin.min_length
      valid_name_unique = length(regexall(local.legacy_az.cdn_frontdoor_origin.regex, local.legacy_az.cdn_frontdoor_origin.name_unique)) > 0
    }
    cdn_frontdoor_origin_group = {
      valid_name        = length(regexall(local.legacy_az.cdn_frontdoor_origin_group.regex, local.legacy_az.cdn_frontdoor_origin_group.name)) > 0 && length(local.legacy_az.cdn_frontdoor_origin_group.name) > local.legacy_az.cdn_frontdoor_origin_group.min_length
      valid_name_unique = length(regexall(local.legacy_az.cdn_frontdoor_origin_group.regex, local.legacy_az.cdn_frontdoor_origin_group.name_unique)) > 0
    }
    cdn_frontdoor_profile = {
      valid_name        = length(regexall(local.legacy_az.cdn_frontdoor_profile.regex, local.legacy_az.cdn_frontdoor_profile.name)) > 0 && length(local.legacy_az.cdn_frontdoor_profile.name) > local.legacy_az.cdn_frontdoor_profile.min_length
      valid_name_unique = length(regexall(local.legacy_az.cdn_frontdoor_profile.regex, local.legacy_az.cdn_frontdoor_profile.name_unique)) > 0
    }
    cdn_frontdoor_route = {
      valid_name        = length(regexall(local.legacy_az.cdn_frontdoor_route.regex, local.legacy_az.cdn_frontdoor_route.name)) > 0 && length(local.legacy_az.cdn_frontdoor_route.name) > local.legacy_az.cdn_frontdoor_route.min_length
      valid_name_unique = length(regexall(local.legacy_az.cdn_frontdoor_route.regex, local.legacy_az.cdn_frontdoor_route.name_unique)) > 0
    }
    cdn_profile = {
      valid_name        = length(regexall(local.legacy_az.cdn_profile.regex, local.legacy_az.cdn_profile.name)) > 0 && length(local.legacy_az.cdn_profile.name) > local.legacy_az.cdn_profile.min_length
      valid_name_unique = length(regexall(local.legacy_az.cdn_profile.regex, local.legacy_az.cdn_profile.name_unique)) > 0
    }
    cognitive_account = {
      valid_name        = length(regexall(local.legacy_az.cognitive_account.regex, local.legacy_az.cognitive_account.name)) > 0 && length(local.legacy_az.cognitive_account.name) > local.legacy_az.cognitive_account.min_length
      valid_name_unique = length(regexall(local.legacy_az.cognitive_account.regex, local.legacy_az.cognitive_account.name_unique)) > 0
    }
    communication_service = {
      valid_name        = length(regexall(local.legacy_az.communication_service.regex, local.legacy_az.communication_service.name)) > 0 && length(local.legacy_az.communication_service.name) > local.legacy_az.communication_service.min_length
      valid_name_unique = length(regexall(local.legacy_az.communication_service.regex, local.legacy_az.communication_service.name_unique)) > 0
    }
    container_app = {
      valid_name        = length(regexall(local.legacy_az.container_app.regex, local.legacy_az.container_app.name)) > 0 && length(local.legacy_az.container_app.name) > local.legacy_az.container_app.min_length
      valid_name_unique = length(regexall(local.legacy_az.container_app.regex, local.legacy_az.container_app.name_unique)) > 0
    }
    container_app_environment = {
      valid_name        = length(regexall(local.legacy_az.container_app_environment.regex, local.legacy_az.container_app_environment.name)) > 0 && length(local.legacy_az.container_app_environment.name) > local.legacy_az.container_app_environment.min_length
      valid_name_unique = length(regexall(local.legacy_az.container_app_environment.regex, local.legacy_az.container_app_environment.name_unique)) > 0
    }
    container_app_job = {
      valid_name        = length(regexall(local.legacy_az.container_app_job.regex, local.legacy_az.container_app_job.name)) > 0 && length(local.legacy_az.container_app_job.name) > local.legacy_az.container_app_job.min_length
      valid_name_unique = length(regexall(local.legacy_az.container_app_job.regex, local.legacy_az.container_app_job.name_unique)) > 0
    }
    container_group = {
      valid_name        = length(regexall(local.legacy_az.container_group.regex, local.legacy_az.container_group.name)) > 0 && length(local.legacy_az.container_group.name) > local.legacy_az.container_group.min_length
      valid_name_unique = length(regexall(local.legacy_az.container_group.regex, local.legacy_az.container_group.name_unique)) > 0
    }
    container_registry = {
      valid_name        = length(regexall(local.legacy_az.container_registry.regex, local.legacy_az.container_registry.name)) > 0 && length(local.legacy_az.container_registry.name) > local.legacy_az.container_registry.min_length
      valid_name_unique = length(regexall(local.legacy_az.container_registry.regex, local.legacy_az.container_registry.name_unique)) > 0
    }
    container_registry_webhook = {
      valid_name        = length(regexall(local.legacy_az.container_registry_webhook.regex, local.legacy_az.container_registry_webhook.name)) > 0 && length(local.legacy_az.container_registry_webhook.name) > local.legacy_az.container_registry_webhook.min_length
      valid_name_unique = length(regexall(local.legacy_az.container_registry_webhook.regex, local.legacy_az.container_registry_webhook.name_unique)) > 0
    }
    cosmosdb_account = {
      valid_name        = length(regexall(local.legacy_az.cosmosdb_account.regex, local.legacy_az.cosmosdb_account.name)) > 0 && length(local.legacy_az.cosmosdb_account.name) > local.legacy_az.cosmosdb_account.min_length
      valid_name_unique = length(regexall(local.legacy_az.cosmosdb_account.regex, local.legacy_az.cosmosdb_account.name_unique)) > 0
    }
    cosmosdb_cassandra = {
      valid_name        = length(regexall(local.legacy_az.cosmosdb_cassandra.regex, local.legacy_az.cosmosdb_cassandra.name)) > 0 && length(local.legacy_az.cosmosdb_cassandra.name) > local.legacy_az.cosmosdb_cassandra.min_length
      valid_name_unique = length(regexall(local.legacy_az.cosmosdb_cassandra.regex, local.legacy_az.cosmosdb_cassandra.name_unique)) > 0
    }
    cosmosdb_cassandra_cluster = {
      valid_name        = length(regexall(local.legacy_az.cosmosdb_cassandra_cluster.regex, local.legacy_az.cosmosdb_cassandra_cluster.name)) > 0 && length(local.legacy_az.cosmosdb_cassandra_cluster.name) > local.legacy_az.cosmosdb_cassandra_cluster.min_length
      valid_name_unique = length(regexall(local.legacy_az.cosmosdb_cassandra_cluster.regex, local.legacy_az.cosmosdb_cassandra_cluster.name_unique)) > 0
    }
    cosmosdb_cassandra_datacenter = {
      valid_name        = length(regexall(local.legacy_az.cosmosdb_cassandra_datacenter.regex, local.legacy_az.cosmosdb_cassandra_datacenter.name)) > 0 && length(local.legacy_az.cosmosdb_cassandra_datacenter.name) > local.legacy_az.cosmosdb_cassandra_datacenter.min_length
      valid_name_unique = length(regexall(local.legacy_az.cosmosdb_cassandra_datacenter.regex, local.legacy_az.cosmosdb_cassandra_datacenter.name_unique)) > 0
    }
    cosmosdb_gremlin = {
      valid_name        = length(regexall(local.legacy_az.cosmosdb_gremlin.regex, local.legacy_az.cosmosdb_gremlin.name)) > 0 && length(local.legacy_az.cosmosdb_gremlin.name) > local.legacy_az.cosmosdb_gremlin.min_length
      valid_name_unique = length(regexall(local.legacy_az.cosmosdb_gremlin.regex, local.legacy_az.cosmosdb_gremlin.name_unique)) > 0
    }
    cosmosdb_mongodb = {
      valid_name        = length(regexall(local.legacy_az.cosmosdb_mongodb.regex, local.legacy_az.cosmosdb_mongodb.name)) > 0 && length(local.legacy_az.cosmosdb_mongodb.name) > local.legacy_az.cosmosdb_mongodb.min_length
      valid_name_unique = length(regexall(local.legacy_az.cosmosdb_mongodb.regex, local.legacy_az.cosmosdb_mongodb.name_unique)) > 0
    }
    cosmosdb_nosql = {
      valid_name        = length(regexall(local.legacy_az.cosmosdb_nosql.regex, local.legacy_az.cosmosdb_nosql.name)) > 0 && length(local.legacy_az.cosmosdb_nosql.name) > local.legacy_az.cosmosdb_nosql.min_length
      valid_name_unique = length(regexall(local.legacy_az.cosmosdb_nosql.regex, local.legacy_az.cosmosdb_nosql.name_unique)) > 0
    }
    cosmosdb_postgres = {
      valid_name        = length(regexall(local.legacy_az.cosmosdb_postgres.regex, local.legacy_az.cosmosdb_postgres.name)) > 0 && length(local.legacy_az.cosmosdb_postgres.name) > local.legacy_az.cosmosdb_postgres.min_length
      valid_name_unique = length(regexall(local.legacy_az.cosmosdb_postgres.regex, local.legacy_az.cosmosdb_postgres.name_unique)) > 0
    }
    cosmosdb_tables = {
      valid_name        = length(regexall(local.legacy_az.cosmosdb_tables.regex, local.legacy_az.cosmosdb_tables.name)) > 0 && length(local.legacy_az.cosmosdb_tables.name) > local.legacy_az.cosmosdb_tables.min_length
      valid_name_unique = length(regexall(local.legacy_az.cosmosdb_tables.regex, local.legacy_az.cosmosdb_tables.name_unique)) > 0
    }
    custom_provider = {
      valid_name        = length(regexall(local.legacy_az.custom_provider.regex, local.legacy_az.custom_provider.name)) > 0 && length(local.legacy_az.custom_provider.name) > local.legacy_az.custom_provider.min_length
      valid_name_unique = length(regexall(local.legacy_az.custom_provider.regex, local.legacy_az.custom_provider.name_unique)) > 0
    }
    dashboard = {
      valid_name        = length(regexall(local.legacy_az.dashboard.regex, local.legacy_az.dashboard.name)) > 0 && length(local.legacy_az.dashboard.name) > local.legacy_az.dashboard.min_length
      valid_name_unique = length(regexall(local.legacy_az.dashboard.regex, local.legacy_az.dashboard.name_unique)) > 0
    }
    dashboard_grafana = {
      valid_name        = length(regexall(local.legacy_az.dashboard_grafana.regex, local.legacy_az.dashboard_grafana.name)) > 0 && length(local.legacy_az.dashboard_grafana.name) > local.legacy_az.dashboard_grafana.min_length
      valid_name_unique = length(regexall(local.legacy_az.dashboard_grafana.regex, local.legacy_az.dashboard_grafana.name_unique)) > 0
    }
    data_factory = {
      valid_name        = length(regexall(local.legacy_az.data_factory.regex, local.legacy_az.data_factory.name)) > 0 && length(local.legacy_az.data_factory.name) > local.legacy_az.data_factory.min_length
      valid_name_unique = length(regexall(local.legacy_az.data_factory.regex, local.legacy_az.data_factory.name_unique)) > 0
    }
    data_factory_dataset_mysql = {
      valid_name        = length(regexall(local.legacy_az.data_factory_dataset_mysql.regex, local.legacy_az.data_factory_dataset_mysql.name)) > 0 && length(local.legacy_az.data_factory_dataset_mysql.name) > local.legacy_az.data_factory_dataset_mysql.min_length
      valid_name_unique = length(regexall(local.legacy_az.data_factory_dataset_mysql.regex, local.legacy_az.data_factory_dataset_mysql.name_unique)) > 0
    }
    data_factory_dataset_postgresql = {
      valid_name        = length(regexall(local.legacy_az.data_factory_dataset_postgresql.regex, local.legacy_az.data_factory_dataset_postgresql.name)) > 0 && length(local.legacy_az.data_factory_dataset_postgresql.name) > local.legacy_az.data_factory_dataset_postgresql.min_length
      valid_name_unique = length(regexall(local.legacy_az.data_factory_dataset_postgresql.regex, local.legacy_az.data_factory_dataset_postgresql.name_unique)) > 0
    }
    data_factory_dataset_sql_server_table = {
      valid_name        = length(regexall(local.legacy_az.data_factory_dataset_sql_server_table.regex, local.legacy_az.data_factory_dataset_sql_server_table.name)) > 0 && length(local.legacy_az.data_factory_dataset_sql_server_table.name) > local.legacy_az.data_factory_dataset_sql_server_table.min_length
      valid_name_unique = length(regexall(local.legacy_az.data_factory_dataset_sql_server_table.regex, local.legacy_az.data_factory_dataset_sql_server_table.name_unique)) > 0
    }
    data_factory_integration_runtime_managed = {
      valid_name        = length(regexall(local.legacy_az.data_factory_integration_runtime_managed.regex, local.legacy_az.data_factory_integration_runtime_managed.name)) > 0 && length(local.legacy_az.data_factory_integration_runtime_managed.name) > local.legacy_az.data_factory_integration_runtime_managed.min_length
      valid_name_unique = length(regexall(local.legacy_az.data_factory_integration_runtime_managed.regex, local.legacy_az.data_factory_integration_runtime_managed.name_unique)) > 0
    }
    data_factory_linked_service_data_lake_storage_gen2 = {
      valid_name        = length(regexall(local.legacy_az.data_factory_linked_service_data_lake_storage_gen2.regex, local.legacy_az.data_factory_linked_service_data_lake_storage_gen2.name)) > 0 && length(local.legacy_az.data_factory_linked_service_data_lake_storage_gen2.name) > local.legacy_az.data_factory_linked_service_data_lake_storage_gen2.min_length
      valid_name_unique = length(regexall(local.legacy_az.data_factory_linked_service_data_lake_storage_gen2.regex, local.legacy_az.data_factory_linked_service_data_lake_storage_gen2.name_unique)) > 0
    }
    data_factory_linked_service_key_vault = {
      valid_name        = length(regexall(local.legacy_az.data_factory_linked_service_key_vault.regex, local.legacy_az.data_factory_linked_service_key_vault.name)) > 0 && length(local.legacy_az.data_factory_linked_service_key_vault.name) > local.legacy_az.data_factory_linked_service_key_vault.min_length
      valid_name_unique = length(regexall(local.legacy_az.data_factory_linked_service_key_vault.regex, local.legacy_az.data_factory_linked_service_key_vault.name_unique)) > 0
    }
    data_factory_linked_service_mysql = {
      valid_name        = length(regexall(local.legacy_az.data_factory_linked_service_mysql.regex, local.legacy_az.data_factory_linked_service_mysql.name)) > 0 && length(local.legacy_az.data_factory_linked_service_mysql.name) > local.legacy_az.data_factory_linked_service_mysql.min_length
      valid_name_unique = length(regexall(local.legacy_az.data_factory_linked_service_mysql.regex, local.legacy_az.data_factory_linked_service_mysql.name_unique)) > 0
    }
    data_factory_linked_service_postgresql = {
      valid_name        = length(regexall(local.legacy_az.data_factory_linked_service_postgresql.regex, local.legacy_az.data_factory_linked_service_postgresql.name)) > 0 && length(local.legacy_az.data_factory_linked_service_postgresql.name) > local.legacy_az.data_factory_linked_service_postgresql.min_length
      valid_name_unique = length(regexall(local.legacy_az.data_factory_linked_service_postgresql.regex, local.legacy_az.data_factory_linked_service_postgresql.name_unique)) > 0
    }
    data_factory_linked_service_sql_server = {
      valid_name        = length(regexall(local.legacy_az.data_factory_linked_service_sql_server.regex, local.legacy_az.data_factory_linked_service_sql_server.name)) > 0 && length(local.legacy_az.data_factory_linked_service_sql_server.name) > local.legacy_az.data_factory_linked_service_sql_server.min_length
      valid_name_unique = length(regexall(local.legacy_az.data_factory_linked_service_sql_server.regex, local.legacy_az.data_factory_linked_service_sql_server.name_unique)) > 0
    }
    data_factory_pipeline = {
      valid_name        = length(regexall(local.legacy_az.data_factory_pipeline.regex, local.legacy_az.data_factory_pipeline.name)) > 0 && length(local.legacy_az.data_factory_pipeline.name) > local.legacy_az.data_factory_pipeline.min_length
      valid_name_unique = length(regexall(local.legacy_az.data_factory_pipeline.regex, local.legacy_az.data_factory_pipeline.name_unique)) > 0
    }
    data_factory_trigger_schedule = {
      valid_name        = length(regexall(local.legacy_az.data_factory_trigger_schedule.regex, local.legacy_az.data_factory_trigger_schedule.name)) > 0 && length(local.legacy_az.data_factory_trigger_schedule.name) > local.legacy_az.data_factory_trigger_schedule.min_length
      valid_name_unique = length(regexall(local.legacy_az.data_factory_trigger_schedule.regex, local.legacy_az.data_factory_trigger_schedule.name_unique)) > 0
    }
    data_lake_analytics_account = {
      valid_name        = length(regexall(local.legacy_az.data_lake_analytics_account.regex, local.legacy_az.data_lake_analytics_account.name)) > 0 && length(local.legacy_az.data_lake_analytics_account.name) > local.legacy_az.data_lake_analytics_account.min_length
      valid_name_unique = length(regexall(local.legacy_az.data_lake_analytics_account.regex, local.legacy_az.data_lake_analytics_account.name_unique)) > 0
    }
    data_lake_analytics_firewall_rule = {
      valid_name        = length(regexall(local.legacy_az.data_lake_analytics_firewall_rule.regex, local.legacy_az.data_lake_analytics_firewall_rule.name)) > 0 && length(local.legacy_az.data_lake_analytics_firewall_rule.name) > local.legacy_az.data_lake_analytics_firewall_rule.min_length
      valid_name_unique = length(regexall(local.legacy_az.data_lake_analytics_firewall_rule.regex, local.legacy_az.data_lake_analytics_firewall_rule.name_unique)) > 0
    }
    data_lake_store = {
      valid_name        = length(regexall(local.legacy_az.data_lake_store.regex, local.legacy_az.data_lake_store.name)) > 0 && length(local.legacy_az.data_lake_store.name) > local.legacy_az.data_lake_store.min_length
      valid_name_unique = length(regexall(local.legacy_az.data_lake_store.regex, local.legacy_az.data_lake_store.name_unique)) > 0
    }
    data_lake_store_firewall_rule = {
      valid_name        = length(regexall(local.legacy_az.data_lake_store_firewall_rule.regex, local.legacy_az.data_lake_store_firewall_rule.name)) > 0 && length(local.legacy_az.data_lake_store_firewall_rule.name) > local.legacy_az.data_lake_store_firewall_rule.min_length
      valid_name_unique = length(regexall(local.legacy_az.data_lake_store_firewall_rule.regex, local.legacy_az.data_lake_store_firewall_rule.name_unique)) > 0
    }
    data_protection_backup_vault = {
      valid_name        = length(regexall(local.legacy_az.data_protection_backup_vault.regex, local.legacy_az.data_protection_backup_vault.name)) > 0 && length(local.legacy_az.data_protection_backup_vault.name) > local.legacy_az.data_protection_backup_vault.min_length
      valid_name_unique = length(regexall(local.legacy_az.data_protection_backup_vault.regex, local.legacy_az.data_protection_backup_vault.name_unique)) > 0
    }
    database_migration_project = {
      valid_name        = length(regexall(local.legacy_az.database_migration_project.regex, local.legacy_az.database_migration_project.name)) > 0 && length(local.legacy_az.database_migration_project.name) > local.legacy_az.database_migration_project.min_length
      valid_name_unique = length(regexall(local.legacy_az.database_migration_project.regex, local.legacy_az.database_migration_project.name_unique)) > 0
    }
    database_migration_service = {
      valid_name        = length(regexall(local.legacy_az.database_migration_service.regex, local.legacy_az.database_migration_service.name)) > 0 && length(local.legacy_az.database_migration_service.name) > local.legacy_az.database_migration_service.min_length
      valid_name_unique = length(regexall(local.legacy_az.database_migration_service.regex, local.legacy_az.database_migration_service.name_unique)) > 0
    }
    databricks_access_connector = {
      valid_name        = length(regexall(local.legacy_az.databricks_access_connector.regex, local.legacy_az.databricks_access_connector.name)) > 0 && length(local.legacy_az.databricks_access_connector.name) > local.legacy_az.databricks_access_connector.min_length
      valid_name_unique = length(regexall(local.legacy_az.databricks_access_connector.regex, local.legacy_az.databricks_access_connector.name_unique)) > 0
    }
    databricks_cluster = {
      valid_name        = length(regexall(local.legacy_az.databricks_cluster.regex, local.legacy_az.databricks_cluster.name)) > 0 && length(local.legacy_az.databricks_cluster.name) > local.legacy_az.databricks_cluster.min_length
      valid_name_unique = length(regexall(local.legacy_az.databricks_cluster.regex, local.legacy_az.databricks_cluster.name_unique)) > 0
    }
    databricks_high_concurrency_cluster = {
      valid_name        = length(regexall(local.legacy_az.databricks_high_concurrency_cluster.regex, local.legacy_az.databricks_high_concurrency_cluster.name)) > 0 && length(local.legacy_az.databricks_high_concurrency_cluster.name) > local.legacy_az.databricks_high_concurrency_cluster.min_length
      valid_name_unique = length(regexall(local.legacy_az.databricks_high_concurrency_cluster.regex, local.legacy_az.databricks_high_concurrency_cluster.name_unique)) > 0
    }
    databricks_standard_cluster = {
      valid_name        = length(regexall(local.legacy_az.databricks_standard_cluster.regex, local.legacy_az.databricks_standard_cluster.name)) > 0 && length(local.legacy_az.databricks_standard_cluster.name) > local.legacy_az.databricks_standard_cluster.min_length
      valid_name_unique = length(regexall(local.legacy_az.databricks_standard_cluster.regex, local.legacy_az.databricks_standard_cluster.name_unique)) > 0
    }
    databricks_workspace = {
      valid_name        = length(regexall(local.legacy_az.databricks_workspace.regex, local.legacy_az.databricks_workspace.name)) > 0 && length(local.legacy_az.databricks_workspace.name) > local.legacy_az.databricks_workspace.min_length
      valid_name_unique = length(regexall(local.legacy_az.databricks_workspace.regex, local.legacy_az.databricks_workspace.name_unique)) > 0
    }
    dev_test_lab = {
      valid_name        = length(regexall(local.legacy_az.dev_test_lab.regex, local.legacy_az.dev_test_lab.name)) > 0 && length(local.legacy_az.dev_test_lab.name) > local.legacy_az.dev_test_lab.min_length
      valid_name_unique = length(regexall(local.legacy_az.dev_test_lab.regex, local.legacy_az.dev_test_lab.name_unique)) > 0
    }
    dev_test_linux_virtual_machine = {
      valid_name        = length(regexall(local.legacy_az.dev_test_linux_virtual_machine.regex, local.legacy_az.dev_test_linux_virtual_machine.name)) > 0 && length(local.legacy_az.dev_test_linux_virtual_machine.name) > local.legacy_az.dev_test_linux_virtual_machine.min_length
      valid_name_unique = length(regexall(local.legacy_az.dev_test_linux_virtual_machine.regex, local.legacy_az.dev_test_linux_virtual_machine.name_unique)) > 0
    }
    dev_test_windows_virtual_machine = {
      valid_name        = length(regexall(local.legacy_az.dev_test_windows_virtual_machine.regex, local.legacy_az.dev_test_windows_virtual_machine.name)) > 0 && length(local.legacy_az.dev_test_windows_virtual_machine.name) > local.legacy_az.dev_test_windows_virtual_machine.min_length
      valid_name_unique = length(regexall(local.legacy_az.dev_test_windows_virtual_machine.regex, local.legacy_az.dev_test_windows_virtual_machine.name_unique)) > 0
    }
    disk_encryption_set = {
      valid_name        = length(regexall(local.legacy_az.disk_encryption_set.regex, local.legacy_az.disk_encryption_set.name)) > 0 && length(local.legacy_az.disk_encryption_set.name) > local.legacy_az.disk_encryption_set.min_length
      valid_name_unique = length(regexall(local.legacy_az.disk_encryption_set.regex, local.legacy_az.disk_encryption_set.name_unique)) > 0
    }
    dns_a_record = {
      valid_name        = length(regexall(local.legacy_az.dns_a_record.regex, local.legacy_az.dns_a_record.name)) > 0 && length(local.legacy_az.dns_a_record.name) > local.legacy_az.dns_a_record.min_length
      valid_name_unique = length(regexall(local.legacy_az.dns_a_record.regex, local.legacy_az.dns_a_record.name_unique)) > 0
    }
    dns_aaaa_record = {
      valid_name        = length(regexall(local.legacy_az.dns_aaaa_record.regex, local.legacy_az.dns_aaaa_record.name)) > 0 && length(local.legacy_az.dns_aaaa_record.name) > local.legacy_az.dns_aaaa_record.min_length
      valid_name_unique = length(regexall(local.legacy_az.dns_aaaa_record.regex, local.legacy_az.dns_aaaa_record.name_unique)) > 0
    }
    dns_caa_record = {
      valid_name        = length(regexall(local.legacy_az.dns_caa_record.regex, local.legacy_az.dns_caa_record.name)) > 0 && length(local.legacy_az.dns_caa_record.name) > local.legacy_az.dns_caa_record.min_length
      valid_name_unique = length(regexall(local.legacy_az.dns_caa_record.regex, local.legacy_az.dns_caa_record.name_unique)) > 0
    }
    dns_cname_record = {
      valid_name        = length(regexall(local.legacy_az.dns_cname_record.regex, local.legacy_az.dns_cname_record.name)) > 0 && length(local.legacy_az.dns_cname_record.name) > local.legacy_az.dns_cname_record.min_length
      valid_name_unique = length(regexall(local.legacy_az.dns_cname_record.regex, local.legacy_az.dns_cname_record.name_unique)) > 0
    }
    dns_mx_record = {
      valid_name        = length(regexall(local.legacy_az.dns_mx_record.regex, local.legacy_az.dns_mx_record.name)) > 0 && length(local.legacy_az.dns_mx_record.name) > local.legacy_az.dns_mx_record.min_length
      valid_name_unique = length(regexall(local.legacy_az.dns_mx_record.regex, local.legacy_az.dns_mx_record.name_unique)) > 0
    }
    dns_ns_record = {
      valid_name        = length(regexall(local.legacy_az.dns_ns_record.regex, local.legacy_az.dns_ns_record.name)) > 0 && length(local.legacy_az.dns_ns_record.name) > local.legacy_az.dns_ns_record.min_length
      valid_name_unique = length(regexall(local.legacy_az.dns_ns_record.regex, local.legacy_az.dns_ns_record.name_unique)) > 0
    }
    dns_private_resolver = {
      valid_name        = length(regexall(local.legacy_az.dns_private_resolver.regex, local.legacy_az.dns_private_resolver.name)) > 0 && length(local.legacy_az.dns_private_resolver.name) > local.legacy_az.dns_private_resolver.min_length
      valid_name_unique = length(regexall(local.legacy_az.dns_private_resolver.regex, local.legacy_az.dns_private_resolver.name_unique)) > 0
    }
    dns_ptr_record = {
      valid_name        = length(regexall(local.legacy_az.dns_ptr_record.regex, local.legacy_az.dns_ptr_record.name)) > 0 && length(local.legacy_az.dns_ptr_record.name) > local.legacy_az.dns_ptr_record.min_length
      valid_name_unique = length(regexall(local.legacy_az.dns_ptr_record.regex, local.legacy_az.dns_ptr_record.name_unique)) > 0
    }
    dns_txt_record = {
      valid_name        = length(regexall(local.legacy_az.dns_txt_record.regex, local.legacy_az.dns_txt_record.name)) > 0 && length(local.legacy_az.dns_txt_record.name) > local.legacy_az.dns_txt_record.min_length
      valid_name_unique = length(regexall(local.legacy_az.dns_txt_record.regex, local.legacy_az.dns_txt_record.name_unique)) > 0
    }
    dns_zone = {
      valid_name        = length(regexall(local.legacy_az.dns_zone.regex, local.legacy_az.dns_zone.name)) > 0 && length(local.legacy_az.dns_zone.name) > local.legacy_az.dns_zone.min_length
      valid_name_unique = length(regexall(local.legacy_az.dns_zone.regex, local.legacy_az.dns_zone.name_unique)) > 0
    }
    eventgrid_domain = {
      valid_name        = length(regexall(local.legacy_az.eventgrid_domain.regex, local.legacy_az.eventgrid_domain.name)) > 0 && length(local.legacy_az.eventgrid_domain.name) > local.legacy_az.eventgrid_domain.min_length
      valid_name_unique = length(regexall(local.legacy_az.eventgrid_domain.regex, local.legacy_az.eventgrid_domain.name_unique)) > 0
    }
    eventgrid_domain_topic = {
      valid_name        = length(regexall(local.legacy_az.eventgrid_domain_topic.regex, local.legacy_az.eventgrid_domain_topic.name)) > 0 && length(local.legacy_az.eventgrid_domain_topic.name) > local.legacy_az.eventgrid_domain_topic.min_length
      valid_name_unique = length(regexall(local.legacy_az.eventgrid_domain_topic.regex, local.legacy_az.eventgrid_domain_topic.name_unique)) > 0
    }
    eventgrid_event_subscription = {
      valid_name        = length(regexall(local.legacy_az.eventgrid_event_subscription.regex, local.legacy_az.eventgrid_event_subscription.name)) > 0 && length(local.legacy_az.eventgrid_event_subscription.name) > local.legacy_az.eventgrid_event_subscription.min_length
      valid_name_unique = length(regexall(local.legacy_az.eventgrid_event_subscription.regex, local.legacy_az.eventgrid_event_subscription.name_unique)) > 0
    }
    eventgrid_namespace = {
      valid_name        = length(regexall(local.legacy_az.eventgrid_namespace.regex, local.legacy_az.eventgrid_namespace.name)) > 0 && length(local.legacy_az.eventgrid_namespace.name) > local.legacy_az.eventgrid_namespace.min_length
      valid_name_unique = length(regexall(local.legacy_az.eventgrid_namespace.regex, local.legacy_az.eventgrid_namespace.name_unique)) > 0
    }
    eventgrid_system_topic = {
      valid_name        = length(regexall(local.legacy_az.eventgrid_system_topic.regex, local.legacy_az.eventgrid_system_topic.name)) > 0 && length(local.legacy_az.eventgrid_system_topic.name) > local.legacy_az.eventgrid_system_topic.min_length
      valid_name_unique = length(regexall(local.legacy_az.eventgrid_system_topic.regex, local.legacy_az.eventgrid_system_topic.name_unique)) > 0
    }
    eventgrid_topic = {
      valid_name        = length(regexall(local.legacy_az.eventgrid_topic.regex, local.legacy_az.eventgrid_topic.name)) > 0 && length(local.legacy_az.eventgrid_topic.name) > local.legacy_az.eventgrid_topic.min_length
      valid_name_unique = length(regexall(local.legacy_az.eventgrid_topic.regex, local.legacy_az.eventgrid_topic.name_unique)) > 0
    }
    eventhub = {
      valid_name        = length(regexall(local.legacy_az.eventhub.regex, local.legacy_az.eventhub.name)) > 0 && length(local.legacy_az.eventhub.name) > local.legacy_az.eventhub.min_length
      valid_name_unique = length(regexall(local.legacy_az.eventhub.regex, local.legacy_az.eventhub.name_unique)) > 0
    }
    eventhub_authorization_rule = {
      valid_name        = length(regexall(local.legacy_az.eventhub_authorization_rule.regex, local.legacy_az.eventhub_authorization_rule.name)) > 0 && length(local.legacy_az.eventhub_authorization_rule.name) > local.legacy_az.eventhub_authorization_rule.min_length
      valid_name_unique = length(regexall(local.legacy_az.eventhub_authorization_rule.regex, local.legacy_az.eventhub_authorization_rule.name_unique)) > 0
    }
    eventhub_cluster = {
      valid_name        = length(regexall(local.legacy_az.eventhub_cluster.regex, local.legacy_az.eventhub_cluster.name)) > 0 && length(local.legacy_az.eventhub_cluster.name) > local.legacy_az.eventhub_cluster.min_length
      valid_name_unique = length(regexall(local.legacy_az.eventhub_cluster.regex, local.legacy_az.eventhub_cluster.name_unique)) > 0
    }
    eventhub_consumer_group = {
      valid_name        = length(regexall(local.legacy_az.eventhub_consumer_group.regex, local.legacy_az.eventhub_consumer_group.name)) > 0 && length(local.legacy_az.eventhub_consumer_group.name) > local.legacy_az.eventhub_consumer_group.min_length
      valid_name_unique = length(regexall(local.legacy_az.eventhub_consumer_group.regex, local.legacy_az.eventhub_consumer_group.name_unique)) > 0
    }
    eventhub_namespace = {
      valid_name        = length(regexall(local.legacy_az.eventhub_namespace.regex, local.legacy_az.eventhub_namespace.name)) > 0 && length(local.legacy_az.eventhub_namespace.name) > local.legacy_az.eventhub_namespace.min_length
      valid_name_unique = length(regexall(local.legacy_az.eventhub_namespace.regex, local.legacy_az.eventhub_namespace.name_unique)) > 0
    }
    eventhub_namespace_authorization_rule = {
      valid_name        = length(regexall(local.legacy_az.eventhub_namespace_authorization_rule.regex, local.legacy_az.eventhub_namespace_authorization_rule.name)) > 0 && length(local.legacy_az.eventhub_namespace_authorization_rule.name) > local.legacy_az.eventhub_namespace_authorization_rule.min_length
      valid_name_unique = length(regexall(local.legacy_az.eventhub_namespace_authorization_rule.regex, local.legacy_az.eventhub_namespace_authorization_rule.name_unique)) > 0
    }
    eventhub_namespace_disaster_recovery_config = {
      valid_name        = length(regexall(local.legacy_az.eventhub_namespace_disaster_recovery_config.regex, local.legacy_az.eventhub_namespace_disaster_recovery_config.name)) > 0 && length(local.legacy_az.eventhub_namespace_disaster_recovery_config.name) > local.legacy_az.eventhub_namespace_disaster_recovery_config.min_length
      valid_name_unique = length(regexall(local.legacy_az.eventhub_namespace_disaster_recovery_config.regex, local.legacy_az.eventhub_namespace_disaster_recovery_config.name_unique)) > 0
    }
    express_route_circuit = {
      valid_name        = length(regexall(local.legacy_az.express_route_circuit.regex, local.legacy_az.express_route_circuit.name)) > 0 && length(local.legacy_az.express_route_circuit.name) > local.legacy_az.express_route_circuit.min_length
      valid_name_unique = length(regexall(local.legacy_az.express_route_circuit.regex, local.legacy_az.express_route_circuit.name_unique)) > 0
    }
    express_route_gateway = {
      valid_name        = length(regexall(local.legacy_az.express_route_gateway.regex, local.legacy_az.express_route_gateway.name)) > 0 && length(local.legacy_az.express_route_gateway.name) > local.legacy_az.express_route_gateway.min_length
      valid_name_unique = length(regexall(local.legacy_az.express_route_gateway.regex, local.legacy_az.express_route_gateway.name_unique)) > 0
    }
    fabric_capacity = {
      valid_name        = length(regexall(local.legacy_az.fabric_capacity.regex, local.legacy_az.fabric_capacity.name)) > 0 && length(local.legacy_az.fabric_capacity.name) > local.legacy_az.fabric_capacity.min_length
      valid_name_unique = length(regexall(local.legacy_az.fabric_capacity.regex, local.legacy_az.fabric_capacity.name_unique)) > 0
    }
    firewall = {
      valid_name        = length(regexall(local.legacy_az.firewall.regex, local.legacy_az.firewall.name)) > 0 && length(local.legacy_az.firewall.name) > local.legacy_az.firewall.min_length
      valid_name_unique = length(regexall(local.legacy_az.firewall.regex, local.legacy_az.firewall.name_unique)) > 0
    }
    firewall_application_rule_collection = {
      valid_name        = length(regexall(local.legacy_az.firewall_application_rule_collection.regex, local.legacy_az.firewall_application_rule_collection.name)) > 0 && length(local.legacy_az.firewall_application_rule_collection.name) > local.legacy_az.firewall_application_rule_collection.min_length
      valid_name_unique = length(regexall(local.legacy_az.firewall_application_rule_collection.regex, local.legacy_az.firewall_application_rule_collection.name_unique)) > 0
    }
    firewall_ip_configuration = {
      valid_name        = length(regexall(local.legacy_az.firewall_ip_configuration.regex, local.legacy_az.firewall_ip_configuration.name)) > 0 && length(local.legacy_az.firewall_ip_configuration.name) > local.legacy_az.firewall_ip_configuration.min_length
      valid_name_unique = length(regexall(local.legacy_az.firewall_ip_configuration.regex, local.legacy_az.firewall_ip_configuration.name_unique)) > 0
    }
    firewall_nat_rule_collection = {
      valid_name        = length(regexall(local.legacy_az.firewall_nat_rule_collection.regex, local.legacy_az.firewall_nat_rule_collection.name)) > 0 && length(local.legacy_az.firewall_nat_rule_collection.name) > local.legacy_az.firewall_nat_rule_collection.min_length
      valid_name_unique = length(regexall(local.legacy_az.firewall_nat_rule_collection.regex, local.legacy_az.firewall_nat_rule_collection.name_unique)) > 0
    }
    firewall_network_rule_collection = {
      valid_name        = length(regexall(local.legacy_az.firewall_network_rule_collection.regex, local.legacy_az.firewall_network_rule_collection.name)) > 0 && length(local.legacy_az.firewall_network_rule_collection.name) > local.legacy_az.firewall_network_rule_collection.min_length
      valid_name_unique = length(regexall(local.legacy_az.firewall_network_rule_collection.regex, local.legacy_az.firewall_network_rule_collection.name_unique)) > 0
    }
    firewall_policy = {
      valid_name        = length(regexall(local.legacy_az.firewall_policy.regex, local.legacy_az.firewall_policy.name)) > 0 && length(local.legacy_az.firewall_policy.name) > local.legacy_az.firewall_policy.min_length
      valid_name_unique = length(regexall(local.legacy_az.firewall_policy.regex, local.legacy_az.firewall_policy.name_unique)) > 0
    }
    firewall_policy_rule_collection_group = {
      valid_name        = length(regexall(local.legacy_az.firewall_policy_rule_collection_group.regex, local.legacy_az.firewall_policy_rule_collection_group.name)) > 0 && length(local.legacy_az.firewall_policy_rule_collection_group.name) > local.legacy_az.firewall_policy_rule_collection_group.min_length
      valid_name_unique = length(regexall(local.legacy_az.firewall_policy_rule_collection_group.regex, local.legacy_az.firewall_policy_rule_collection_group.name_unique)) > 0
    }
    frontdoor = {
      valid_name        = length(regexall(local.legacy_az.frontdoor.regex, local.legacy_az.frontdoor.name)) > 0 && length(local.legacy_az.frontdoor.name) > local.legacy_az.frontdoor.min_length
      valid_name_unique = length(regexall(local.legacy_az.frontdoor.regex, local.legacy_az.frontdoor.name_unique)) > 0
    }
    frontdoor_firewall_policy = {
      valid_name        = length(regexall(local.legacy_az.frontdoor_firewall_policy.regex, local.legacy_az.frontdoor_firewall_policy.name)) > 0 && length(local.legacy_az.frontdoor_firewall_policy.name) > local.legacy_az.frontdoor_firewall_policy.min_length
      valid_name_unique = length(regexall(local.legacy_az.frontdoor_firewall_policy.regex, local.legacy_az.frontdoor_firewall_policy.name_unique)) > 0
    }
    function_app = {
      valid_name        = length(regexall(local.legacy_az.function_app.regex, local.legacy_az.function_app.name)) > 0 && length(local.legacy_az.function_app.name) > local.legacy_az.function_app.min_length
      valid_name_unique = length(regexall(local.legacy_az.function_app.regex, local.legacy_az.function_app.name_unique)) > 0
    }
    hdinsight_hadoop_cluster = {
      valid_name        = length(regexall(local.legacy_az.hdinsight_hadoop_cluster.regex, local.legacy_az.hdinsight_hadoop_cluster.name)) > 0 && length(local.legacy_az.hdinsight_hadoop_cluster.name) > local.legacy_az.hdinsight_hadoop_cluster.min_length
      valid_name_unique = length(regexall(local.legacy_az.hdinsight_hadoop_cluster.regex, local.legacy_az.hdinsight_hadoop_cluster.name_unique)) > 0
    }
    hdinsight_hbase_cluster = {
      valid_name        = length(regexall(local.legacy_az.hdinsight_hbase_cluster.regex, local.legacy_az.hdinsight_hbase_cluster.name)) > 0 && length(local.legacy_az.hdinsight_hbase_cluster.name) > local.legacy_az.hdinsight_hbase_cluster.min_length
      valid_name_unique = length(regexall(local.legacy_az.hdinsight_hbase_cluster.regex, local.legacy_az.hdinsight_hbase_cluster.name_unique)) > 0
    }
    hdinsight_interactive_query_cluster = {
      valid_name        = length(regexall(local.legacy_az.hdinsight_interactive_query_cluster.regex, local.legacy_az.hdinsight_interactive_query_cluster.name)) > 0 && length(local.legacy_az.hdinsight_interactive_query_cluster.name) > local.legacy_az.hdinsight_interactive_query_cluster.min_length
      valid_name_unique = length(regexall(local.legacy_az.hdinsight_interactive_query_cluster.regex, local.legacy_az.hdinsight_interactive_query_cluster.name_unique)) > 0
    }
    hdinsight_kafka_cluster = {
      valid_name        = length(regexall(local.legacy_az.hdinsight_kafka_cluster.regex, local.legacy_az.hdinsight_kafka_cluster.name)) > 0 && length(local.legacy_az.hdinsight_kafka_cluster.name) > local.legacy_az.hdinsight_kafka_cluster.min_length
      valid_name_unique = length(regexall(local.legacy_az.hdinsight_kafka_cluster.regex, local.legacy_az.hdinsight_kafka_cluster.name_unique)) > 0
    }
    hdinsight_ml_services_cluster = {
      valid_name        = length(regexall(local.legacy_az.hdinsight_ml_services_cluster.regex, local.legacy_az.hdinsight_ml_services_cluster.name)) > 0 && length(local.legacy_az.hdinsight_ml_services_cluster.name) > local.legacy_az.hdinsight_ml_services_cluster.min_length
      valid_name_unique = length(regexall(local.legacy_az.hdinsight_ml_services_cluster.regex, local.legacy_az.hdinsight_ml_services_cluster.name_unique)) > 0
    }
    hdinsight_rserver_cluster = {
      valid_name        = length(regexall(local.legacy_az.hdinsight_rserver_cluster.regex, local.legacy_az.hdinsight_rserver_cluster.name)) > 0 && length(local.legacy_az.hdinsight_rserver_cluster.name) > local.legacy_az.hdinsight_rserver_cluster.min_length
      valid_name_unique = length(regexall(local.legacy_az.hdinsight_rserver_cluster.regex, local.legacy_az.hdinsight_rserver_cluster.name_unique)) > 0
    }
    hdinsight_spark_cluster = {
      valid_name        = length(regexall(local.legacy_az.hdinsight_spark_cluster.regex, local.legacy_az.hdinsight_spark_cluster.name)) > 0 && length(local.legacy_az.hdinsight_spark_cluster.name) > local.legacy_az.hdinsight_spark_cluster.min_length
      valid_name_unique = length(regexall(local.legacy_az.hdinsight_spark_cluster.regex, local.legacy_az.hdinsight_spark_cluster.name_unique)) > 0
    }
    hdinsight_storm_cluster = {
      valid_name        = length(regexall(local.legacy_az.hdinsight_storm_cluster.regex, local.legacy_az.hdinsight_storm_cluster.name)) > 0 && length(local.legacy_az.hdinsight_storm_cluster.name) > local.legacy_az.hdinsight_storm_cluster.min_length
      valid_name_unique = length(regexall(local.legacy_az.hdinsight_storm_cluster.regex, local.legacy_az.hdinsight_storm_cluster.name_unique)) > 0
    }
    image = {
      valid_name        = length(regexall(local.legacy_az.image.regex, local.legacy_az.image.name)) > 0 && length(local.legacy_az.image.name) > local.legacy_az.image.min_length
      valid_name_unique = length(regexall(local.legacy_az.image.regex, local.legacy_az.image.name_unique)) > 0
    }
    iotcentral_application = {
      valid_name        = length(regexall(local.legacy_az.iotcentral_application.regex, local.legacy_az.iotcentral_application.name)) > 0 && length(local.legacy_az.iotcentral_application.name) > local.legacy_az.iotcentral_application.min_length
      valid_name_unique = length(regexall(local.legacy_az.iotcentral_application.regex, local.legacy_az.iotcentral_application.name_unique)) > 0
    }
    iothub = {
      valid_name        = length(regexall(local.legacy_az.iothub.regex, local.legacy_az.iothub.name)) > 0 && length(local.legacy_az.iothub.name) > local.legacy_az.iothub.min_length
      valid_name_unique = length(regexall(local.legacy_az.iothub.regex, local.legacy_az.iothub.name_unique)) > 0
    }
    iothub_consumer_group = {
      valid_name        = length(regexall(local.legacy_az.iothub_consumer_group.regex, local.legacy_az.iothub_consumer_group.name)) > 0 && length(local.legacy_az.iothub_consumer_group.name) > local.legacy_az.iothub_consumer_group.min_length
      valid_name_unique = length(regexall(local.legacy_az.iothub_consumer_group.regex, local.legacy_az.iothub_consumer_group.name_unique)) > 0
    }
    iothub_dps = {
      valid_name        = length(regexall(local.legacy_az.iothub_dps.regex, local.legacy_az.iothub_dps.name)) > 0 && length(local.legacy_az.iothub_dps.name) > local.legacy_az.iothub_dps.min_length
      valid_name_unique = length(regexall(local.legacy_az.iothub_dps.regex, local.legacy_az.iothub_dps.name_unique)) > 0
    }
    iothub_dps_certificate = {
      valid_name        = length(regexall(local.legacy_az.iothub_dps_certificate.regex, local.legacy_az.iothub_dps_certificate.name)) > 0 && length(local.legacy_az.iothub_dps_certificate.name) > local.legacy_az.iothub_dps_certificate.min_length
      valid_name_unique = length(regexall(local.legacy_az.iothub_dps_certificate.regex, local.legacy_az.iothub_dps_certificate.name_unique)) > 0
    }
    ip_group = {
      valid_name        = length(regexall(local.legacy_az.ip_group.regex, local.legacy_az.ip_group.name)) > 0 && length(local.legacy_az.ip_group.name) > local.legacy_az.ip_group.min_length
      valid_name_unique = length(regexall(local.legacy_az.ip_group.regex, local.legacy_az.ip_group.name_unique)) > 0
    }
    key_vault = {
      valid_name        = length(regexall(local.legacy_az.key_vault.regex, local.legacy_az.key_vault.name)) > 0 && length(local.legacy_az.key_vault.name) > local.legacy_az.key_vault.min_length
      valid_name_unique = length(regexall(local.legacy_az.key_vault.regex, local.legacy_az.key_vault.name_unique)) > 0
    }
    key_vault_certificate = {
      valid_name        = length(regexall(local.legacy_az.key_vault_certificate.regex, local.legacy_az.key_vault_certificate.name)) > 0 && length(local.legacy_az.key_vault_certificate.name) > local.legacy_az.key_vault_certificate.min_length
      valid_name_unique = length(regexall(local.legacy_az.key_vault_certificate.regex, local.legacy_az.key_vault_certificate.name_unique)) > 0
    }
    key_vault_key = {
      valid_name        = length(regexall(local.legacy_az.key_vault_key.regex, local.legacy_az.key_vault_key.name)) > 0 && length(local.legacy_az.key_vault_key.name) > local.legacy_az.key_vault_key.min_length
      valid_name_unique = length(regexall(local.legacy_az.key_vault_key.regex, local.legacy_az.key_vault_key.name_unique)) > 0
    }
    key_vault_secret = {
      valid_name        = length(regexall(local.legacy_az.key_vault_secret.regex, local.legacy_az.key_vault_secret.name)) > 0 && length(local.legacy_az.key_vault_secret.name) > local.legacy_az.key_vault_secret.min_length
      valid_name_unique = length(regexall(local.legacy_az.key_vault_secret.regex, local.legacy_az.key_vault_secret.name_unique)) > 0
    }
    kubernetes_cluster = {
      valid_name        = length(regexall(local.legacy_az.kubernetes_cluster.regex, local.legacy_az.kubernetes_cluster.name)) > 0 && length(local.legacy_az.kubernetes_cluster.name) > local.legacy_az.kubernetes_cluster.min_length
      valid_name_unique = length(regexall(local.legacy_az.kubernetes_cluster.regex, local.legacy_az.kubernetes_cluster.name_unique)) > 0
    }
    kusto_cluster = {
      valid_name        = length(regexall(local.legacy_az.kusto_cluster.regex, local.legacy_az.kusto_cluster.name)) > 0 && length(local.legacy_az.kusto_cluster.name) > local.legacy_az.kusto_cluster.min_length
      valid_name_unique = length(regexall(local.legacy_az.kusto_cluster.regex, local.legacy_az.kusto_cluster.name_unique)) > 0
    }
    kusto_database = {
      valid_name        = length(regexall(local.legacy_az.kusto_database.regex, local.legacy_az.kusto_database.name)) > 0 && length(local.legacy_az.kusto_database.name) > local.legacy_az.kusto_database.min_length
      valid_name_unique = length(regexall(local.legacy_az.kusto_database.regex, local.legacy_az.kusto_database.name_unique)) > 0
    }
    kusto_eventhub_data_connection = {
      valid_name        = length(regexall(local.legacy_az.kusto_eventhub_data_connection.regex, local.legacy_az.kusto_eventhub_data_connection.name)) > 0 && length(local.legacy_az.kusto_eventhub_data_connection.name) > local.legacy_az.kusto_eventhub_data_connection.min_length
      valid_name_unique = length(regexall(local.legacy_az.kusto_eventhub_data_connection.regex, local.legacy_az.kusto_eventhub_data_connection.name_unique)) > 0
    }
    lb = {
      valid_name        = length(regexall(local.legacy_az.lb.regex, local.legacy_az.lb.name)) > 0 && length(local.legacy_az.lb.name) > local.legacy_az.lb.min_length
      valid_name_unique = length(regexall(local.legacy_az.lb.regex, local.legacy_az.lb.name_unique)) > 0
    }
    lb_nat_rule = {
      valid_name        = length(regexall(local.legacy_az.lb_nat_rule.regex, local.legacy_az.lb_nat_rule.name)) > 0 && length(local.legacy_az.lb_nat_rule.name) > local.legacy_az.lb_nat_rule.min_length
      valid_name_unique = length(regexall(local.legacy_az.lb_nat_rule.regex, local.legacy_az.lb_nat_rule.name_unique)) > 0
    }
    lb_rule = {
      valid_name        = length(regexall(local.legacy_az.lb_rule.regex, local.legacy_az.lb_rule.name)) > 0 && length(local.legacy_az.lb_rule.name) > local.legacy_az.lb_rule.min_length
      valid_name_unique = length(regexall(local.legacy_az.lb_rule.regex, local.legacy_az.lb_rule.name_unique)) > 0
    }
    linux_virtual_machine = {
      valid_name        = length(regexall(local.legacy_az.linux_virtual_machine.regex, local.legacy_az.linux_virtual_machine.name)) > 0 && length(local.legacy_az.linux_virtual_machine.name) > local.legacy_az.linux_virtual_machine.min_length
      valid_name_unique = length(regexall(local.legacy_az.linux_virtual_machine.regex, local.legacy_az.linux_virtual_machine.name_unique)) > 0
    }
    linux_virtual_machine_scale_set = {
      valid_name        = length(regexall(local.legacy_az.linux_virtual_machine_scale_set.regex, local.legacy_az.linux_virtual_machine_scale_set.name)) > 0 && length(local.legacy_az.linux_virtual_machine_scale_set.name) > local.legacy_az.linux_virtual_machine_scale_set.min_length
      valid_name_unique = length(regexall(local.legacy_az.linux_virtual_machine_scale_set.regex, local.legacy_az.linux_virtual_machine_scale_set.name_unique)) > 0
    }
    load_test = {
      valid_name        = length(regexall(local.legacy_az.load_test.regex, local.legacy_az.load_test.name)) > 0 && length(local.legacy_az.load_test.name) > local.legacy_az.load_test.min_length
      valid_name_unique = length(regexall(local.legacy_az.load_test.regex, local.legacy_az.load_test.name_unique)) > 0
    }
    local_network_gateway = {
      valid_name        = length(regexall(local.legacy_az.local_network_gateway.regex, local.legacy_az.local_network_gateway.name)) > 0 && length(local.legacy_az.local_network_gateway.name) > local.legacy_az.local_network_gateway.min_length
      valid_name_unique = length(regexall(local.legacy_az.local_network_gateway.regex, local.legacy_az.local_network_gateway.name_unique)) > 0
    }
    log_analytics_query_pack = {
      valid_name        = length(regexall(local.legacy_az.log_analytics_query_pack.regex, local.legacy_az.log_analytics_query_pack.name)) > 0 && length(local.legacy_az.log_analytics_query_pack.name) > local.legacy_az.log_analytics_query_pack.min_length
      valid_name_unique = length(regexall(local.legacy_az.log_analytics_query_pack.regex, local.legacy_az.log_analytics_query_pack.name_unique)) > 0
    }
    log_analytics_workspace = {
      valid_name        = length(regexall(local.legacy_az.log_analytics_workspace.regex, local.legacy_az.log_analytics_workspace.name)) > 0 && length(local.legacy_az.log_analytics_workspace.name) > local.legacy_az.log_analytics_workspace.min_length
      valid_name_unique = length(regexall(local.legacy_az.log_analytics_workspace.regex, local.legacy_az.log_analytics_workspace.name_unique)) > 0
    }
    logic_app_integration_account = {
      valid_name        = length(regexall(local.legacy_az.logic_app_integration_account.regex, local.legacy_az.logic_app_integration_account.name)) > 0 && length(local.legacy_az.logic_app_integration_account.name) > local.legacy_az.logic_app_integration_account.min_length
      valid_name_unique = length(regexall(local.legacy_az.logic_app_integration_account.regex, local.legacy_az.logic_app_integration_account.name_unique)) > 0
    }
    logic_app_workflow = {
      valid_name        = length(regexall(local.legacy_az.logic_app_workflow.regex, local.legacy_az.logic_app_workflow.name)) > 0 && length(local.legacy_az.logic_app_workflow.name) > local.legacy_az.logic_app_workflow.min_length
      valid_name_unique = length(regexall(local.legacy_az.logic_app_workflow.regex, local.legacy_az.logic_app_workflow.name_unique)) > 0
    }
    machine_learning_registry = {
      valid_name        = length(regexall(local.legacy_az.machine_learning_registry.regex, local.legacy_az.machine_learning_registry.name)) > 0 && length(local.legacy_az.machine_learning_registry.name) > local.legacy_az.machine_learning_registry.min_length
      valid_name_unique = length(regexall(local.legacy_az.machine_learning_registry.regex, local.legacy_az.machine_learning_registry.name_unique)) > 0
    }
    machine_learning_workspace = {
      valid_name        = length(regexall(local.legacy_az.machine_learning_workspace.regex, local.legacy_az.machine_learning_workspace.name)) > 0 && length(local.legacy_az.machine_learning_workspace.name) > local.legacy_az.machine_learning_workspace.min_length
      valid_name_unique = length(regexall(local.legacy_az.machine_learning_workspace.regex, local.legacy_az.machine_learning_workspace.name_unique)) > 0
    }
    maintenance_configuration = {
      valid_name        = length(regexall(local.legacy_az.maintenance_configuration.regex, local.legacy_az.maintenance_configuration.name)) > 0 && length(local.legacy_az.maintenance_configuration.name) > local.legacy_az.maintenance_configuration.min_length
      valid_name_unique = length(regexall(local.legacy_az.maintenance_configuration.regex, local.legacy_az.maintenance_configuration.name_unique)) > 0
    }
    managed_disk = {
      valid_name        = length(regexall(local.legacy_az.managed_disk.regex, local.legacy_az.managed_disk.name)) > 0 && length(local.legacy_az.managed_disk.name) > local.legacy_az.managed_disk.min_length
      valid_name_unique = length(regexall(local.legacy_az.managed_disk.regex, local.legacy_az.managed_disk.name_unique)) > 0
    }
    management_group = {
      valid_name        = length(regexall(local.legacy_az.management_group.regex, local.legacy_az.management_group.name)) > 0 && length(local.legacy_az.management_group.name) > local.legacy_az.management_group.min_length
      valid_name_unique = length(regexall(local.legacy_az.management_group.regex, local.legacy_az.management_group.name_unique)) > 0
    }
    maps_account = {
      valid_name        = length(regexall(local.legacy_az.maps_account.regex, local.legacy_az.maps_account.name)) > 0 && length(local.legacy_az.maps_account.name) > local.legacy_az.maps_account.min_length
      valid_name_unique = length(regexall(local.legacy_az.maps_account.regex, local.legacy_az.maps_account.name_unique)) > 0
    }
    mariadb_database = {
      valid_name        = length(regexall(local.legacy_az.mariadb_database.regex, local.legacy_az.mariadb_database.name)) > 0 && length(local.legacy_az.mariadb_database.name) > local.legacy_az.mariadb_database.min_length
      valid_name_unique = length(regexall(local.legacy_az.mariadb_database.regex, local.legacy_az.mariadb_database.name_unique)) > 0
    }
    mariadb_firewall_rule = {
      valid_name        = length(regexall(local.legacy_az.mariadb_firewall_rule.regex, local.legacy_az.mariadb_firewall_rule.name)) > 0 && length(local.legacy_az.mariadb_firewall_rule.name) > local.legacy_az.mariadb_firewall_rule.min_length
      valid_name_unique = length(regexall(local.legacy_az.mariadb_firewall_rule.regex, local.legacy_az.mariadb_firewall_rule.name_unique)) > 0
    }
    mariadb_server = {
      valid_name        = length(regexall(local.legacy_az.mariadb_server.regex, local.legacy_az.mariadb_server.name)) > 0 && length(local.legacy_az.mariadb_server.name) > local.legacy_az.mariadb_server.min_length
      valid_name_unique = length(regexall(local.legacy_az.mariadb_server.regex, local.legacy_az.mariadb_server.name_unique)) > 0
    }
    mariadb_virtual_network_rule = {
      valid_name        = length(regexall(local.legacy_az.mariadb_virtual_network_rule.regex, local.legacy_az.mariadb_virtual_network_rule.name)) > 0 && length(local.legacy_az.mariadb_virtual_network_rule.name) > local.legacy_az.mariadb_virtual_network_rule.min_length
      valid_name_unique = length(regexall(local.legacy_az.mariadb_virtual_network_rule.regex, local.legacy_az.mariadb_virtual_network_rule.name_unique)) > 0
    }
    monitor_action_group = {
      valid_name        = length(regexall(local.legacy_az.monitor_action_group.regex, local.legacy_az.monitor_action_group.name)) > 0 && length(local.legacy_az.monitor_action_group.name) > local.legacy_az.monitor_action_group.min_length
      valid_name_unique = length(regexall(local.legacy_az.monitor_action_group.regex, local.legacy_az.monitor_action_group.name_unique)) > 0
    }
    monitor_alert_processing_rule_action_group = {
      valid_name        = length(regexall(local.legacy_az.monitor_alert_processing_rule_action_group.regex, local.legacy_az.monitor_alert_processing_rule_action_group.name)) > 0 && length(local.legacy_az.monitor_alert_processing_rule_action_group.name) > local.legacy_az.monitor_alert_processing_rule_action_group.min_length
      valid_name_unique = length(regexall(local.legacy_az.monitor_alert_processing_rule_action_group.regex, local.legacy_az.monitor_alert_processing_rule_action_group.name_unique)) > 0
    }
    monitor_autoscale_setting = {
      valid_name        = length(regexall(local.legacy_az.monitor_autoscale_setting.regex, local.legacy_az.monitor_autoscale_setting.name)) > 0 && length(local.legacy_az.monitor_autoscale_setting.name) > local.legacy_az.monitor_autoscale_setting.min_length
      valid_name_unique = length(regexall(local.legacy_az.monitor_autoscale_setting.regex, local.legacy_az.monitor_autoscale_setting.name_unique)) > 0
    }
    monitor_data_collection_endpoint = {
      valid_name        = length(regexall(local.legacy_az.monitor_data_collection_endpoint.regex, local.legacy_az.monitor_data_collection_endpoint.name)) > 0 && length(local.legacy_az.monitor_data_collection_endpoint.name) > local.legacy_az.monitor_data_collection_endpoint.min_length
      valid_name_unique = length(regexall(local.legacy_az.monitor_data_collection_endpoint.regex, local.legacy_az.monitor_data_collection_endpoint.name_unique)) > 0
    }
    monitor_data_collection_rule = {
      valid_name        = length(regexall(local.legacy_az.monitor_data_collection_rule.regex, local.legacy_az.monitor_data_collection_rule.name)) > 0 && length(local.legacy_az.monitor_data_collection_rule.name) > local.legacy_az.monitor_data_collection_rule.min_length
      valid_name_unique = length(regexall(local.legacy_az.monitor_data_collection_rule.regex, local.legacy_az.monitor_data_collection_rule.name_unique)) > 0
    }
    monitor_diagnostic_setting = {
      valid_name        = length(regexall(local.legacy_az.monitor_diagnostic_setting.regex, local.legacy_az.monitor_diagnostic_setting.name)) > 0 && length(local.legacy_az.monitor_diagnostic_setting.name) > local.legacy_az.monitor_diagnostic_setting.min_length
      valid_name_unique = length(regexall(local.legacy_az.monitor_diagnostic_setting.regex, local.legacy_az.monitor_diagnostic_setting.name_unique)) > 0
    }
    monitor_scheduled_query_rules_alert = {
      valid_name        = length(regexall(local.legacy_az.monitor_scheduled_query_rules_alert.regex, local.legacy_az.monitor_scheduled_query_rules_alert.name)) > 0 && length(local.legacy_az.monitor_scheduled_query_rules_alert.name) > local.legacy_az.monitor_scheduled_query_rules_alert.min_length
      valid_name_unique = length(regexall(local.legacy_az.monitor_scheduled_query_rules_alert.regex, local.legacy_az.monitor_scheduled_query_rules_alert.name_unique)) > 0
    }
    mssql_database = {
      valid_name        = length(regexall(local.legacy_az.mssql_database.regex, local.legacy_az.mssql_database.name)) > 0 && length(local.legacy_az.mssql_database.name) > local.legacy_az.mssql_database.min_length
      valid_name_unique = length(regexall(local.legacy_az.mssql_database.regex, local.legacy_az.mssql_database.name_unique)) > 0
    }
    mssql_elasticpool = {
      valid_name        = length(regexall(local.legacy_az.mssql_elasticpool.regex, local.legacy_az.mssql_elasticpool.name)) > 0 && length(local.legacy_az.mssql_elasticpool.name) > local.legacy_az.mssql_elasticpool.min_length
      valid_name_unique = length(regexall(local.legacy_az.mssql_elasticpool.regex, local.legacy_az.mssql_elasticpool.name_unique)) > 0
    }
    mssql_job_agent = {
      valid_name        = length(regexall(local.legacy_az.mssql_job_agent.regex, local.legacy_az.mssql_job_agent.name)) > 0 && length(local.legacy_az.mssql_job_agent.name) > local.legacy_az.mssql_job_agent.min_length
      valid_name_unique = length(regexall(local.legacy_az.mssql_job_agent.regex, local.legacy_az.mssql_job_agent.name_unique)) > 0
    }
    mssql_managed_instance = {
      valid_name        = length(regexall(local.legacy_az.mssql_managed_instance.regex, local.legacy_az.mssql_managed_instance.name)) > 0 && length(local.legacy_az.mssql_managed_instance.name) > local.legacy_az.mssql_managed_instance.min_length
      valid_name_unique = length(regexall(local.legacy_az.mssql_managed_instance.regex, local.legacy_az.mssql_managed_instance.name_unique)) > 0
    }
    mssql_server = {
      valid_name        = length(regexall(local.legacy_az.mssql_server.regex, local.legacy_az.mssql_server.name)) > 0 && length(local.legacy_az.mssql_server.name) > local.legacy_az.mssql_server.min_length
      valid_name_unique = length(regexall(local.legacy_az.mssql_server.regex, local.legacy_az.mssql_server.name_unique)) > 0
    }
    mysql_database = {
      valid_name        = length(regexall(local.legacy_az.mysql_database.regex, local.legacy_az.mysql_database.name)) > 0 && length(local.legacy_az.mysql_database.name) > local.legacy_az.mysql_database.min_length
      valid_name_unique = length(regexall(local.legacy_az.mysql_database.regex, local.legacy_az.mysql_database.name_unique)) > 0
    }
    mysql_firewall_rule = {
      valid_name        = length(regexall(local.legacy_az.mysql_firewall_rule.regex, local.legacy_az.mysql_firewall_rule.name)) > 0 && length(local.legacy_az.mysql_firewall_rule.name) > local.legacy_az.mysql_firewall_rule.min_length
      valid_name_unique = length(regexall(local.legacy_az.mysql_firewall_rule.regex, local.legacy_az.mysql_firewall_rule.name_unique)) > 0
    }
    mysql_server = {
      valid_name        = length(regexall(local.legacy_az.mysql_server.regex, local.legacy_az.mysql_server.name)) > 0 && length(local.legacy_az.mysql_server.name) > local.legacy_az.mysql_server.min_length
      valid_name_unique = length(regexall(local.legacy_az.mysql_server.regex, local.legacy_az.mysql_server.name_unique)) > 0
    }
    mysql_virtual_network_rule = {
      valid_name        = length(regexall(local.legacy_az.mysql_virtual_network_rule.regex, local.legacy_az.mysql_virtual_network_rule.name)) > 0 && length(local.legacy_az.mysql_virtual_network_rule.name) > local.legacy_az.mysql_virtual_network_rule.min_length
      valid_name_unique = length(regexall(local.legacy_az.mysql_virtual_network_rule.regex, local.legacy_az.mysql_virtual_network_rule.name_unique)) > 0
    }
    nat_gateway = {
      valid_name        = length(regexall(local.legacy_az.nat_gateway.regex, local.legacy_az.nat_gateway.name)) > 0 && length(local.legacy_az.nat_gateway.name) > local.legacy_az.nat_gateway.min_length
      valid_name_unique = length(regexall(local.legacy_az.nat_gateway.regex, local.legacy_az.nat_gateway.name_unique)) > 0
    }
    network_ddos_protection_plan = {
      valid_name        = length(regexall(local.legacy_az.network_ddos_protection_plan.regex, local.legacy_az.network_ddos_protection_plan.name)) > 0 && length(local.legacy_az.network_ddos_protection_plan.name) > local.legacy_az.network_ddos_protection_plan.min_length
      valid_name_unique = length(regexall(local.legacy_az.network_ddos_protection_plan.regex, local.legacy_az.network_ddos_protection_plan.name_unique)) > 0
    }
    network_interface = {
      valid_name        = length(regexall(local.legacy_az.network_interface.regex, local.legacy_az.network_interface.name)) > 0 && length(local.legacy_az.network_interface.name) > local.legacy_az.network_interface.min_length
      valid_name_unique = length(regexall(local.legacy_az.network_interface.regex, local.legacy_az.network_interface.name_unique)) > 0
    }
    network_manager = {
      valid_name        = length(regexall(local.legacy_az.network_manager.regex, local.legacy_az.network_manager.name)) > 0 && length(local.legacy_az.network_manager.name) > local.legacy_az.network_manager.min_length
      valid_name_unique = length(regexall(local.legacy_az.network_manager.regex, local.legacy_az.network_manager.name_unique)) > 0
    }
    network_security_group = {
      valid_name        = length(regexall(local.legacy_az.network_security_group.regex, local.legacy_az.network_security_group.name)) > 0 && length(local.legacy_az.network_security_group.name) > local.legacy_az.network_security_group.min_length
      valid_name_unique = length(regexall(local.legacy_az.network_security_group.regex, local.legacy_az.network_security_group.name_unique)) > 0
    }
    network_security_group_rule = {
      valid_name        = length(regexall(local.legacy_az.network_security_group_rule.regex, local.legacy_az.network_security_group_rule.name)) > 0 && length(local.legacy_az.network_security_group_rule.name) > local.legacy_az.network_security_group_rule.min_length
      valid_name_unique = length(regexall(local.legacy_az.network_security_group_rule.regex, local.legacy_az.network_security_group_rule.name_unique)) > 0
    }
    network_security_rule = {
      valid_name        = length(regexall(local.legacy_az.network_security_rule.regex, local.legacy_az.network_security_rule.name)) > 0 && length(local.legacy_az.network_security_rule.name) > local.legacy_az.network_security_rule.min_length
      valid_name_unique = length(regexall(local.legacy_az.network_security_rule.regex, local.legacy_az.network_security_rule.name_unique)) > 0
    }
    network_watcher = {
      valid_name        = length(regexall(local.legacy_az.network_watcher.regex, local.legacy_az.network_watcher.name)) > 0 && length(local.legacy_az.network_watcher.name) > local.legacy_az.network_watcher.min_length
      valid_name_unique = length(regexall(local.legacy_az.network_watcher.regex, local.legacy_az.network_watcher.name_unique)) > 0
    }
    notification_hub = {
      valid_name        = length(regexall(local.legacy_az.notification_hub.regex, local.legacy_az.notification_hub.name)) > 0 && length(local.legacy_az.notification_hub.name) > local.legacy_az.notification_hub.min_length
      valid_name_unique = length(regexall(local.legacy_az.notification_hub.regex, local.legacy_az.notification_hub.name_unique)) > 0
    }
    notification_hub_authorization_rule = {
      valid_name        = length(regexall(local.legacy_az.notification_hub_authorization_rule.regex, local.legacy_az.notification_hub_authorization_rule.name)) > 0 && length(local.legacy_az.notification_hub_authorization_rule.name) > local.legacy_az.notification_hub_authorization_rule.min_length
      valid_name_unique = length(regexall(local.legacy_az.notification_hub_authorization_rule.regex, local.legacy_az.notification_hub_authorization_rule.name_unique)) > 0
    }
    notification_hub_namespace = {
      valid_name        = length(regexall(local.legacy_az.notification_hub_namespace.regex, local.legacy_az.notification_hub_namespace.name)) > 0 && length(local.legacy_az.notification_hub_namespace.name) > local.legacy_az.notification_hub_namespace.min_length
      valid_name_unique = length(regexall(local.legacy_az.notification_hub_namespace.regex, local.legacy_az.notification_hub_namespace.name_unique)) > 0
    }
    point_to_site_vpn_gateway = {
      valid_name        = length(regexall(local.legacy_az.point_to_site_vpn_gateway.regex, local.legacy_az.point_to_site_vpn_gateway.name)) > 0 && length(local.legacy_az.point_to_site_vpn_gateway.name) > local.legacy_az.point_to_site_vpn_gateway.min_length
      valid_name_unique = length(regexall(local.legacy_az.point_to_site_vpn_gateway.regex, local.legacy_az.point_to_site_vpn_gateway.name_unique)) > 0
    }
    policy_definition = {
      valid_name        = length(regexall(local.legacy_az.policy_definition.regex, local.legacy_az.policy_definition.name)) > 0 && length(local.legacy_az.policy_definition.name) > local.legacy_az.policy_definition.min_length
      valid_name_unique = length(regexall(local.legacy_az.policy_definition.regex, local.legacy_az.policy_definition.name_unique)) > 0
    }
    postgresql_database = {
      valid_name        = length(regexall(local.legacy_az.postgresql_database.regex, local.legacy_az.postgresql_database.name)) > 0 && length(local.legacy_az.postgresql_database.name) > local.legacy_az.postgresql_database.min_length
      valid_name_unique = length(regexall(local.legacy_az.postgresql_database.regex, local.legacy_az.postgresql_database.name_unique)) > 0
    }
    postgresql_firewall_rule = {
      valid_name        = length(regexall(local.legacy_az.postgresql_firewall_rule.regex, local.legacy_az.postgresql_firewall_rule.name)) > 0 && length(local.legacy_az.postgresql_firewall_rule.name) > local.legacy_az.postgresql_firewall_rule.min_length
      valid_name_unique = length(regexall(local.legacy_az.postgresql_firewall_rule.regex, local.legacy_az.postgresql_firewall_rule.name_unique)) > 0
    }
    postgresql_server = {
      valid_name        = length(regexall(local.legacy_az.postgresql_server.regex, local.legacy_az.postgresql_server.name)) > 0 && length(local.legacy_az.postgresql_server.name) > local.legacy_az.postgresql_server.min_length
      valid_name_unique = length(regexall(local.legacy_az.postgresql_server.regex, local.legacy_az.postgresql_server.name_unique)) > 0
    }
    postgresql_virtual_network_rule = {
      valid_name        = length(regexall(local.legacy_az.postgresql_virtual_network_rule.regex, local.legacy_az.postgresql_virtual_network_rule.name)) > 0 && length(local.legacy_az.postgresql_virtual_network_rule.name) > local.legacy_az.postgresql_virtual_network_rule.min_length
      valid_name_unique = length(regexall(local.legacy_az.postgresql_virtual_network_rule.regex, local.legacy_az.postgresql_virtual_network_rule.name_unique)) > 0
    }
    powerbi_embedded = {
      valid_name        = length(regexall(local.legacy_az.powerbi_embedded.regex, local.legacy_az.powerbi_embedded.name)) > 0 && length(local.legacy_az.powerbi_embedded.name) > local.legacy_az.powerbi_embedded.min_length
      valid_name_unique = length(regexall(local.legacy_az.powerbi_embedded.regex, local.legacy_az.powerbi_embedded.name_unique)) > 0
    }
    private_dns_a_record = {
      valid_name        = length(regexall(local.legacy_az.private_dns_a_record.regex, local.legacy_az.private_dns_a_record.name)) > 0 && length(local.legacy_az.private_dns_a_record.name) > local.legacy_az.private_dns_a_record.min_length
      valid_name_unique = length(regexall(local.legacy_az.private_dns_a_record.regex, local.legacy_az.private_dns_a_record.name_unique)) > 0
    }
    private_dns_aaaa_record = {
      valid_name        = length(regexall(local.legacy_az.private_dns_aaaa_record.regex, local.legacy_az.private_dns_aaaa_record.name)) > 0 && length(local.legacy_az.private_dns_aaaa_record.name) > local.legacy_az.private_dns_aaaa_record.min_length
      valid_name_unique = length(regexall(local.legacy_az.private_dns_aaaa_record.regex, local.legacy_az.private_dns_aaaa_record.name_unique)) > 0
    }
    private_dns_cname_record = {
      valid_name        = length(regexall(local.legacy_az.private_dns_cname_record.regex, local.legacy_az.private_dns_cname_record.name)) > 0 && length(local.legacy_az.private_dns_cname_record.name) > local.legacy_az.private_dns_cname_record.min_length
      valid_name_unique = length(regexall(local.legacy_az.private_dns_cname_record.regex, local.legacy_az.private_dns_cname_record.name_unique)) > 0
    }
    private_dns_mx_record = {
      valid_name        = length(regexall(local.legacy_az.private_dns_mx_record.regex, local.legacy_az.private_dns_mx_record.name)) > 0 && length(local.legacy_az.private_dns_mx_record.name) > local.legacy_az.private_dns_mx_record.min_length
      valid_name_unique = length(regexall(local.legacy_az.private_dns_mx_record.regex, local.legacy_az.private_dns_mx_record.name_unique)) > 0
    }
    private_dns_ptr_record = {
      valid_name        = length(regexall(local.legacy_az.private_dns_ptr_record.regex, local.legacy_az.private_dns_ptr_record.name)) > 0 && length(local.legacy_az.private_dns_ptr_record.name) > local.legacy_az.private_dns_ptr_record.min_length
      valid_name_unique = length(regexall(local.legacy_az.private_dns_ptr_record.regex, local.legacy_az.private_dns_ptr_record.name_unique)) > 0
    }
    private_dns_srv_record = {
      valid_name        = length(regexall(local.legacy_az.private_dns_srv_record.regex, local.legacy_az.private_dns_srv_record.name)) > 0 && length(local.legacy_az.private_dns_srv_record.name) > local.legacy_az.private_dns_srv_record.min_length
      valid_name_unique = length(regexall(local.legacy_az.private_dns_srv_record.regex, local.legacy_az.private_dns_srv_record.name_unique)) > 0
    }
    private_dns_txt_record = {
      valid_name        = length(regexall(local.legacy_az.private_dns_txt_record.regex, local.legacy_az.private_dns_txt_record.name)) > 0 && length(local.legacy_az.private_dns_txt_record.name) > local.legacy_az.private_dns_txt_record.min_length
      valid_name_unique = length(regexall(local.legacy_az.private_dns_txt_record.regex, local.legacy_az.private_dns_txt_record.name_unique)) > 0
    }
    private_dns_zone = {
      valid_name        = length(regexall(local.legacy_az.private_dns_zone.regex, local.legacy_az.private_dns_zone.name)) > 0 && length(local.legacy_az.private_dns_zone.name) > local.legacy_az.private_dns_zone.min_length
      valid_name_unique = length(regexall(local.legacy_az.private_dns_zone.regex, local.legacy_az.private_dns_zone.name_unique)) > 0
    }
    private_dns_zone_group = {
      valid_name        = length(regexall(local.legacy_az.private_dns_zone_group.regex, local.legacy_az.private_dns_zone_group.name)) > 0 && length(local.legacy_az.private_dns_zone_group.name) > local.legacy_az.private_dns_zone_group.min_length
      valid_name_unique = length(regexall(local.legacy_az.private_dns_zone_group.regex, local.legacy_az.private_dns_zone_group.name_unique)) > 0
    }
    private_endpoint = {
      valid_name        = length(regexall(local.legacy_az.private_endpoint.regex, local.legacy_az.private_endpoint.name)) > 0 && length(local.legacy_az.private_endpoint.name) > local.legacy_az.private_endpoint.min_length
      valid_name_unique = length(regexall(local.legacy_az.private_endpoint.regex, local.legacy_az.private_endpoint.name_unique)) > 0
    }
    private_link_service = {
      valid_name        = length(regexall(local.legacy_az.private_link_service.regex, local.legacy_az.private_link_service.name)) > 0 && length(local.legacy_az.private_link_service.name) > local.legacy_az.private_link_service.min_length
      valid_name_unique = length(regexall(local.legacy_az.private_link_service.regex, local.legacy_az.private_link_service.name_unique)) > 0
    }
    private_service_connection = {
      valid_name        = length(regexall(local.legacy_az.private_service_connection.regex, local.legacy_az.private_service_connection.name)) > 0 && length(local.legacy_az.private_service_connection.name) > local.legacy_az.private_service_connection.min_length
      valid_name_unique = length(regexall(local.legacy_az.private_service_connection.regex, local.legacy_az.private_service_connection.name_unique)) > 0
    }
    proximity_placement_group = {
      valid_name        = length(regexall(local.legacy_az.proximity_placement_group.regex, local.legacy_az.proximity_placement_group.name)) > 0 && length(local.legacy_az.proximity_placement_group.name) > local.legacy_az.proximity_placement_group.min_length
      valid_name_unique = length(regexall(local.legacy_az.proximity_placement_group.regex, local.legacy_az.proximity_placement_group.name_unique)) > 0
    }
    public_ip = {
      valid_name        = length(regexall(local.legacy_az.public_ip.regex, local.legacy_az.public_ip.name)) > 0 && length(local.legacy_az.public_ip.name) > local.legacy_az.public_ip.min_length
      valid_name_unique = length(regexall(local.legacy_az.public_ip.regex, local.legacy_az.public_ip.name_unique)) > 0
    }
    public_ip_prefix = {
      valid_name        = length(regexall(local.legacy_az.public_ip_prefix.regex, local.legacy_az.public_ip_prefix.name)) > 0 && length(local.legacy_az.public_ip_prefix.name) > local.legacy_az.public_ip_prefix.min_length
      valid_name_unique = length(regexall(local.legacy_az.public_ip_prefix.regex, local.legacy_az.public_ip_prefix.name_unique)) > 0
    }
    purview_account = {
      valid_name        = length(regexall(local.legacy_az.purview_account.regex, local.legacy_az.purview_account.name)) > 0 && length(local.legacy_az.purview_account.name) > local.legacy_az.purview_account.min_length
      valid_name_unique = length(regexall(local.legacy_az.purview_account.regex, local.legacy_az.purview_account.name_unique)) > 0
    }
    recovery_services_vault = {
      valid_name        = length(regexall(local.legacy_az.recovery_services_vault.regex, local.legacy_az.recovery_services_vault.name)) > 0 && length(local.legacy_az.recovery_services_vault.name) > local.legacy_az.recovery_services_vault.min_length
      valid_name_unique = length(regexall(local.legacy_az.recovery_services_vault.regex, local.legacy_az.recovery_services_vault.name_unique)) > 0
    }
    redhat_openshift_cluster = {
      valid_name        = length(regexall(local.legacy_az.redhat_openshift_cluster.regex, local.legacy_az.redhat_openshift_cluster.name)) > 0 && length(local.legacy_az.redhat_openshift_cluster.name) > local.legacy_az.redhat_openshift_cluster.min_length
      valid_name_unique = length(regexall(local.legacy_az.redhat_openshift_cluster.regex, local.legacy_az.redhat_openshift_cluster.name_unique)) > 0
    }
    redis_cache = {
      valid_name        = length(regexall(local.legacy_az.redis_cache.regex, local.legacy_az.redis_cache.name)) > 0 && length(local.legacy_az.redis_cache.name) > local.legacy_az.redis_cache.min_length
      valid_name_unique = length(regexall(local.legacy_az.redis_cache.regex, local.legacy_az.redis_cache.name_unique)) > 0
    }
    redis_firewall_rule = {
      valid_name        = length(regexall(local.legacy_az.redis_firewall_rule.regex, local.legacy_az.redis_firewall_rule.name)) > 0 && length(local.legacy_az.redis_firewall_rule.name) > local.legacy_az.redis_firewall_rule.min_length
      valid_name_unique = length(regexall(local.legacy_az.redis_firewall_rule.regex, local.legacy_az.redis_firewall_rule.name_unique)) > 0
    }
    relay_hybrid_connection = {
      valid_name        = length(regexall(local.legacy_az.relay_hybrid_connection.regex, local.legacy_az.relay_hybrid_connection.name)) > 0 && length(local.legacy_az.relay_hybrid_connection.name) > local.legacy_az.relay_hybrid_connection.min_length
      valid_name_unique = length(regexall(local.legacy_az.relay_hybrid_connection.regex, local.legacy_az.relay_hybrid_connection.name_unique)) > 0
    }
    relay_namespace = {
      valid_name        = length(regexall(local.legacy_az.relay_namespace.regex, local.legacy_az.relay_namespace.name)) > 0 && length(local.legacy_az.relay_namespace.name) > local.legacy_az.relay_namespace.min_length
      valid_name_unique = length(regexall(local.legacy_az.relay_namespace.regex, local.legacy_az.relay_namespace.name_unique)) > 0
    }
    resource_group = {
      valid_name        = length(regexall(local.legacy_az.resource_group.regex, local.legacy_az.resource_group.name)) > 0 && length(local.legacy_az.resource_group.name) > local.legacy_az.resource_group.min_length
      valid_name_unique = length(regexall(local.legacy_az.resource_group.regex, local.legacy_az.resource_group.name_unique)) > 0
    }
    resource_group_template_deployment = {
      valid_name        = length(regexall(local.legacy_az.resource_group_template_deployment.regex, local.legacy_az.resource_group_template_deployment.name)) > 0 && length(local.legacy_az.resource_group_template_deployment.name) > local.legacy_az.resource_group_template_deployment.min_length
      valid_name_unique = length(regexall(local.legacy_az.resource_group_template_deployment.regex, local.legacy_az.resource_group_template_deployment.name_unique)) > 0
    }
    role_assignment = {
      valid_name        = length(regexall(local.legacy_az.role_assignment.regex, local.legacy_az.role_assignment.name)) > 0 && length(local.legacy_az.role_assignment.name) > local.legacy_az.role_assignment.min_length
      valid_name_unique = length(regexall(local.legacy_az.role_assignment.regex, local.legacy_az.role_assignment.name_unique)) > 0
    }
    role_definition = {
      valid_name        = length(regexall(local.legacy_az.role_definition.regex, local.legacy_az.role_definition.name)) > 0 && length(local.legacy_az.role_definition.name) > local.legacy_az.role_definition.min_length
      valid_name_unique = length(regexall(local.legacy_az.role_definition.regex, local.legacy_az.role_definition.name_unique)) > 0
    }
    route = {
      valid_name        = length(regexall(local.legacy_az.route.regex, local.legacy_az.route.name)) > 0 && length(local.legacy_az.route.name) > local.legacy_az.route.min_length
      valid_name_unique = length(regexall(local.legacy_az.route.regex, local.legacy_az.route.name_unique)) > 0
    }
    route_filter = {
      valid_name        = length(regexall(local.legacy_az.route_filter.regex, local.legacy_az.route_filter.name)) > 0 && length(local.legacy_az.route_filter.name) > local.legacy_az.route_filter.min_length
      valid_name_unique = length(regexall(local.legacy_az.route_filter.regex, local.legacy_az.route_filter.name_unique)) > 0
    }
    route_server = {
      valid_name        = length(regexall(local.legacy_az.route_server.regex, local.legacy_az.route_server.name)) > 0 && length(local.legacy_az.route_server.name) > local.legacy_az.route_server.min_length
      valid_name_unique = length(regexall(local.legacy_az.route_server.regex, local.legacy_az.route_server.name_unique)) > 0
    }
    route_table = {
      valid_name        = length(regexall(local.legacy_az.route_table.regex, local.legacy_az.route_table.name)) > 0 && length(local.legacy_az.route_table.name) > local.legacy_az.route_table.min_length
      valid_name_unique = length(regexall(local.legacy_az.route_table.regex, local.legacy_az.route_table.name_unique)) > 0
    }
    search_service = {
      valid_name        = length(regexall(local.legacy_az.search_service.regex, local.legacy_az.search_service.name)) > 0 && length(local.legacy_az.search_service.name) > local.legacy_az.search_service.min_length
      valid_name_unique = length(regexall(local.legacy_az.search_service.regex, local.legacy_az.search_service.name_unique)) > 0
    }
    service_fabric_cluster = {
      valid_name        = length(regexall(local.legacy_az.service_fabric_cluster.regex, local.legacy_az.service_fabric_cluster.name)) > 0 && length(local.legacy_az.service_fabric_cluster.name) > local.legacy_az.service_fabric_cluster.min_length
      valid_name_unique = length(regexall(local.legacy_az.service_fabric_cluster.regex, local.legacy_az.service_fabric_cluster.name_unique)) > 0
    }
    servicebus_namespace = {
      valid_name        = length(regexall(local.legacy_az.servicebus_namespace.regex, local.legacy_az.servicebus_namespace.name)) > 0 && length(local.legacy_az.servicebus_namespace.name) > local.legacy_az.servicebus_namespace.min_length
      valid_name_unique = length(regexall(local.legacy_az.servicebus_namespace.regex, local.legacy_az.servicebus_namespace.name_unique)) > 0
    }
    servicebus_namespace_authorization_rule = {
      valid_name        = length(regexall(local.legacy_az.servicebus_namespace_authorization_rule.regex, local.legacy_az.servicebus_namespace_authorization_rule.name)) > 0 && length(local.legacy_az.servicebus_namespace_authorization_rule.name) > local.legacy_az.servicebus_namespace_authorization_rule.min_length
      valid_name_unique = length(regexall(local.legacy_az.servicebus_namespace_authorization_rule.regex, local.legacy_az.servicebus_namespace_authorization_rule.name_unique)) > 0
    }
    servicebus_queue = {
      valid_name        = length(regexall(local.legacy_az.servicebus_queue.regex, local.legacy_az.servicebus_queue.name)) > 0 && length(local.legacy_az.servicebus_queue.name) > local.legacy_az.servicebus_queue.min_length
      valid_name_unique = length(regexall(local.legacy_az.servicebus_queue.regex, local.legacy_az.servicebus_queue.name_unique)) > 0
    }
    servicebus_queue_authorization_rule = {
      valid_name        = length(regexall(local.legacy_az.servicebus_queue_authorization_rule.regex, local.legacy_az.servicebus_queue_authorization_rule.name)) > 0 && length(local.legacy_az.servicebus_queue_authorization_rule.name) > local.legacy_az.servicebus_queue_authorization_rule.min_length
      valid_name_unique = length(regexall(local.legacy_az.servicebus_queue_authorization_rule.regex, local.legacy_az.servicebus_queue_authorization_rule.name_unique)) > 0
    }
    servicebus_subscription = {
      valid_name        = length(regexall(local.legacy_az.servicebus_subscription.regex, local.legacy_az.servicebus_subscription.name)) > 0 && length(local.legacy_az.servicebus_subscription.name) > local.legacy_az.servicebus_subscription.min_length
      valid_name_unique = length(regexall(local.legacy_az.servicebus_subscription.regex, local.legacy_az.servicebus_subscription.name_unique)) > 0
    }
    servicebus_subscription_rule = {
      valid_name        = length(regexall(local.legacy_az.servicebus_subscription_rule.regex, local.legacy_az.servicebus_subscription_rule.name)) > 0 && length(local.legacy_az.servicebus_subscription_rule.name) > local.legacy_az.servicebus_subscription_rule.min_length
      valid_name_unique = length(regexall(local.legacy_az.servicebus_subscription_rule.regex, local.legacy_az.servicebus_subscription_rule.name_unique)) > 0
    }
    servicebus_topic = {
      valid_name        = length(regexall(local.legacy_az.servicebus_topic.regex, local.legacy_az.servicebus_topic.name)) > 0 && length(local.legacy_az.servicebus_topic.name) > local.legacy_az.servicebus_topic.min_length
      valid_name_unique = length(regexall(local.legacy_az.servicebus_topic.regex, local.legacy_az.servicebus_topic.name_unique)) > 0
    }
    servicebus_topic_authorization_rule = {
      valid_name        = length(regexall(local.legacy_az.servicebus_topic_authorization_rule.regex, local.legacy_az.servicebus_topic_authorization_rule.name)) > 0 && length(local.legacy_az.servicebus_topic_authorization_rule.name) > local.legacy_az.servicebus_topic_authorization_rule.min_length
      valid_name_unique = length(regexall(local.legacy_az.servicebus_topic_authorization_rule.regex, local.legacy_az.servicebus_topic_authorization_rule.name_unique)) > 0
    }
    shared_image = {
      valid_name        = length(regexall(local.legacy_az.shared_image.regex, local.legacy_az.shared_image.name)) > 0 && length(local.legacy_az.shared_image.name) > local.legacy_az.shared_image.min_length
      valid_name_unique = length(regexall(local.legacy_az.shared_image.regex, local.legacy_az.shared_image.name_unique)) > 0
    }
    shared_image_gallery = {
      valid_name        = length(regexall(local.legacy_az.shared_image_gallery.regex, local.legacy_az.shared_image_gallery.name)) > 0 && length(local.legacy_az.shared_image_gallery.name) > local.legacy_az.shared_image_gallery.min_length
      valid_name_unique = length(regexall(local.legacy_az.shared_image_gallery.regex, local.legacy_az.shared_image_gallery.name_unique)) > 0
    }
    signalr_service = {
      valid_name        = length(regexall(local.legacy_az.signalr_service.regex, local.legacy_az.signalr_service.name)) > 0 && length(local.legacy_az.signalr_service.name) > local.legacy_az.signalr_service.min_length
      valid_name_unique = length(regexall(local.legacy_az.signalr_service.regex, local.legacy_az.signalr_service.name_unique)) > 0
    }
    snapshots = {
      valid_name        = length(regexall(local.legacy_az.snapshots.regex, local.legacy_az.snapshots.name)) > 0 && length(local.legacy_az.snapshots.name) > local.legacy_az.snapshots.min_length
      valid_name_unique = length(regexall(local.legacy_az.snapshots.regex, local.legacy_az.snapshots.name_unique)) > 0
    }
    sql_elasticpool = {
      valid_name        = length(regexall(local.legacy_az.sql_elasticpool.regex, local.legacy_az.sql_elasticpool.name)) > 0 && length(local.legacy_az.sql_elasticpool.name) > local.legacy_az.sql_elasticpool.min_length
      valid_name_unique = length(regexall(local.legacy_az.sql_elasticpool.regex, local.legacy_az.sql_elasticpool.name_unique)) > 0
    }
    sql_failover_group = {
      valid_name        = length(regexall(local.legacy_az.sql_failover_group.regex, local.legacy_az.sql_failover_group.name)) > 0 && length(local.legacy_az.sql_failover_group.name) > local.legacy_az.sql_failover_group.min_length
      valid_name_unique = length(regexall(local.legacy_az.sql_failover_group.regex, local.legacy_az.sql_failover_group.name_unique)) > 0
    }
    sql_firewall_rule = {
      valid_name        = length(regexall(local.legacy_az.sql_firewall_rule.regex, local.legacy_az.sql_firewall_rule.name)) > 0 && length(local.legacy_az.sql_firewall_rule.name) > local.legacy_az.sql_firewall_rule.min_length
      valid_name_unique = length(regexall(local.legacy_az.sql_firewall_rule.regex, local.legacy_az.sql_firewall_rule.name_unique)) > 0
    }
    sql_server = {
      valid_name        = length(regexall(local.legacy_az.sql_server.regex, local.legacy_az.sql_server.name)) > 0 && length(local.legacy_az.sql_server.name) > local.legacy_az.sql_server.min_length
      valid_name_unique = length(regexall(local.legacy_az.sql_server.regex, local.legacy_az.sql_server.name_unique)) > 0
    }
    ssh_public_key = {
      valid_name        = length(regexall(local.legacy_az.ssh_public_key.regex, local.legacy_az.ssh_public_key.name)) > 0 && length(local.legacy_az.ssh_public_key.name) > local.legacy_az.ssh_public_key.min_length
      valid_name_unique = length(regexall(local.legacy_az.ssh_public_key.regex, local.legacy_az.ssh_public_key.name_unique)) > 0
    }
    static_web_app = {
      valid_name        = length(regexall(local.legacy_az.static_web_app.regex, local.legacy_az.static_web_app.name)) > 0 && length(local.legacy_az.static_web_app.name) > local.legacy_az.static_web_app.min_length
      valid_name_unique = length(regexall(local.legacy_az.static_web_app.regex, local.legacy_az.static_web_app.name_unique)) > 0
    }
    storage_account = {
      valid_name        = length(regexall(local.legacy_az.storage_account.regex, local.legacy_az.storage_account.name)) > 0 && length(local.legacy_az.storage_account.name) > local.legacy_az.storage_account.min_length
      valid_name_unique = length(regexall(local.legacy_az.storage_account.regex, local.legacy_az.storage_account.name_unique)) > 0
    }
    storage_blob = {
      valid_name        = length(regexall(local.legacy_az.storage_blob.regex, local.legacy_az.storage_blob.name)) > 0 && length(local.legacy_az.storage_blob.name) > local.legacy_az.storage_blob.min_length
      valid_name_unique = length(regexall(local.legacy_az.storage_blob.regex, local.legacy_az.storage_blob.name_unique)) > 0
    }
    storage_container = {
      valid_name        = length(regexall(local.legacy_az.storage_container.regex, local.legacy_az.storage_container.name)) > 0 && length(local.legacy_az.storage_container.name) > local.legacy_az.storage_container.min_length
      valid_name_unique = length(regexall(local.legacy_az.storage_container.regex, local.legacy_az.storage_container.name_unique)) > 0
    }
    storage_data_lake_gen2_filesystem = {
      valid_name        = length(regexall(local.legacy_az.storage_data_lake_gen2_filesystem.regex, local.legacy_az.storage_data_lake_gen2_filesystem.name)) > 0 && length(local.legacy_az.storage_data_lake_gen2_filesystem.name) > local.legacy_az.storage_data_lake_gen2_filesystem.min_length
      valid_name_unique = length(regexall(local.legacy_az.storage_data_lake_gen2_filesystem.regex, local.legacy_az.storage_data_lake_gen2_filesystem.name_unique)) > 0
    }
    storage_queue = {
      valid_name        = length(regexall(local.legacy_az.storage_queue.regex, local.legacy_az.storage_queue.name)) > 0 && length(local.legacy_az.storage_queue.name) > local.legacy_az.storage_queue.min_length
      valid_name_unique = length(regexall(local.legacy_az.storage_queue.regex, local.legacy_az.storage_queue.name_unique)) > 0
    }
    storage_share = {
      valid_name        = length(regexall(local.legacy_az.storage_share.regex, local.legacy_az.storage_share.name)) > 0 && length(local.legacy_az.storage_share.name) > local.legacy_az.storage_share.min_length
      valid_name_unique = length(regexall(local.legacy_az.storage_share.regex, local.legacy_az.storage_share.name_unique)) > 0
    }
    storage_share_directory = {
      valid_name        = length(regexall(local.legacy_az.storage_share_directory.regex, local.legacy_az.storage_share_directory.name)) > 0 && length(local.legacy_az.storage_share_directory.name) > local.legacy_az.storage_share_directory.min_length
      valid_name_unique = length(regexall(local.legacy_az.storage_share_directory.regex, local.legacy_az.storage_share_directory.name_unique)) > 0
    }
    storage_table = {
      valid_name        = length(regexall(local.legacy_az.storage_table.regex, local.legacy_az.storage_table.name)) > 0 && length(local.legacy_az.storage_table.name) > local.legacy_az.storage_table.min_length
      valid_name_unique = length(regexall(local.legacy_az.storage_table.regex, local.legacy_az.storage_table.name_unique)) > 0
    }
    stream_analytics_function_javascript_udf = {
      valid_name        = length(regexall(local.legacy_az.stream_analytics_function_javascript_udf.regex, local.legacy_az.stream_analytics_function_javascript_udf.name)) > 0 && length(local.legacy_az.stream_analytics_function_javascript_udf.name) > local.legacy_az.stream_analytics_function_javascript_udf.min_length
      valid_name_unique = length(regexall(local.legacy_az.stream_analytics_function_javascript_udf.regex, local.legacy_az.stream_analytics_function_javascript_udf.name_unique)) > 0
    }
    stream_analytics_job = {
      valid_name        = length(regexall(local.legacy_az.stream_analytics_job.regex, local.legacy_az.stream_analytics_job.name)) > 0 && length(local.legacy_az.stream_analytics_job.name) > local.legacy_az.stream_analytics_job.min_length
      valid_name_unique = length(regexall(local.legacy_az.stream_analytics_job.regex, local.legacy_az.stream_analytics_job.name_unique)) > 0
    }
    stream_analytics_output_blob = {
      valid_name        = length(regexall(local.legacy_az.stream_analytics_output_blob.regex, local.legacy_az.stream_analytics_output_blob.name)) > 0 && length(local.legacy_az.stream_analytics_output_blob.name) > local.legacy_az.stream_analytics_output_blob.min_length
      valid_name_unique = length(regexall(local.legacy_az.stream_analytics_output_blob.regex, local.legacy_az.stream_analytics_output_blob.name_unique)) > 0
    }
    stream_analytics_output_eventhub = {
      valid_name        = length(regexall(local.legacy_az.stream_analytics_output_eventhub.regex, local.legacy_az.stream_analytics_output_eventhub.name)) > 0 && length(local.legacy_az.stream_analytics_output_eventhub.name) > local.legacy_az.stream_analytics_output_eventhub.min_length
      valid_name_unique = length(regexall(local.legacy_az.stream_analytics_output_eventhub.regex, local.legacy_az.stream_analytics_output_eventhub.name_unique)) > 0
    }
    stream_analytics_output_mssql = {
      valid_name        = length(regexall(local.legacy_az.stream_analytics_output_mssql.regex, local.legacy_az.stream_analytics_output_mssql.name)) > 0 && length(local.legacy_az.stream_analytics_output_mssql.name) > local.legacy_az.stream_analytics_output_mssql.min_length
      valid_name_unique = length(regexall(local.legacy_az.stream_analytics_output_mssql.regex, local.legacy_az.stream_analytics_output_mssql.name_unique)) > 0
    }
    stream_analytics_output_servicebus_queue = {
      valid_name        = length(regexall(local.legacy_az.stream_analytics_output_servicebus_queue.regex, local.legacy_az.stream_analytics_output_servicebus_queue.name)) > 0 && length(local.legacy_az.stream_analytics_output_servicebus_queue.name) > local.legacy_az.stream_analytics_output_servicebus_queue.min_length
      valid_name_unique = length(regexall(local.legacy_az.stream_analytics_output_servicebus_queue.regex, local.legacy_az.stream_analytics_output_servicebus_queue.name_unique)) > 0
    }
    stream_analytics_output_servicebus_topic = {
      valid_name        = length(regexall(local.legacy_az.stream_analytics_output_servicebus_topic.regex, local.legacy_az.stream_analytics_output_servicebus_topic.name)) > 0 && length(local.legacy_az.stream_analytics_output_servicebus_topic.name) > local.legacy_az.stream_analytics_output_servicebus_topic.min_length
      valid_name_unique = length(regexall(local.legacy_az.stream_analytics_output_servicebus_topic.regex, local.legacy_az.stream_analytics_output_servicebus_topic.name_unique)) > 0
    }
    stream_analytics_reference_input_blob = {
      valid_name        = length(regexall(local.legacy_az.stream_analytics_reference_input_blob.regex, local.legacy_az.stream_analytics_reference_input_blob.name)) > 0 && length(local.legacy_az.stream_analytics_reference_input_blob.name) > local.legacy_az.stream_analytics_reference_input_blob.min_length
      valid_name_unique = length(regexall(local.legacy_az.stream_analytics_reference_input_blob.regex, local.legacy_az.stream_analytics_reference_input_blob.name_unique)) > 0
    }
    stream_analytics_stream_input_blob = {
      valid_name        = length(regexall(local.legacy_az.stream_analytics_stream_input_blob.regex, local.legacy_az.stream_analytics_stream_input_blob.name)) > 0 && length(local.legacy_az.stream_analytics_stream_input_blob.name) > local.legacy_az.stream_analytics_stream_input_blob.min_length
      valid_name_unique = length(regexall(local.legacy_az.stream_analytics_stream_input_blob.regex, local.legacy_az.stream_analytics_stream_input_blob.name_unique)) > 0
    }
    stream_analytics_stream_input_eventhub = {
      valid_name        = length(regexall(local.legacy_az.stream_analytics_stream_input_eventhub.regex, local.legacy_az.stream_analytics_stream_input_eventhub.name)) > 0 && length(local.legacy_az.stream_analytics_stream_input_eventhub.name) > local.legacy_az.stream_analytics_stream_input_eventhub.min_length
      valid_name_unique = length(regexall(local.legacy_az.stream_analytics_stream_input_eventhub.regex, local.legacy_az.stream_analytics_stream_input_eventhub.name_unique)) > 0
    }
    stream_analytics_stream_input_iothub = {
      valid_name        = length(regexall(local.legacy_az.stream_analytics_stream_input_iothub.regex, local.legacy_az.stream_analytics_stream_input_iothub.name)) > 0 && length(local.legacy_az.stream_analytics_stream_input_iothub.name) > local.legacy_az.stream_analytics_stream_input_iothub.min_length
      valid_name_unique = length(regexall(local.legacy_az.stream_analytics_stream_input_iothub.regex, local.legacy_az.stream_analytics_stream_input_iothub.name_unique)) > 0
    }
    subnet = {
      valid_name        = length(regexall(local.legacy_az.subnet.regex, local.legacy_az.subnet.name)) > 0 && length(local.legacy_az.subnet.name) > local.legacy_az.subnet.min_length
      valid_name_unique = length(regexall(local.legacy_az.subnet.regex, local.legacy_az.subnet.name_unique)) > 0
    }
    subnet_service_endpoint_storage_policy = {
      valid_name        = length(regexall(local.legacy_az.subnet_service_endpoint_storage_policy.regex, local.legacy_az.subnet_service_endpoint_storage_policy.name)) > 0 && length(local.legacy_az.subnet_service_endpoint_storage_policy.name) > local.legacy_az.subnet_service_endpoint_storage_policy.min_length
      valid_name_unique = length(regexall(local.legacy_az.subnet_service_endpoint_storage_policy.regex, local.legacy_az.subnet_service_endpoint_storage_policy.name_unique)) > 0
    }
    synapse_private_link_hub = {
      valid_name        = length(regexall(local.legacy_az.synapse_private_link_hub.regex, local.legacy_az.synapse_private_link_hub.name)) > 0 && length(local.legacy_az.synapse_private_link_hub.name) > local.legacy_az.synapse_private_link_hub.min_length
      valid_name_unique = length(regexall(local.legacy_az.synapse_private_link_hub.regex, local.legacy_az.synapse_private_link_hub.name_unique)) > 0
    }
    synapse_spark_pool = {
      valid_name        = length(regexall(local.legacy_az.synapse_spark_pool.regex, local.legacy_az.synapse_spark_pool.name)) > 0 && length(local.legacy_az.synapse_spark_pool.name) > local.legacy_az.synapse_spark_pool.min_length
      valid_name_unique = length(regexall(local.legacy_az.synapse_spark_pool.regex, local.legacy_az.synapse_spark_pool.name_unique)) > 0
    }
    synapse_sql_pool = {
      valid_name        = length(regexall(local.legacy_az.synapse_sql_pool.regex, local.legacy_az.synapse_sql_pool.name)) > 0 && length(local.legacy_az.synapse_sql_pool.name) > local.legacy_az.synapse_sql_pool.min_length
      valid_name_unique = length(regexall(local.legacy_az.synapse_sql_pool.regex, local.legacy_az.synapse_sql_pool.name_unique)) > 0
    }
    synapse_workspace = {
      valid_name        = length(regexall(local.legacy_az.synapse_workspace.regex, local.legacy_az.synapse_workspace.name)) > 0 && length(local.legacy_az.synapse_workspace.name) > local.legacy_az.synapse_workspace.min_length
      valid_name_unique = length(regexall(local.legacy_az.synapse_workspace.regex, local.legacy_az.synapse_workspace.name_unique)) > 0
    }
    template_deployment = {
      valid_name        = length(regexall(local.legacy_az.template_deployment.regex, local.legacy_az.template_deployment.name)) > 0 && length(local.legacy_az.template_deployment.name) > local.legacy_az.template_deployment.min_length
      valid_name_unique = length(regexall(local.legacy_az.template_deployment.regex, local.legacy_az.template_deployment.name_unique)) > 0
    }
    traffic_manager_profile = {
      valid_name        = length(regexall(local.legacy_az.traffic_manager_profile.regex, local.legacy_az.traffic_manager_profile.name)) > 0 && length(local.legacy_az.traffic_manager_profile.name) > local.legacy_az.traffic_manager_profile.min_length
      valid_name_unique = length(regexall(local.legacy_az.traffic_manager_profile.regex, local.legacy_az.traffic_manager_profile.name_unique)) > 0
    }
    user_assigned_identity = {
      valid_name        = length(regexall(local.legacy_az.user_assigned_identity.regex, local.legacy_az.user_assigned_identity.name)) > 0 && length(local.legacy_az.user_assigned_identity.name) > local.legacy_az.user_assigned_identity.min_length
      valid_name_unique = length(regexall(local.legacy_az.user_assigned_identity.regex, local.legacy_az.user_assigned_identity.name_unique)) > 0
    }
    virtual_desktop_application_group = {
      valid_name        = length(regexall(local.legacy_az.virtual_desktop_application_group.regex, local.legacy_az.virtual_desktop_application_group.name)) > 0 && length(local.legacy_az.virtual_desktop_application_group.name) > local.legacy_az.virtual_desktop_application_group.min_length
      valid_name_unique = length(regexall(local.legacy_az.virtual_desktop_application_group.regex, local.legacy_az.virtual_desktop_application_group.name_unique)) > 0
    }
    virtual_desktop_host_pool = {
      valid_name        = length(regexall(local.legacy_az.virtual_desktop_host_pool.regex, local.legacy_az.virtual_desktop_host_pool.name)) > 0 && length(local.legacy_az.virtual_desktop_host_pool.name) > local.legacy_az.virtual_desktop_host_pool.min_length
      valid_name_unique = length(regexall(local.legacy_az.virtual_desktop_host_pool.regex, local.legacy_az.virtual_desktop_host_pool.name_unique)) > 0
    }
    virtual_desktop_scaling_plan = {
      valid_name        = length(regexall(local.legacy_az.virtual_desktop_scaling_plan.regex, local.legacy_az.virtual_desktop_scaling_plan.name)) > 0 && length(local.legacy_az.virtual_desktop_scaling_plan.name) > local.legacy_az.virtual_desktop_scaling_plan.min_length
      valid_name_unique = length(regexall(local.legacy_az.virtual_desktop_scaling_plan.regex, local.legacy_az.virtual_desktop_scaling_plan.name_unique)) > 0
    }
    virtual_desktop_workspace = {
      valid_name        = length(regexall(local.legacy_az.virtual_desktop_workspace.regex, local.legacy_az.virtual_desktop_workspace.name)) > 0 && length(local.legacy_az.virtual_desktop_workspace.name) > local.legacy_az.virtual_desktop_workspace.min_length
      valid_name_unique = length(regexall(local.legacy_az.virtual_desktop_workspace.regex, local.legacy_az.virtual_desktop_workspace.name_unique)) > 0
    }
    virtual_hub = {
      valid_name        = length(regexall(local.legacy_az.virtual_hub.regex, local.legacy_az.virtual_hub.name)) > 0 && length(local.legacy_az.virtual_hub.name) > local.legacy_az.virtual_hub.min_length
      valid_name_unique = length(regexall(local.legacy_az.virtual_hub.regex, local.legacy_az.virtual_hub.name_unique)) > 0
    }
    virtual_machine = {
      valid_name        = length(regexall(local.legacy_az.virtual_machine.regex, local.legacy_az.virtual_machine.name)) > 0 && length(local.legacy_az.virtual_machine.name) > local.legacy_az.virtual_machine.min_length
      valid_name_unique = length(regexall(local.legacy_az.virtual_machine.regex, local.legacy_az.virtual_machine.name_unique)) > 0
    }
    virtual_machine_extension = {
      valid_name        = length(regexall(local.legacy_az.virtual_machine_extension.regex, local.legacy_az.virtual_machine_extension.name)) > 0 && length(local.legacy_az.virtual_machine_extension.name) > local.legacy_az.virtual_machine_extension.min_length
      valid_name_unique = length(regexall(local.legacy_az.virtual_machine_extension.regex, local.legacy_az.virtual_machine_extension.name_unique)) > 0
    }
    virtual_machine_restore_point_collection = {
      valid_name        = length(regexall(local.legacy_az.virtual_machine_restore_point_collection.regex, local.legacy_az.virtual_machine_restore_point_collection.name)) > 0 && length(local.legacy_az.virtual_machine_restore_point_collection.name) > local.legacy_az.virtual_machine_restore_point_collection.min_length
      valid_name_unique = length(regexall(local.legacy_az.virtual_machine_restore_point_collection.regex, local.legacy_az.virtual_machine_restore_point_collection.name_unique)) > 0
    }
    virtual_machine_scale_set = {
      valid_name        = length(regexall(local.legacy_az.virtual_machine_scale_set.regex, local.legacy_az.virtual_machine_scale_set.name)) > 0 && length(local.legacy_az.virtual_machine_scale_set.name) > local.legacy_az.virtual_machine_scale_set.min_length
      valid_name_unique = length(regexall(local.legacy_az.virtual_machine_scale_set.regex, local.legacy_az.virtual_machine_scale_set.name_unique)) > 0
    }
    virtual_machine_scale_set_extension = {
      valid_name        = length(regexall(local.legacy_az.virtual_machine_scale_set_extension.regex, local.legacy_az.virtual_machine_scale_set_extension.name)) > 0 && length(local.legacy_az.virtual_machine_scale_set_extension.name) > local.legacy_az.virtual_machine_scale_set_extension.min_length
      valid_name_unique = length(regexall(local.legacy_az.virtual_machine_scale_set_extension.regex, local.legacy_az.virtual_machine_scale_set_extension.name_unique)) > 0
    }
    virtual_network = {
      valid_name        = length(regexall(local.legacy_az.virtual_network.regex, local.legacy_az.virtual_network.name)) > 0 && length(local.legacy_az.virtual_network.name) > local.legacy_az.virtual_network.min_length
      valid_name_unique = length(regexall(local.legacy_az.virtual_network.regex, local.legacy_az.virtual_network.name_unique)) > 0
    }
    virtual_network_gateway = {
      valid_name        = length(regexall(local.legacy_az.virtual_network_gateway.regex, local.legacy_az.virtual_network_gateway.name)) > 0 && length(local.legacy_az.virtual_network_gateway.name) > local.legacy_az.virtual_network_gateway.min_length
      valid_name_unique = length(regexall(local.legacy_az.virtual_network_gateway.regex, local.legacy_az.virtual_network_gateway.name_unique)) > 0
    }
    virtual_network_gateway_connection = {
      valid_name        = length(regexall(local.legacy_az.virtual_network_gateway_connection.regex, local.legacy_az.virtual_network_gateway_connection.name)) > 0 && length(local.legacy_az.virtual_network_gateway_connection.name) > local.legacy_az.virtual_network_gateway_connection.min_length
      valid_name_unique = length(regexall(local.legacy_az.virtual_network_gateway_connection.regex, local.legacy_az.virtual_network_gateway_connection.name_unique)) > 0
    }
    virtual_network_peering = {
      valid_name        = length(regexall(local.legacy_az.virtual_network_peering.regex, local.legacy_az.virtual_network_peering.name)) > 0 && length(local.legacy_az.virtual_network_peering.name) > local.legacy_az.virtual_network_peering.min_length
      valid_name_unique = length(regexall(local.legacy_az.virtual_network_peering.regex, local.legacy_az.virtual_network_peering.name_unique)) > 0
    }
    virtual_wan = {
      valid_name        = length(regexall(local.legacy_az.virtual_wan.regex, local.legacy_az.virtual_wan.name)) > 0 && length(local.legacy_az.virtual_wan.name) > local.legacy_az.virtual_wan.min_length
      valid_name_unique = length(regexall(local.legacy_az.virtual_wan.regex, local.legacy_az.virtual_wan.name_unique)) > 0
    }
    vpn_gateway = {
      valid_name        = length(regexall(local.legacy_az.vpn_gateway.regex, local.legacy_az.vpn_gateway.name)) > 0 && length(local.legacy_az.vpn_gateway.name) > local.legacy_az.vpn_gateway.min_length
      valid_name_unique = length(regexall(local.legacy_az.vpn_gateway.regex, local.legacy_az.vpn_gateway.name_unique)) > 0
    }
    vpn_gateway_connection = {
      valid_name        = length(regexall(local.legacy_az.vpn_gateway_connection.regex, local.legacy_az.vpn_gateway_connection.name)) > 0 && length(local.legacy_az.vpn_gateway_connection.name) > local.legacy_az.vpn_gateway_connection.min_length
      valid_name_unique = length(regexall(local.legacy_az.vpn_gateway_connection.regex, local.legacy_az.vpn_gateway_connection.name_unique)) > 0
    }
    vpn_site = {
      valid_name        = length(regexall(local.legacy_az.vpn_site.regex, local.legacy_az.vpn_site.name)) > 0 && length(local.legacy_az.vpn_site.name) > local.legacy_az.vpn_site.min_length
      valid_name_unique = length(regexall(local.legacy_az.vpn_site.regex, local.legacy_az.vpn_site.name_unique)) > 0
    }
    web_application_firewall_policy = {
      valid_name        = length(regexall(local.legacy_az.web_application_firewall_policy.regex, local.legacy_az.web_application_firewall_policy.name)) > 0 && length(local.legacy_az.web_application_firewall_policy.name) > local.legacy_az.web_application_firewall_policy.min_length
      valid_name_unique = length(regexall(local.legacy_az.web_application_firewall_policy.regex, local.legacy_az.web_application_firewall_policy.name_unique)) > 0
    }
    web_application_firewall_policy_rule_group = {
      valid_name        = length(regexall(local.legacy_az.web_application_firewall_policy_rule_group.regex, local.legacy_az.web_application_firewall_policy_rule_group.name)) > 0 && length(local.legacy_az.web_application_firewall_policy_rule_group.name) > local.legacy_az.web_application_firewall_policy_rule_group.min_length
      valid_name_unique = length(regexall(local.legacy_az.web_application_firewall_policy_rule_group.regex, local.legacy_az.web_application_firewall_policy_rule_group.name_unique)) > 0
    }
    windows_virtual_machine = {
      valid_name        = length(regexall(local.legacy_az.windows_virtual_machine.regex, local.legacy_az.windows_virtual_machine.name)) > 0 && length(local.legacy_az.windows_virtual_machine.name) > local.legacy_az.windows_virtual_machine.min_length
      valid_name_unique = length(regexall(local.legacy_az.windows_virtual_machine.regex, local.legacy_az.windows_virtual_machine.name_unique)) > 0
    }
    windows_virtual_machine_scale_set = {
      valid_name        = length(regexall(local.legacy_az.windows_virtual_machine_scale_set.regex, local.legacy_az.windows_virtual_machine_scale_set.name)) > 0 && length(local.legacy_az.windows_virtual_machine_scale_set.name) > local.legacy_az.windows_virtual_machine_scale_set.min_length
      valid_name_unique = length(regexall(local.legacy_az.windows_virtual_machine_scale_set.regex, local.legacy_az.windows_virtual_machine_scale_set.name_unique)) > 0
    }
  }
}
