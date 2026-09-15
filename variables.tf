variable "custom_override_file" {
  type        = string
  default     = null
  description = "Path to a customer JSON naming catalog, merged after the generated and bundled manual catalogs. Its schema_version must be 2 and resources must map snake-case keys to complete or partial entries. Only supplied properties replace earlier values; omitted properties and unrelated keys are retained. Arrays and nested metadata objects replace as whole properties. A new entry requires a string slug; unknown constraints remain null. Relative paths resolve from the Terraform working directory; use path.module for a caller-local file. Ignored in legacy_mode."

  validation {
    condition     = var.legacy_mode || var.custom_override_file == null ? true : can(file(var.custom_override_file))
    error_message = "custom_override_file must identify a readable local UTF-8 file."
  }
}

variable "legacy_mode" {
  type        = bool
  default     = false
  description = "Use the frozen original renderer for the deprecated named outputs, including original separators, casing, bounds, regexes, scope values, and validation booleans. Modern dynamic outputs are empty in this mode; modern catalogs, customer override files, templates, and slug overrides are ignored."
  nullable    = false
}

variable "naming_template_variables" {
  type        = map(string)
  default     = {}
  description = "Additional string tokens available to modern naming templates. Built-in token names cannot be replaced."
  nullable    = false

  validation {
    condition = var.legacy_mode ? true : length(setintersection(toset(keys(var.naming_template_variables)), toset([
      "name", "prefix", "suffix", "slug", "separator", "unique", "unique_seed",
      "terraform_key", "resource_type", "variant", "min_length", "max_length",
    ]))) == 0
    error_message = "naming_template_variables must not replace built-in naming tokens."
  }
}

variable "naming_templates" {
  type = object({
    name        = optional(string, "$${join(separator, compact([join(separator, prefix), slug, join(separator, suffix)]))}")
    name_unique = optional(string, "$${join(separator, compact([name, unique]))}")
  })
  default     = {}
  description = "Modern templates rendered with templatestring. Escape interpolation as $${token} in HCL. The name_unique template receives a bounded name and must interpolate the full unique token directly or through a whole-token case conversion. Unverifiable or oversized unique names are null with per-entry diagnostics, not catalog-wide failures. Available tokens are name (unique template only), prefix/suffix lists, slug, separator, unique, unique_seed, terraform_key, resource_type, variant, min_length, max_length, and naming_template_variables. Ignored in legacy_mode."
  nullable    = false
}

variable "prefix" {
  type        = list(string)
  default     = []
  description = "Name components placed before the resource slug. Prefer suffixes when following Azure naming recommendations."
  nullable    = false
}

variable "slug_overrides" {
  type        = map(string)
  default     = null
  description = "Modern slug overrides keyed by the snake-case JSON catalog key, taking precedence over all bundled and customer files. Null uses the merged catalog slug; an empty string omits the slug. Ignored in legacy_mode so the frozen renderer remains unchanged."

  validation {
    condition     = var.legacy_mode || var.slug_overrides == null ? true : alltrue([for key in keys(var.slug_overrides) : contains(keys(local.catalog), key)])
    error_message = "Every slug_overrides key must identify an entry in the naming catalog."
  }
}

variable "suffix" {
  type        = list(string)
  default     = []
  description = "Name components placed after the resource slug. Lowercase components are recommended."
  nullable    = false
}

variable "unique_include_numbers" {
  type        = bool
  default     = null
  description = "Whether the generated uniqueness seed can contain numbers. A non-null value takes precedence over unique-include-numbers. The effective default is true. A supplied unique_seed is used unchanged."
}

variable "unique_length" {
  type        = number
  default     = null
  description = "Maximum number of seed characters appended to unique names before maximum-length truncation. A non-null value takes precedence over unique-length. The effective default is 4."
}

variable "unique_seed" {
  type        = string
  default     = null
  description = "Custom uniqueness seed. A non-null value takes precedence over unique-seed, including an empty string, which selects the state-persisted random seed. If neither input supplies a nonempty seed, a random seed beginning with a lowercase letter is used."
}
