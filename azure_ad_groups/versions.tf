terraform {
  required_version = ">= 1.4.0"

  required_providers {
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 3.9"
    }

    null = {
      source  = "hashicorp/null"
      version = "~> 3.2"
    }
  }
}
