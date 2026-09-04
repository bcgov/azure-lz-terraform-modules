# Imports pre-existing Private DNS Zone virtual network links (hub "primary") that were created
# outside Terraform's state prior to the first `terraform apply` of this configuration.
# Run `terraform apply` once to bring these into state, then this file can be removed.
# locals {
#   private_dns_zone_network_link_imports = {
#     azure_media_services_delivery       = "privatelink.media.azure.net"
#     azure_bot_svc_bot                   = "privatelink.directline.botframework.com"
#     azure_cosmos_db_gremlin             = "privatelink.gremlin.cosmos.azure.com"
#     azure_log_analytics_data            = "privatelink.ods.opinsights.azure.com"
#     azure_fabric                        = "privatelink.fabric.microsoft.com"
#     azure_maria_db_server               = "privatelink.mariadb.database.azure.com"
#     azure_static_web_apps_partitioned_3 = "privatelink.3.azurestaticapps.net"
#     azure_cosmos_db_postgres            = "privatelink.postgres.cosmos.azure.com"
#     azure_arc_kubernetes                = "privatelink.dp.kubernetesconfiguration.azure.com"
#     azure_backup                        = "privatelink.cnc.backup.windowsazure.com"
#     azure_avd_feed_mgmt                 = "privatelink.wvd.microsoft.com"
#     azure_data_explorer                 = "privatelink.canadacentral.kusto.windows.net"
#     azure_automation                    = "privatelink.azure-automation.net"
#     azure_app_configuration             = "privatelink.azconfig.io"
#     azure_app_service                   = "privatelink.azurewebsites.net"
#     azure_digital_twins                 = "privatelink.digitaltwins.azure.net"
#     azure_service_hub                   = "privatelink.servicebus.windows.net"
#     azure_static_web_apps_partitioned_5 = "privatelink.5.azurestaticapps.net"
#     azure_ml                            = "privatelink.api.azureml.ms"
#   }
# }

# import {
#   for_each = local.private_dns_zone_network_link_imports

#   to = module.connectivity.module.avm-ptn-alz-connectivity-virtual-wan.module.private_dns_zones["primary"].module.avm_res_network_privatednszone[each.key].module.virtual_network_links["primary"].azapi_resource.private_dns_zone_network_link

#   id = "${local.virtual_hubs.primary.private_dns_zones.parent_id}/providers/Microsoft.Network/privateDnsZones/${each.value}/virtualNetworkLinks/vnet_link-${each.key}-primary"
# }
