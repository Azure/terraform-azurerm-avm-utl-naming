module "naming" {
  source = "../.."

  prefix        = ["example"]
  suffix        = ["dev"]
  unique-length = 6
  unique-seed   = "a1b2c3d4"
}
