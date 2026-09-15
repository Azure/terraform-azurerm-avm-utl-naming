# tflint-ignore: terraform_naming_convention # Deprecated compatibility alias.
variable "unique-include-numbers" {
  type        = bool
  default     = true
  description = "DEPRECATED: Use unique_include_numbers instead. Controls whether the generated seed can contain numbers when unique_include_numbers is null."
}

# tflint-ignore: terraform_naming_convention # Deprecated compatibility alias.
variable "unique-length" {
  type        = number
  default     = 4
  description = "DEPRECATED: Use unique_length instead. Controls the uniqueness suffix length when unique_length is null."
}

# tflint-ignore: terraform_naming_convention # Deprecated compatibility alias.
variable "unique-seed" {
  type        = string
  default     = ""
  description = "DEPRECATED: Use unique_seed instead. Supplies the uniqueness seed when unique_seed is null; an empty or null value selects the state-persisted random seed."
}
