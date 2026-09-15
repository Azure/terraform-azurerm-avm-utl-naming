locals {
  catalog = {
    for key, definition in local.catalog_defaults : key => merge(
      definition,
      try(local.manual_catalog.overrides[key].settings, {}),
      try(local.manual_catalog.overrides[key].settings.slug, null) != null ? { slug_source = "manual" } : {},
    )
  }
  catalog_defaults = {
    for entry in local.catalog_entries : entry.key => entry.definition
  }
  catalog_entries = concat(
    [for key, definition in local.generated_catalog.resources : { key = key, definition = definition }],
    [for key, definition in local.manual_catalog.resources : { key = key, definition = definition }],
  )
  generated_catalog = jsondecode(var.legacy_mode ? jsonencode({ schema_version = 2, resources = {} }) : file("${path.module}/data/resource-name-rules.json"))
  legacy_aliases = flatten([
    for key, definition in local.catalog : [
      for alias in definition.legacy_outputs : { alias = alias, key = key }
    ]
  ])
  legacy_catalog_keys = {
    for entry in local.legacy_aliases : entry.alias => entry.key
  }
  manual_catalog = jsondecode(var.legacy_mode ? jsonencode({ schema_version = 2, resources = {} }) : file("${path.module}/data/resource-name-rules.manual.json"))
  modern_aliases = {
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
  modern_alias_validation = {
    for alias, key in local.legacy_catalog_keys : alias => local.names[key].validation
  }
  name_base = {
    for key, definition in local.catalog :
    key => definition.lowercase ? lower(local.name_templates_rendered[key]) : local.name_templates_rendered[key]
  }
  name_bounded = {
    for key, definition in local.catalog :
    key => definition.max_length == null ? local.name_base[key] : substr(local.name_base[key], 0, definition.max_length)
  }
  name_templates_rendered = {
    for key, definition in local.catalog :
    key => templatestring(var.naming_templates.name, local.template_context[key])
  }
  names = {
    for key, definition in local.catalog : key => {
      name                   = local.rendered_names[key].name
      name_unique            = local.rendered_names[key].name_unique
      dashes                 = definition.dashes
      slug                   = local.selected_slugs[key]
      slug_source            = local.slug_sources[key]
      min_length             = definition.min_length
      max_length             = definition.max_length
      scope                  = definition.scope
      regex                  = local.regexes[key]
      resource_type          = definition.resource_type
      terraform_key          = key
      variant                = definition.variant
      name_kind              = definition.name_kind
      unique_seed            = local.unique_seed
      unique_suffix_retained = local.unique_suffix_retained[key]
      validation_complete    = definition.validation_complete
      validation_notes       = definition.validation_notes
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
  regexes = {
    for key, definition in local.catalog :
    key => definition.regex == null ? null : templatestring(definition.regex, {
      min_length = definition.min_length
      max_length = definition.max_length
    })
  }
  rendered_names = {
    for key, definition in local.catalog : key => {
      name = (
        definition.name_kind == "literal" ? definition.fixed_name :
        definition.name_kind == "uuid" ? uuidv5("url", "urn:avm:naming:${key}:${local.name_base[key]}") :
        local.trailing_patterns[key] == null ? local.name_bounded[key] :
        replace(local.name_bounded[key], local.trailing_patterns[key], "")
      )
      name_unique = (
        definition.name_kind == "literal" ? definition.fixed_name :
        definition.name_kind == "uuid" ? uuidv5("url", "urn:avm:naming:${key}:${local.unique_names[key]}") :
        local.unique_names[key]
      )
    }
  }
  resource_keys_by_type = {
    for key, definition in local.catalog :
    definition.resource_type => key... if definition.resource_type != null
  }
  selected_slugs = {
    for key, definition in local.catalog :
    key => try(var.slug_overrides[key], null) != null ? var.slug_overrides[key] : definition.slug
  }
  slug_sources = {
    for key, definition in local.catalog :
    key => try(var.slug_overrides[key], null) != null ? "override" : definition.slug_source
  }
  template_context = {
    for key, definition in local.catalog : key => merge(var.naming_template_variables, {
      prefix        = var.prefix
      suffix        = var.suffix
      slug          = local.selected_slugs[key]
      separator     = definition.dashes ? "-" : ""
      unique        = local.random
      unique_seed   = local.unique_seed
      terraform_key = key
      resource_type = definition.resource_type
      variant       = definition.variant
      min_length    = definition.min_length
      max_length    = definition.max_length
    })
  }
  trailing_characters = {
    for key, definition in local.catalog :
    key => join("", [for suffix in definition.forbidden_suffixes : suffix == "-" ? "\\-" : suffix if contains(["-", ".", " "], suffix)])
  }
  trailing_patterns = {
    for key, characters in local.trailing_characters :
    key => characters == "" ? null : "/[${characters}]+$/"
  }
  unique_base = {
    for key, definition in local.catalog :
    key => definition.max_length == null ? local.name_base[key] : substr(
      local.name_base[key], 0, max(0, definition.max_length - local.unique_overhead[key]),
    )
  }
  unique_names = {
    for key, definition in local.catalog :
    key => definition.lowercase ? lower(local.unique_templates_rendered[key]) : local.unique_templates_rendered[key]
  }
  unique_overhead = {
    for key, definition in local.catalog :
    key => max(0, length(templatestring(var.naming_templates.name_unique, merge(local.template_context[key], { name = "x" }))) - 1)
  }
  unique_suffix_retained = {
    for key, definition in local.catalog :
    key => local.random == "" ? true : definition.name_kind == "literal" ? false : strcontains(
      local.unique_names[key], definition.lowercase ? lower(local.random) : local.random,
    )
  }
  unique_templates_rendered = {
    for key, definition in local.catalog :
    key => templatestring(var.naming_templates.name_unique, merge(local.template_context[key], {
      name = local.trailing_patterns[key] == null ? local.unique_base[key] : replace(local.unique_base[key], local.trailing_patterns[key], "")
    }))
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
