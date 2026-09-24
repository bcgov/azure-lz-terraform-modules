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
      path = "platform/amba"
      ref  = "2026.06.2" # Check the latest library version https://github.com/Azure/Azure-Landing-Zones-Library/tags
    },
    {
      custom_url = "${path.module}/lib" # policy assignments/definitions, role definitions, archetype overrides
    },
    {
      custom_url = "${path.root}/lib" # calling module's custom architecture definition
    }
  ]
  suppress_warning_policy_role_assignments = true
  # Keep the GUID and roleName from the library JSON. The default rewrites both,
  # which would create a second role beside the Forge role the assignments already use.
  role_definitions_use_supplied_names_enabled = true
}
