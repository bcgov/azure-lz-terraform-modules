# IMPORTANT: This resource is used to add or modify properties on an existing resource.
# When delete azapi_update_resource, no operation will be performed, and these properties will stay unchanged.
# If you want to restore the modified properties to some values, you must apply the restored properties before deleting.

resource "azapi_update_resource" "vwan_routing_intent_and_policies" {
  type        = "Microsoft.Network/virtualHubs@2024-07-01"
  resource_id = data.azurerm_firewall_policy.this.id

  body = {
    properties = {
    }
  }
}
