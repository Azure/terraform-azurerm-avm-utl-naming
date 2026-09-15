module "naming" {
  source = "../.."

  custom_override_file = "${path.module}/naming-overrides.json"
  suffix               = ["workload", "dev"]
  unique_seed          = "abcd1234"
}
