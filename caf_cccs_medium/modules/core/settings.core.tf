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
        Deploy-Private-DNS-PSQL = {
          privateDnsZoneId : "/subscriptions/${var.subscription_id_connectivity}/resourceGroups/${var.root_id}-dns/providers/Microsoft.Network/privateDnsZones/privatelink.postgres.database.azure.com",
          location : var.primary_location,
        },
        Audit-ZoneResiliency = {
          effect = "Disabled",
        },
      }
      access_control = {}
    }
    management = {
      parameters = {
        Deploy-Log-Analytics = {
          # This is to seperate out the log analytics policy sku from the log analytics workspace resource sku
          sku = "pergb2018"
        }
      }
    }
    landing-zones = {
      parameters = {
        Allowed-Locations = {
          listOfAllowedLocations = [var.primary_location, var.secondary_location]
          listOfAllowedServices  = ["Microsoft.PowerPlatform/accounts"]
        },
        Deny-RSG-Locations = {
          listOfAllowedLocations = [var.primary_location, var.secondary_location]
        },
        Deploy-VMSS-Monitoring = {
          scopeToSupportedImages = true
        },
        Deny-VNet-DNS-Changes = {
          # VNet-DNS-Settings = var.root_id == "bcgov-managed-lz-forge" ? ["10.41.253.4"] : ["10.53.244.4"]
          VNet-DNS-Settings = var.VNet-DNS-Settings
        }
      }
      access_control = {}
    }
  }
}
