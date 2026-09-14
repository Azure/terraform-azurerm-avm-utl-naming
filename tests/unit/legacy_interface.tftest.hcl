mock_provider "random" {}

run "all_legacy_outputs" {
  command = apply

  module {
    source = "./tests/fixtures/legacy_interface"
  }

  assert {
    condition = jsonencode({
      for name in keys(jsondecode(file("tests/unit/fixtures/baseline.json")).outputs) :
      name => output.naming[name]
    }) == jsonencode(jsondecode(file("tests/unit/fixtures/baseline.json")).outputs)
    error_message = "Every legacy output must retain its name, exact value, and object shape."
  }

  assert {
    condition = alltrue([
      for name in keys(output.naming.names) :
      output.naming.names[name] == output.naming[name]
      if contains(keys(jsondecode(file("tests/unit/fixtures/baseline.json")).outputs), name)
    ])
    error_message = "Legacy named outputs must be aliases of the JSON-backed catalog."
  }
}
