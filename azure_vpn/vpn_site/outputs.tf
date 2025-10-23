output "vpn_site" {
  description = "A map of VPN Sites created."
  value = {
    for site in azurerm_vpn_site.this :
    site.name => {
      id             = site.id
      name           = site.name
      virtual_wan_id = site.virtual_wan_id
      link           = site.link
      address_cidrs  = site.address_cidrs
      device_model   = site.device_model
      device_vendor  = site.device_vendor
      o365_policy    = site.o365_policy
      tags           = site.tags
    }
  }
}

# output "vpn_site_id" {
#   description = "The ID of the VPN Site."
#   value       = azurerm_vpn_site.this.id
# }

# output "vpn_site_name" {
#   description = "The name of the VPN Site."
#   value       = azurerm_vpn_site.this.name
# }

# output "vpn_site_virtual_wan_id" {
#   description = "The ID of the Virtual WAN that the VPN Site is associated with."
#   value       = azurerm_vpn_site.this.virtual_wan_id
# }

# output "vpn_site_link" {
#   description = "The link block of the VPN Site."
#   value       = azurerm_vpn_site.this.link
# }

# output "vpn_site_address_cidrs" {
#   description = "The list of address CIDRs for the VPN Site."
#   value       = azurerm_vpn_site.this.address_cidrs
# }

# output "vpn_site_device_model" {
#   description = "The device model for the VPN Site."
#   value       = azurerm_vpn_site.this.device_model
# }

# output "vpn_site_device_vendor" {
#   description = "The device vendor for the VPN Site."
#   value       = azurerm_vpn_site.this.device_vendor
# }

# output "vpn_site_o365_policy" {
#   description = "The O365 policy for the VPN Site."
#   value       = azurerm_vpn_site.this.o365_policy
# }
