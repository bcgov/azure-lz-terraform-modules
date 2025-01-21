locals {
  archetype_config_overrides = {
    root = {
      parameters = {
        CanadaFederalPBMM = {
          logAnalyticsWorkspaceIdforVMReporting                  = "/subscriptions/${var.subscription_id_management}/resourceGroups/${var.root_id}-mgmt/providers/Microsoft.OperationalInsights/workspaces/${var.root_id}-la",
          listOfMembersToExcludeFromWindowsVMAdministratorsGroup = "",
          listOfMembersToIncludeInWindowsVMAdministratorsGroup   = ""
        }
        Deploy-Private-DNS-Sql = {
          privateDnsZoneId : "/subscriptions/${var.subscription_id_connectivity}/resourceGroups/${var.root_id}-dns/providers/Microsoft.Network/privateDnsZones/privatelink.database.windows.net",
          location : var.primary_location,
        }
        Deploy-Private-DNS-OAI = {
          defaultPrivateDnsZoneId : "/subscriptions/${var.subscription_id_connectivity}/resourceGroups/${var.root_id}-dns/providers/Microsoft.Network/privateDnsZones/privatelink.cognitiveservices.azure.com",
          openaiPrivateDnsZoneId : "/subscriptions/${var.subscription_id_connectivity}/resourceGroups/${var.root_id}-dns/providers/Microsoft.Network/privateDnsZones/privatelink.openai.azure.com"
        }
      }
      access_control = {}
    }
    landing-zones = {
      parameters = {
        Deny-Resource-Locations = {
          listOfAllowedLocations = [var.primary_location, var.secondary_location]
        }
        Deny-RSG-Locations = {
          listOfAllowedLocations = [var.primary_location, var.secondary_location]
        }
        Deploy-VMSS-Monitoring = {
          scopeToSupportedImages = true
        },
        Deny-VNet-DNS-Changes = {
          VNet-DNS-Settings = var.root_id == "bcgov-managed-lz-forge" ? ["10.41.253.4", "10.41.253.5"] : ["10.53.244.4"]
        }
      }
      access_control = {}
    }
  }
}
