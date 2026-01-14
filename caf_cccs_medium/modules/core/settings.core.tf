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
          location : var.primary_location
        }
        Deploy-Private-DNS-APIM = {
          privateDnsZoneId : "/subscriptions/${var.subscription_id_connectivity}/resourceGroups/${var.root_id}-dns/providers/Microsoft.Network/privateDnsZones/privatelink.azure-api.net",
          location : var.primary_location
        }
        Deploy-Private-DNS-CgSrv = {
          cognitiveServicesPrivateDnsZoneId : "/subscriptions/${var.subscription_id_connectivity}/resourceGroups/${var.root_id}-dns/providers/Microsoft.Network/privateDnsZones/privatelink.cognitiveservices.azure.com",
          openAIPrivateDnsZoneId : "/subscriptions/${var.subscription_id_connectivity}/resourceGroups/${var.root_id}-dns/providers/Microsoft.Network/privateDnsZones/privatelink.openai.azure.com",
          aiServicesPrivateDnsZoneId : "/subscriptions/${var.subscription_id_connectivity}/resourceGroups/${var.root_id}-dns/providers/Microsoft.Network/privateDnsZones/privatelink.services.ai.azure.com"
        },
        Deploy-Private-DNS-PSQL = {
          privateDnsZoneId : "/subscriptions/${var.subscription_id_connectivity}/resourceGroups/${var.root_id}-dns/providers/Microsoft.Network/privateDnsZones/privatelink.postgres.database.azure.com",
          location : var.primary_location
        },
        Deploy-Private-DNS-ACA = {
          defaultPrivateDnsZoneId : "/subscriptions/${var.subscription_id_connectivity}/resourceGroups/${var.root_id}-dns/providers/Microsoft.Network/privateDnsZones/privatelink.${lower(var.primary_location)}.azurecontainerapps.io"
        },
        Audit-ZoneResiliency = {
          effect = "Disabled",
        },
        Network-Watcher-storageId = {
          # /subscriptions/40e13180-2fb8-4399-8931-f0c3eefb3e14/resourceGroups/network-flow-logs-live/providers/Microsoft.Storage/storageAccounts/networkflowlogslive
          value = "/subscriptions/${var.subscription_id_management}/resourceGroups/${var.network_watcher_storage_account_resource_group}/providers/Microsoft.Storage/storageAccounts/${var.network_watcher_storage_account_name}"
        },
        Network-Watcher-workspaceResourceId = {
          # /subscriptions/40e13180-2fb8-4399-8931-f0c3eefb3e14/resourceGroups/bcgov-managed-lz-live-mgmt/providers/Microsoft.OperationalInsights/workspaces/bcgov-managed-lz-live-la
          value = "/subscriptions/${var.subscription_id_management}/resourceGroups/${var.root_id}/providers/Microsoft.OperationalInsights/workspaces/${var.root_id}-la"
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
        Resource-Locations = {
          listOfAllowedLocations = [var.primary_location, var.secondary_location]
          extraAllowedLocations  = [var.country_location]
        },
        Deny-RSG-Locations = {
          listOfAllowedLocations = [var.primary_location, var.secondary_location]
        },
        Deploy-VMSS-Monitoring = {
          scopeToSupportedImages = true
        },
        Deny-VNet-DNS-Changes = {
          VNet-DNS-Settings = var.VNet-DNS-Settings
        }
      }
      access_control = {}
    }
  }
}
