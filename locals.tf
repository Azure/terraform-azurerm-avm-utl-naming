locals {
  az = {
    for definition in local.resource_definitions : definition.name => {
      name = substr(join(definition.dashes ? "-" : "", compact([
        definition.dashes ? local.prefix : local.prefix_safe,
        definition.slug,
        definition.dashes ? local.suffix : local.suffix_safe,
      ])), 0, definition.length.max)
      name_unique = substr(join(definition.dashes ? "-" : "", compact([
        definition.dashes ? local.prefix : local.prefix_safe,
        definition.slug,
        definition.dashes ? local.suffix_unique : local.suffix_unique_safe,
      ])), 0, definition.length.max)
      dashes     = definition.dashes
      slug       = definition.slug
      min_length = definition.length.min
      max_length = definition.length.max
      scope      = definition.scope
      regex = templatestring(definition.regex, {
        min_length = definition.length.min
        max_length = definition.length.max
      })
    }
  }
  prefix                 = join("-", var.prefix)
  prefix_safe            = lower(join("", var.prefix))
  random                 = substr(coalesce(var.unique-seed, local.random_safe_generation), 0, var.unique-length)
  random_safe_generation = join("", [random_string.first_letter.result, random_string.main.result])
  resource_definitions = concat(
    jsondecode(file("${path.module}/resourceDefinition.json")),
    jsondecode(file("${path.module}/resourceDefinition_out_of_docs.json")),
  )
  suffix             = join("-", var.suffix)
  suffix_safe        = lower(join("", var.suffix))
  suffix_unique      = join("-", concat(var.suffix, [local.random]))
  suffix_unique_safe = lower(join("", concat(var.suffix, [local.random])))
  validation = {
    for name, definition in local.az : name => {
      valid_name        = length(regexall(definition.regex, definition.name)) > 0 && length(definition.name) > definition.min_length
      valid_name_unique = length(regexall(definition.regex, definition.name_unique)) > 0
    }
  }
}
