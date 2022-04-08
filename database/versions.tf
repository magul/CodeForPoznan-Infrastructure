terraform {
  required_providers {
    postgresql = {
      source = "cyrilgdn/postgresql"
    }
    random = {
      source = "hashicorp/random"
    }
  }
  required_version = ">= 1.1.8"
}
