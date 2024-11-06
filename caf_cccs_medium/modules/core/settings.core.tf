locals {
  archetype_config_overrides = {
    root = {
      parameters = {
        CanadaFederalPBMM = {
          logAnalyticsWorkspaceIdforVMReporting                  = "/subscriptions/${var.subscription_id_management}/resourceGroups/${var.root_id}-mgmt/providers/Microsoft.OperationalInsights/workspaces/${var.root_id}-la",
          listOfMembersToExcludeFromWindowsVMAdministratorsGroup = "",
          listOfMembersToIncludeInWindowsVMAdministratorsGroup   = ""
        },
        "Deploy-Private-DNS-Sql" = {
          privateDnsZoneId : "/subscriptions/${var.subscription_id_connectivity}/resourceGroups/${var.root_id}-dns/providers/Microsoft.Network/privateDnsZones/privatelink.database.windows.net",
        },
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
      }
      access_control = {}
    }
  }
}
