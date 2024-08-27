locals {
  api_url = var.environment == "FORGE" ? "https://ipam-forge.azurewebsites.net" : "https://ipam-live.azurewebsites.net"
}
