# IMPORTANT: This resource is used to add or modify properties on an existing resource.
# When delete azapi_update_resource, no operation will be performed, and these properties will stay unchanged.
# If you want to restore the modified properties to some values, you must apply the restored properties before deleting.

resource "azapi_update_resource" "vwan_routing_intent_and_policies" {
  type      = "Microsoft.Network/virtualHubs/hubRouteTables@2024-07-01"
  parent_id = var.vhub_resource_id
  name      = "defaultRouteTable"

  body = {
    properties = {
      labels = ["default"]
      routes = [
        {
          destinations    = var.onpremises_address_ranges
          destinationType = "CIDR"
          name            = "private_traffic"
          nextHop         = var.firewall_resource_id
          nextHopType     = "ResourceId"
        }
      ]
    }
  }
}
