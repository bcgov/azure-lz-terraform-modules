terraform {
  required_version = ">= 1.4.0"

  required_providers {
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 3.8"
    }

    null = {
      source  = "hashicorp/null"
      version = "~> 3.0"
    }
  }
}
