variable "legacy_mode" {
  type        = bool
  default     = false
  description = "Use the original naming module's slugs where a legacy mapping exists. Other entries use the current catalog defaults. This restores slugs, not historical naming constraints."
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
  description = "Slug overrides keyed by the snake-case JSON catalog key. Overrides take precedence over legacy_mode and catalog defaults. Null uses the selected defaults; an empty string omits the slug."

  validation {
    condition     = var.slug_overrides == null ? true : alltrue([for key in keys(var.slug_overrides) : contains(keys(local.catalog), key)])
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
