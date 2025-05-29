resource "azapi_resource" "powerbi_data_gateway_subnet" {
  type = "Microsoft.Network/virtualNetworks/subnets@2024-05-01"

  name      = var.data_gateway_subnet_name
  parent_id = data.azurerm_virtual_network.vnet.id
  locks = [
    data.azurerm_virtual_network.vnet.id
  ]

  body = {
    properties = {
      addressPrefix         = var.data_gateway_subnet_address_prefix
      defaultOutboundAccess = false
      delegations = [
        {
          name = "PowerBIDataGateway"
          properties = {
            serviceName = "Microsoft.PowerPlatform/vnetaccesslinks"
          }
        }
      ]
      networkSecurityGroup = {
        id = azurerm_network_security_group.powerbi_data_gateway.id
      }
      serviceEndpoints = [
        {
          locations = [
            "canadacentral",
            "canadaeast"
          ]
          service = "Microsoft.Storage"
        }
      ]
    }
  }
  response_export_values = ["*"]
}
