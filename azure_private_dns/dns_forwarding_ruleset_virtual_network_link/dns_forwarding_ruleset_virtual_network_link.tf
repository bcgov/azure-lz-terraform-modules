resource "azapi_resource" "dns_forwarding_ruleset_virtual_network_link" {
  type      = "Microsoft.Network/dnsForwardingRulesets/virtualNetworkLinks@2025-05-01"
  name      = var.link_name                 # Name of the DNS Forwarding Ruleset Virtual Network Link
  parent_id = var.dns_forwarding_ruleset_id # DNS Forwarding Ruleset ID
  body = {
    properties = {
      # metadata = {
      #   {customized property} = "string"
      # }
      virtualNetwork = {
        id = var.virtual_network_object.id # ID of the Virtual Network to link
      }
    }
  }
}
