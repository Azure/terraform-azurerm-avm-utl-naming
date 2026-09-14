mock_provider "random" {}

variables {
  unique-seed = "a1b2c3d4"
}

run "json_catalog" {
  command = apply

  assert {
    condition = length(output.names) == length(concat(
      jsondecode(file("resourceDefinition.json")),
      jsondecode(file("resourceDefinition_out_of_docs.json")),
    ))
    error_message = "Every definition from both JSON files must be available through names."
  }

  assert {
    condition = alltrue([
      for name, definition in output.names :
      length(definition.name) <= definition.max_length &&
      length(definition.name_unique) <= definition.max_length &&
      can(regexall(definition.regex, definition.name))
    ])
    error_message = "Catalog regexes must be valid RE2 expressions and names must respect their maximum lengths."
  }

  assert {
    condition = (
      output.load_test.regex == "^[a-zA-Z][a-zA-Z0-9-_]{0,62}[a-zA-Z0-9|]$" &&
      output.machine_learning_registry.regex == "^[a-zA-Z0-9][a-zA-Z0-9_-]{2,32}$"
    )
    error_message = "JSON regex templates must render with each definition's length limits."
  }
}

run "mixed_case" {
  command = apply

  variables {
    prefix        = ["Co", "RE"]
    suffix        = ["App", "Dev"]
    unique-length = 6
    unique-seed   = "Ab9XyZ"
  }

  assert {
    condition = jsonencode({
      for name in keys(jsondecode(file("tests/unit/fixtures/mixed_case.json")).names) :
      name => [output.names[name].name, output.names[name].name_unique]
    }) == jsonencode(jsondecode(file("tests/unit/fixtures/mixed_case.json")).names)
    error_message = "Mixed-case components and seeds must preserve legacy names for every resource."
  }

  assert {
    condition = jsonencode({
      for name in keys(jsondecode(file("tests/unit/fixtures/mixed_case.json")).validation) :
      name => output.validation[name]
    }) == jsonencode(jsondecode(file("tests/unit/fixtures/mixed_case.json")).validation)
    error_message = "Mixed-case validation must retain the legacy results."
  }
}

run "empty_components" {
  command = apply

  variables {
    prefix      = ["", "a", ""]
    suffix      = ["", "b", ""]
    unique-seed = "t1e2s3t4"
  }

  assert {
    condition = jsonencode({
      for name in keys(jsondecode(file("tests/unit/fixtures/empty_components.json")).names) :
      name => [output.names[name].name, output.names[name].name_unique]
    }) == jsonencode(jsondecode(file("tests/unit/fixtures/empty_components.json")).names)
    error_message = "Empty components must retain the legacy separator behavior."
  }

  assert {
    condition = jsonencode({
      for name in keys(jsondecode(file("tests/unit/fixtures/empty_components.json")).validation) :
      name => output.validation[name]
    }) == jsonencode(jsondecode(file("tests/unit/fixtures/empty_components.json")).validation)
    error_message = "Empty-component validation must retain the legacy results."
  }
}

run "maximum_length_truncation" {
  command = apply

  variables {
    prefix      = [join("", [for i in range(600) : "Ab"])]
    suffix      = ["Production"]
    unique-seed = "seed123"
  }

  assert {
    condition = jsonencode({
      for name in keys(jsondecode(file("tests/unit/fixtures/truncated.json")).names) :
      name => [output.names[name].name, output.names[name].name_unique]
    }) == jsonencode(jsondecode(file("tests/unit/fixtures/truncated.json")).names)
    error_message = "Truncation must preserve the legacy result, including truncated-away uniqueness."
  }

  assert {
    condition = alltrue([
      for name, definition in output.names :
      length(definition.name) == definition.max_length &&
      length(definition.name_unique) == definition.max_length
    ])
    error_message = "Long components must be truncated at each resource's exact maximum length."
  }

  assert {
    condition = jsonencode({
      for name in keys(jsondecode(file("tests/unit/fixtures/truncated.json")).validation) :
      name => output.validation[name]
    }) == jsonencode(jsondecode(file("tests/unit/fixtures/truncated.json")).validation)
    error_message = "Truncated-name validation must retain the legacy results."
  }
}

run "punctuation" {
  command = apply

  variables {
    prefix = ["a.b_(c)", "x"]
    suffix = ["y_z", "q"]
  }

  assert {
    condition = jsonencode({
      for name in keys(jsondecode(file("tests/unit/fixtures/punctuation.json")).names) :
      name => [output.names[name].name, output.names[name].name_unique]
    }) == jsonencode(jsondecode(file("tests/unit/fixtures/punctuation.json")).names)
    error_message = "Punctuation must not be silently sanitized."
  }

  assert {
    condition = jsonencode({
      for name in keys(jsondecode(file("tests/unit/fixtures/punctuation.json")).validation) :
      name => output.validation[name]
    }) == jsonencode(jsondecode(file("tests/unit/fixtures/punctuation.json")).validation)
    error_message = "JSON backslashes and quotes must preserve the legacy regex semantics."
  }
}

run "short_seed" {
  command = apply

  variables {
    suffix        = ["Dev"]
    unique-length = 8
    unique-seed   = "Z"
  }

  assert {
    condition = jsonencode({
      for name in keys(jsondecode(file("tests/unit/fixtures/short_seed.json")).names) :
      name => [output.names[name].name, output.names[name].name_unique]
    }) == jsonencode(jsondecode(file("tests/unit/fixtures/short_seed.json")).names)
    error_message = "A short seed must not be padded or replaced."
  }

  assert {
    condition     = output.unique-seed == "Z"
    error_message = "The seed output must retain the complete supplied value."
  }

  assert {
    condition = jsonencode({
      for name in keys(jsondecode(file("tests/unit/fixtures/short_seed.json")).validation) :
      name => output.validation[name]
    }) == jsonencode(jsondecode(file("tests/unit/fixtures/short_seed.json")).validation)
    error_message = "Short-seed validation must retain the legacy results."
  }
}

run "zero_length" {
  command = apply

  variables {
    prefix        = ["a"]
    suffix        = ["b"]
    unique-length = 0
    unique-seed   = "abc123"
  }

  assert {
    condition = jsonencode({
      for name in keys(jsondecode(file("tests/unit/fixtures/zero_length.json")).names) :
      name => [output.names[name].name, output.names[name].name_unique]
    }) == jsonencode(jsondecode(file("tests/unit/fixtures/zero_length.json")).names)
    error_message = "A zero-length uniqueness suffix must retain legacy trailing separators."
  }

  assert {
    condition = jsonencode({
      for name in keys(jsondecode(file("tests/unit/fixtures/zero_length.json")).validation) :
      name => output.validation[name]
    }) == jsonencode(jsondecode(file("tests/unit/fixtures/zero_length.json")).validation)
    error_message = "Zero-length validation must retain the legacy results."
  }
}

run "negative_length" {
  command = apply

  variables {
    unique-length = -1
    unique-seed   = "seedabcd"
  }

  assert {
    condition = jsonencode({
      for name in keys(jsondecode(file("tests/unit/fixtures/negative_length.json")).names) :
      name => [output.names[name].name, output.names[name].name_unique]
    }) == jsonencode(jsondecode(file("tests/unit/fixtures/negative_length.json")).names)
    error_message = "The legacy substr length of -1 must continue to select the full seed."
  }

  assert {
    condition = jsonencode({
      for name in keys(jsondecode(file("tests/unit/fixtures/negative_length.json")).validation) :
      name => output.validation[name]
    }) == jsonencode(jsondecode(file("tests/unit/fixtures/negative_length.json")).validation)
    error_message = "Full-seed validation must retain the legacy results."
  }
}

run "legacy_validation_boundaries" {
  command = apply

  assert {
    condition = (
      output.application_insights.name == "appi" &&
      output.application_insights.min_length == 10 &&
      output.validation.application_insights.valid_name == false &&
      output.validation.application_insights.valid_name_unique == true &&
      output.machine_learning_registry.name == "mlr" &&
      output.machine_learning_registry.min_length == 3 &&
      output.validation.machine_learning_registry.valid_name == false &&
      output.validation.machine_learning_registry.valid_name_unique == true
    )
    error_message = "Legacy validation uses an exclusive minimum for name and regex-only checks for name_unique."
  }
}
