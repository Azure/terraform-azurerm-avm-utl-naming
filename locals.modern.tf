locals {
  legacy_aliases = flatten([
    for key, definition in local.bundled_catalog : [
      for alias in definition.legacy_outputs : { alias = alias, key = key }
    ]
  ])
  legacy_catalog_keys = {
    for entry in local.legacy_aliases : entry.alias => entry.key
  }
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
      name_unique            = local.unique_name_available[key] ? local.rendered_names[key].name_unique : null
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
      name_unique_available  = local.unique_name_available[key]
      fits_max_length        = definition.max_length == null ? null : local.unique_name_fits[key]
      name_unique_errors     = local.unique_name_errors[key]
      validation_complete    = definition.validation_complete
      validation_notes       = definition.validation_notes
      validation = {
        valid_name        = local.validation_results[key].name
        valid_name_unique = local.unique_name_available[key] ? local.validation_results[key].name_unique : false
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
    key => (
      try(var.slug_overrides[key], null) != null ? "override" :
      try(local.customer_catalog.resources[key].slug, null) != null ? "customer" :
      try(local.manual_catalog.resources[key].slug, null) != null ? "manual" :
      definition.slug_source
    )
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
  trailing_patterns = {
    for key, definition in local.catalog :
    key => length(definition.forbidden_suffixes) == 0 ? null : "/(?:${join("|", [
      for suffix in definition.forbidden_suffixes : "\\Q${replace(suffix, "\\E", "\\E\\\\E\\Q")}\\E"
    ])})+$/"
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
  unique_name_available = {
    for key, definition in local.catalog :
    key => length(local.unique_name_errors[key]) == 0
  }
  unique_name_errors = {
    for key, definition in local.catalog : key => compact([
      local.unique_name_fits[key] ? null : "The unique name exceeds max_length; shorten the template or reduce unique_length. Other catalog entries remain usable.",
      definition.name_kind == "literal" || local.unique_suffix_retained[key] ? null : "Complete unique-token interpolation could not be verified. Use direct interpolation or a whole-token case conversion.",
    ])
  }
  unique_name_fits = {
    for key, definition in local.catalog :
    key => definition.max_length == null ? true : length(local.rendered_names[key].name_unique) <= definition.max_length
  }
  unique_overhead = {
    for key, definition in local.catalog :
    key => max(0, length(templatestring(var.naming_templates.name_unique, merge(local.template_context[key], { name = "x" }))) - 1)
  }
  unique_suffix_retained = {
    for key, definition in local.catalog :
    key => local.random == "" ? true : definition.name_kind == "literal" ? false : alltrue([
      for marker, rendering in local.unique_token_probes[key] :
      strcontains(lower(rendering), marker) &&
      replace(lower(rendering), marker, lower(local.random)) == lower(local.unique_names[key])
    ])
  }
  unique_template_context = {
    for key, definition in local.catalog : key => merge(local.template_context[key], {
      name = local.trailing_patterns[key] == null ? local.unique_base[key] : replace(local.unique_base[key], local.trailing_patterns[key], "")
    })
  }
  unique_templates_rendered = {
    for key, definition in local.catalog :
    key => templatestring(var.naming_templates.name_unique, local.unique_template_context[key])
  }
  unique_token_probes = {
    for key, definition in local.catalog : key => {
      for marker in ["avmuniquemarker${sha256(key)}a", "avmuniquemarker${sha256(key)}b"] :
      marker => templatestring(var.naming_templates.name_unique, merge(local.unique_template_context[key], { unique = marker }))
    }
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
