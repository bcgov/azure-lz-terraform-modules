#------------------------------------------------------------------------------
# Virtual Network
#------------------------------------------------------------------------------

resource "azurerm_virtual_network" "this" {
  name                = local.vnet_name
  location            = var.location
  resource_group_name = azurerm_resource_group.this.name
  address_space       = [local.vnet_address_space]
  dns_servers         = length(var.dns_servers) > 0 ? var.dns_servers : null

  tags = local.tags

  depends_on = [
    azurerm_network_manager_ipam_pool_static_cidr.mccs_observability
  ]

  lifecycle {
    ignore_changes = [tags]
  }
}

#------------------------------------------------------------------------------
# Virtual WAN Hub Connection
#------------------------------------------------------------------------------

resource "azurerm_virtual_hub_connection" "this" {
  name                      = "vhc-${local.vnet_name}"
  virtual_hub_id            = var.virtual_hub_id
  remote_virtual_network_id = azurerm_virtual_network.this.id
  internet_security_enabled = var.internet_security_enabled
}

#------------------------------------------------------------------------------
# Subnets
#------------------------------------------------------------------------------

# Subnet for Azure Container Instances (Netbox, Prometheus)
resource "azurerm_subnet" "containers" {
  name                 = local.subnet_containers
  resource_group_name  = azurerm_resource_group.this.name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = [local.container_subnet_cidr]

  # Service endpoints for storage access (required for ACI file share mounts)
  service_endpoints = ["Microsoft.Storage"]

  delegation {
    name = "aci-delegation"

    service_delegation {
      name = "Microsoft.ContainerInstance/containerGroups"
      actions = [
        "Microsoft.Network/virtualNetworks/subnets/join/action",
        "Microsoft.Network/virtualNetworks/subnets/prepareNetworkPolicies/action"
      ]
    }
  }

  lifecycle {
    # Azure may normalize delegation actions differently
    ignore_changes = [delegation]
  }
}

# Subnet for PostgreSQL Flexible Server
resource "azurerm_subnet" "postgresql" {
  name                 = local.subnet_postgresql
  resource_group_name  = azurerm_resource_group.this.name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = [local.postgresql_subnet_cidr]

  delegation {
    name = "postgresql-delegation"

    service_delegation {
      name = "Microsoft.DBforPostgreSQL/flexibleServers"
      actions = [
        "Microsoft.Network/virtualNetworks/subnets/join/action"
      ]
    }
  }
}

# Subnet for Private Endpoints (Grafana, Key Vault)
resource "azurerm_subnet" "private_endpoints" {
  name                                          = local.subnet_private_endpoints
  resource_group_name                           = azurerm_resource_group.this.name
  virtual_network_name                          = azurerm_virtual_network.this.name
  address_prefixes                              = [local.private_endpoint_subnet_cidr]
  private_endpoint_network_policies             = "Disabled"
  private_link_service_network_policies_enabled = false
}

#------------------------------------------------------------------------------
# Network Security Groups
#------------------------------------------------------------------------------

resource "azurerm_network_security_group" "postgresql" {
  name                = "nsg-${local.subnet_postgresql}"
  location            = var.location
  resource_group_name = azurerm_resource_group.this.name
  tags                = local.tags

  # Allow inbound PostgreSQL from VNet
  security_rule {
    name                       = "AllowPostgreSQLInbound"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "5432"
    source_address_prefix      = "VirtualNetwork"
    destination_address_prefix = "*"
  }

  # Deny all other inbound
  security_rule {
    name                       = "DenyAllInbound"
    priority                   = 4096
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  lifecycle {
    ignore_changes = [tags]
  }
}

resource "azurerm_subnet_network_security_group_association" "postgresql" {
  subnet_id                 = azurerm_subnet.postgresql.id
  network_security_group_id = azurerm_network_security_group.postgresql.id
}

#------------------------------------------------------------------------------
# Private Endpoints
#------------------------------------------------------------------------------

# Private Endpoint for Grafana
resource "azurerm_private_endpoint" "grafana" {
  name                = "pe-${local.grafana_name}"
  location            = var.location
  resource_group_name = azurerm_resource_group.this.name
  subnet_id           = azurerm_subnet.private_endpoints.id
  tags                = local.tags

  private_service_connection {
    name                           = "psc-${local.grafana_name}"
    private_connection_resource_id = azurerm_dashboard_grafana.this.id
    subresource_names              = ["grafana"]
    is_manual_connection           = false
  }

  # Only create DNS zone group if not using DINE policy
  dynamic "private_dns_zone_group" {
    for_each = var.create_private_dns_zone_groups && var.central_grafana_dns_zone_id != null ? [1] : []
    content {
      name                 = "default"
      private_dns_zone_ids = [var.central_grafana_dns_zone_id]
    }
  }

  lifecycle {
    # Ignore DNS zone groups created by DINE policy
    ignore_changes = [tags, private_dns_zone_group]
  }
}

# Private Endpoint for Key Vault
resource "azurerm_private_endpoint" "keyvault" {
  name                = "pe-${local.key_vault_name}"
  location            = var.location
  resource_group_name = azurerm_resource_group.this.name
  subnet_id           = azurerm_subnet.private_endpoints.id
  tags                = local.tags

  private_service_connection {
    name                           = "psc-${local.key_vault_name}"
    private_connection_resource_id = azurerm_key_vault.this.id
    subresource_names              = ["vault"]
    is_manual_connection           = false
  }

  # Only create DNS zone group if not using DINE policy
  dynamic "private_dns_zone_group" {
    for_each = var.create_private_dns_zone_groups && var.central_keyvault_dns_zone_id != null ? [1] : []
    content {
      name                 = "default"
      private_dns_zone_ids = [var.central_keyvault_dns_zone_id]
    }
  }

  lifecycle {
    # Ignore DNS zone groups created by DINE policy
    ignore_changes = [tags, private_dns_zone_group]
  }
}

#------------------------------------------------------------------------------
# Network Security Groups - Container Subnet
#------------------------------------------------------------------------------

resource "azurerm_network_security_group" "containers" {
  name                = "nsg-${local.subnet_containers}"
  location            = var.location
  resource_group_name = azurerm_resource_group.this.name
  tags                = local.tags

  # Allow inbound from VNet for Prometheus scraping and Grafana queries
  # 8080 = Netbox (including /metrics endpoint)
  # 9090 = Prometheus
  security_rule {
    name                       = "AllowVNetInbound"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_ranges    = ["8080", "9090"]
    source_address_prefix      = "VirtualNetwork"
    destination_address_prefix = "*"
  }

  # Allow outbound DNS to custom DNS servers (firewall) for private DNS zone resolution
  # ACI uses explicit dns_config and needs network path to DNS servers
  security_rule {
    name                       = "AllowDNSOutbound"
    priority                   = 100
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "53"
    source_address_prefix      = "*"
    destination_address_prefix = "VirtualNetwork"
  }

  # Allow outbound to VNet for PostgreSQL
  security_rule {
    name                       = "AllowPostgreSQLOutbound"
    priority                   = 110
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "5432"
    source_address_prefix      = "*"
    destination_address_prefix = "VirtualNetwork"
  }

  # Allow outbound to Azure Storage (service endpoint)
  security_rule {
    name                       = "AllowStorageOutbound"
    priority                   = 120
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "445"
    source_address_prefix      = "*"
    destination_address_prefix = "Storage"
  }

  # Allow outbound HTTPS for container image pulls and Azure services
  security_rule {
    name                       = "AllowAzureCloudOutbound"
    priority                   = 130
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "AzureCloud"
  }

  lifecycle {
    ignore_changes = [tags]
  }
}

resource "azurerm_subnet_network_security_group_association" "containers" {
  subnet_id                 = azurerm_subnet.containers.id
  network_security_group_id = azurerm_network_security_group.containers.id
}

resource "azurerm_network_security_group" "private_endpoints" {
  name                = "nsg-${local.subnet_private_endpoints}"
  location            = var.location
  resource_group_name = azurerm_resource_group.this.name
  tags                = local.tags

  # Allow inbound from VNet for private endpoint access
  security_rule {
    name                       = "AllowVNetInbound"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "VirtualNetwork"
    destination_address_prefix = "*"
  }

  lifecycle {
    ignore_changes = [tags]
  }
}

resource "azurerm_subnet_network_security_group_association" "private_endpoints" {
  subnet_id                 = azurerm_subnet.private_endpoints.id
  network_security_group_id = azurerm_network_security_group.private_endpoints.id
}
