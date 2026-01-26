locals {
  # Set the DNS server to the Azure Firewall IP based on the environment
  dns_servers = upper(var.environment) == "FORGE" ? ["10.41.253.4"] : ["10.53.244.4"]

  newbits = (var.virtual_network_address_space - var.github_hosted_runners_subnet_address_prefix)
}
