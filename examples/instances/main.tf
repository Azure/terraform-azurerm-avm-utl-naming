module "naming" {
  source   = "../.."
  for_each = { for instance in range(1, 21) : tostring(instance) => instance }

  instance      = each.value
  suffix        = ["workload", "dev"]
  unique_length = 0
}
