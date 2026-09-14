locals {
  az = {
    for alias, key in local.legacy_catalog_keys : alias => {
      name        = local.names[key].name
      name_unique = local.names[key].name_unique
      dashes      = local.names[key].dashes
      slug        = local.names[key].slug
      min_length  = local.names[key].min_length
      max_length  = local.names[key].max_length
      scope       = local.names[key].scope
      regex       = local.names[key].regex
    }
  }
  case_names = {
    for key, names in local.component_names : key => {
      for name_type, name in names :
      name_type => local.catalog[key].lowercase ? lower(name) : name
    }
  }
  catalog = {
    for entry in local.catalog_entries : entry.key => entry.definition
  }
  catalog_entries = concat(
    [for key, definition in local.generated_catalog.resources : { key = key, definition = definition }],
    [for key, definition in local.manual_catalog.resources : { key = key, definition = definition }],
  )
  component_names = {
    for key, definition in local.catalog : key => {
      name = join(definition.dashes ? "-" : "", compact([
        join(definition.dashes ? "-" : "", var.prefix),
        local.selected_slugs[key],
        join(definition.dashes ? "-" : "", var.suffix),
      ]))
      name_unique = join(definition.dashes ? "-" : "", compact([
        join(definition.dashes ? "-" : "", var.prefix),
        local.selected_slugs[key],
        join(definition.dashes ? "-" : "", concat(var.suffix, local.random == "" ? [] : [local.random])),
      ]))
    }
  }
  generated_catalog = jsondecode(file("${path.module}/data/resource-name-rules.json"))
  legacy_aliases = flatten([
    for key, definition in local.catalog : [
      for alias in definition.legacy_outputs : { alias = alias, key = key }
    ]
  ])
  legacy_catalog_keys = {
    for entry in local.legacy_aliases : entry.alias => entry.key
  }
  manual_catalog = jsondecode(file("${path.module}/data/resource-name-rules.manual.json"))
  names = {
    for key, definition in local.catalog : key => {
      name                = local.rendered_names[key].name
      name_unique         = local.rendered_names[key].name_unique
      dashes              = definition.dashes
      slug                = local.selected_slugs[key]
      slug_source         = local.slug_sources[key]
      min_length          = definition.min_length
      max_length          = definition.max_length
      scope               = definition.scope
      regex               = local.regexes[key]
      resource_type       = definition.resource_type
      terraform_key       = key
      variant             = definition.variant
      name_kind           = definition.name_kind
      unique_seed         = local.unique_seed
      validation_complete = definition.validation_complete
      validation_notes    = definition.validation_notes
      validation = {
        valid_name        = local.validation_results[key].name
        valid_name_unique = local.validation_results[key].name_unique
      }
    }
  }
  names_by_azure_type = {
    for resource_type, keys in local.resource_keys_by_type : resource_type => {
      for key in keys : key => local.names[key]
    }
  }
  random                 = substr(local.unique_seed, 0, var.unique-length)
  random_safe_generation = join("", [random_string.first_letter.result, random_string.main.result])
  regexes = {
    for key, definition in local.catalog :
    key => definition.regex == null ? null : templatestring(definition.regex, {
      min_length = definition.min_length
      max_length = definition.max_length
    })
  }
  rendered_names = {
    for key, definition in local.catalog : key => {
      for name_type, name in local.case_names[key] : name_type => (
        definition.name_kind == "literal" ? definition.fixed_name :
        definition.name_kind == "uuid" ? uuidv5("url", "urn:avm:naming:${key}:${name}") :
        definition.max_length == null ? name : substr(name, 0, definition.max_length)
      )
    }
  }
  resource_keys_by_type = {
    for key, definition in local.catalog :
    definition.resource_type => key... if definition.resource_type != null
  }
  selected_slugs = {
    for key, definition in local.catalog : key => (
      try(var.slug_overrides[key], null) != null ? var.slug_overrides[key] :
      var.legacy_mode && definition.legacy_slug != null ? definition.legacy_slug :
      definition.slug
    )
  }
  slug_sources = {
    for key, definition in local.catalog : key => (
      try(var.slug_overrides[key], null) != null ? "override" :
      var.legacy_mode && definition.legacy_slug != null ? "legacy" :
      definition.slug_source
    )
  }
  unique_seed = coalesce(var.unique-seed, local.random_safe_generation)
  validation = {
    for alias, key in local.legacy_catalog_keys : alias => local.names[key].validation
  }
  validation_results = {
    for key, definition in local.catalog : key => {
      for name_type, name in local.rendered_names[key] :
      name_type => definition.validation_complete ? (
        (definition.min_length == null ? true : length(name) >= definition.min_length) &&
        (definition.max_length == null ? true : length(name) <= definition.max_length) &&
        (local.regexes[key] == null ? true : length(regexall(local.regexes[key], name)) > 0) &&
        alltrue([for prefix in definition.forbidden_prefixes : !startswith(name, prefix)]) &&
        alltrue([for suffix in definition.forbidden_suffixes : !endswith(name, suffix)]) &&
        alltrue([for sequence in definition.forbidden_sequences : !strcontains(name, sequence)]) &&
        !contains([for reserved in definition.reserved_names : lower(reserved)], lower(name))
      ) : null
    }
  }
}
