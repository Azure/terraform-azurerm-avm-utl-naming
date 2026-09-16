locals {
  default_instance_name_template = "$${join(separator, compact([join(separator, prefix), slug, join(separator, suffix), instance]))}"
  default_instance_template      = local.instance_enabled && (var.naming_templates.name == null || var.naming_templates.name == local.default_instance_name_template)
  default_name_template          = "$${join(separator, compact([join(separator, prefix), slug, join(separator, suffix)]))}"
  default_unique_template        = "$${join(separator, compact([name, unique]))}"
  instance_enabled               = !var.legacy_mode && var.instance != null
  instance_value                 = local.instance_enabled ? try(format(var.instance_format, var.instance), "") : ""
  name_template = var.naming_templates.name != null ? var.naming_templates.name : (
    local.instance_enabled ? local.default_instance_name_template :
    local.default_name_template
  )
  default_name_base = {
    for key, definition in local.catalog :
    key => definition.lowercase ? lower(local.default_names_rendered[key]) : local.default_names_rendered[key]
  }
  default_names_rendered = {
    for key, definition in local.catalog :
    key => templatestring(local.default_name_template, local.template_context[key])
  }
  instance_overhead = {
    for key, definition in local.catalog :
    key => length(local.instance_value) + (local.default_name_base[key] == "" ? 0 : length(local.template_context[key].separator))
  }
  instance_prefix_length = {
    for key, definition in local.catalog :
    key => !local.instance_enabled || local.default_instance_template ? null : (
      local.instance_template_interpolated[key] ? length(split(
        keys(local.instance_token_probes[key])[0],
        lower(values(local.instance_token_probes[key])[0]),
      )[0]) : null
    )
  }
  instance_template_interpolated = {
    for key, definition in local.catalog :
    key => !local.instance_enabled ? false : local.default_instance_template ? true : alltrue([
      for marker, rendering in local.instance_token_probes[key] :
      rendering == null ? false : (
        strcontains(lower(rendering), marker) &&
        replace(lower(rendering), marker, lower(local.instance_value)) == lower(local.name_templates_rendered[key])
      )
    ])
  }
  instance_token_probes = {
    for key, definition in local.catalog : key => {
      for marker in ["avminstancemarker${sha256(key)}a", "avminstancemarker${sha256(key)}b"] :
      marker => try(templatestring(local.name_template, merge(local.template_context[key], { instance = marker })), null)
    } if local.instance_enabled && !local.default_instance_template
  }
  instance_unique_base_position = {
    for key, definition in local.catalog :
    key => !local.instance_enabled || definition.name_kind == "literal" ? null : (
      local.default_instance_template ? (
        endswith(lower(local.unique_template_context[key].name), lower(local.instance_value)) ?
        length(local.unique_template_context[key].name) - length(local.instance_value) : null
        ) : local.instance_prefix_length[key] == null ? null : (
        length(local.unique_template_context[key].name) < local.instance_prefix_length[key] + length(local.instance_value) ? null : (
          lower(substr(local.unique_template_context[key].name, local.instance_prefix_length[key], length(local.instance_value))) == lower(local.instance_value) ?
          local.instance_prefix_length[key] : null
        )
      )
    )
  }
  name_instance_retained = {
    for key, definition in local.catalog :
    key => !local.instance_enabled ? true : definition.name_kind == "literal" ? false : (
      definition.name_kind == "uuid" ? local.instance_template_interpolated[key] :
      local.default_instance_template ? endswith(lower(local.rendered_names[key].name), lower(local.instance_value)) :
      local.instance_prefix_length[key] == null ? false : (
        length(local.rendered_names[key].name) < local.instance_prefix_length[key] + length(local.instance_value) ? false :
        lower(substr(local.rendered_names[key].name, local.instance_prefix_length[key], length(local.instance_value))) == lower(local.instance_value)
      )
    )
  }
  unique_instance_token_probes = {
    for key, definition in local.catalog : key => {
      for marker in ["avminstancemarker${sha256(key)}a", "avminstancemarker${sha256(key)}b"] :
      marker => try(templatestring(var.naming_templates.name_unique, merge(local.unique_template_context[key], {
        instance = marker
        # Replace only the proven token position, not coincidental digits in a prefix.
        name = local.instance_unique_base_position[key] == null ? local.unique_template_context[key].name : join("", [
          substr(local.unique_template_context[key].name, 0, local.instance_unique_base_position[key]),
          marker,
          substr(local.unique_template_context[key].name, local.instance_unique_base_position[key] + length(local.instance_value), -1),
        ])
      })), null)
    } if local.instance_enabled && var.naming_templates.name_unique != local.default_unique_template
  }
  unique_name_instance_retained = {
    for key, definition in local.catalog :
    key => !local.instance_enabled ? true : definition.name_kind == "literal" ? false : var.naming_templates.name_unique == local.default_unique_template ? local.instance_unique_base_position[key] != null : alltrue([
      for marker, rendering in local.unique_instance_token_probes[key] :
      rendering == null ? false : (
        strcontains(lower(rendering), marker) &&
        replace(lower(rendering), marker, lower(local.instance_value)) == lower(local.unique_names[key])
      )
    ])
  }
}
