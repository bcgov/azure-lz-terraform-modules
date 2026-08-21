provider "azurerm" {
  features {}
}

# Include the additional policies and override archetypes
provider "alz" {
  library_overwrite_enabled = true
  library_references = [
    {
      path = "platform/alz",
      ref  = "2026.08.0" # Loads ALZ library assets for https://github.com/Azure/Azure-Landing-Zones-Library/tree/platform/alz/2026.08.0/platform/alz
    },
    {
      custom_url = "${path.root}/lib"
    }
  ]
  suppress_warning_policy_role_assignments = true
}
