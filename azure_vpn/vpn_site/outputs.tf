output "vpn_site_id" {
  description = "The ID of the VPN Site."
  value       = azurerm_vpn_site.this.id
}

output "vpn_site_link" {
  description = "The link block of the VPN Site."
  value       = azurerm_vpn_site.this.link
}
