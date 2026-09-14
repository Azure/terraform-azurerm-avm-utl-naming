module "naming" {
  source = "../.."

  legacy_mode = true
  prefix      = ["example"]
  slug_overrides = {
    storage_account = "store"
  }
  suffix        = ["dev"]
  unique-length = 6
  unique-seed   = "a1b2c3d4"
}
