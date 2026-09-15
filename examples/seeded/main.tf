module "naming" {
  source = "../.."

  legacy_mode = true
  prefix      = ["example"]
  slug_overrides = {
    storage_account = "store"
  }
  suffix        = ["dev"]
  unique_length = 6
  unique_seed   = "a1b2c3d4"
}
