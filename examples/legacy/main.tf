module "naming" {
  source = "../.."

  legacy_mode = true
  prefix      = ["Contoso"]
  suffix      = ["Prod"]
  unique_seed = "abcd1234"
}
