# IMPORTANT: This resource is used to add or modify properties on an existing resource.
# When delete azapi_update_resource, no operation will be performed, and these properties will stay unchanged.
# If you want to restore the modified properties to some values, you must apply the restored properties before deleting.

resource "azapi_update_resource" "fwpolicy_threat_intel_allow_list" {
  type        = "Microsoft.Network/firewallPolicies@2024-03-01"
  resource_id = data.azurerm_firewall_policy.this.id

  body = {
    properties = {
      threatIntelWhitelist = {
        # fqdns = try(local.fqdn_names, [])
        # ipAddresses = try(local.ip_addresses, [])
        fqdns       = []
        ipAddresses = []
      }
    }
  }
}

resource "azapi_update_resource" "fwpolicy_idps" {
  type        = "Microsoft.Network/firewallPolicies@2024-03-01"
  resource_id = data.azurerm_firewall_policy.this.id

  body = {
    properties = {
      intrusionDetection = {
        mode = "Alert" # Allowed values: "Alert", "Deny", "Off"
        configuration = {
          # bypassTrafficSettings = []
          privateRanges = var.idps_private_ip_ranges
          signatureOverrides = [
            {
              id     = "1000000001"
              action = "Alert" # Allowed values: "Alert", "Deny", "Off"
            }
          ]
        }
      }
    }
  }
}
