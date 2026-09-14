terraform {
  required_version = ">= 1.9, < 2.0"

  required_providers {
    random = {
      source  = "hashicorp/random"
      version = ">= 3.3.2, < 4.0"
    }
  }
}
