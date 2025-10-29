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
