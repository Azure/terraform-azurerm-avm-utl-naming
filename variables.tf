variable "prefix" {
  type        = list(string)
  default     = []
  description = "Name components placed before the resource slug. Prefer suffixes when following Azure naming recommendations."
  nullable    = false
}

variable "suffix" {
  type        = list(string)
  default     = []
  description = "Name components placed after the resource slug. Lowercase components are recommended."
  nullable    = false
}

# tflint-ignore: terraform_naming_convention # Legacy public input retained for drop-in compatibility.
variable "unique-include-numbers" {
  type        = bool
  default     = true
  description = "Whether the generated uniqueness seed can contain numbers. A supplied unique-seed is used unchanged."
}

# tflint-ignore: terraform_naming_convention # Legacy public input retained for drop-in compatibility.
variable "unique-length" {
  type        = number
  default     = 4
  description = "Maximum number of seed characters appended to unique names, before the resource's maximum-length truncation."
}

# tflint-ignore: terraform_naming_convention # Legacy public input retained for drop-in compatibility.
variable "unique-seed" {
  type        = string
  default     = ""
  description = "Custom uniqueness seed. An empty or null value uses a state-persisted random seed beginning with a lowercase letter."
}
