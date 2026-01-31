#------------------------------------------------------------------------------
# Windows Jump Box (Bastion Host)
#
# Small Windows VM for accessing private resources via RDP.
# Deployed in the private endpoints subnet.
#------------------------------------------------------------------------------

resource "azurerm_network_interface" "jumpbox" {
  count = var.deploy_jumpbox ? 1 : 0

  name                = "nic-${local.resource_prefix}-jumpbox"
  location            = var.location
  resource_group_name = azurerm_resource_group.this.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.private_endpoints.id
    private_ip_address_allocation = "Dynamic"
  }

  tags = local.tags

  lifecycle {
    ignore_changes = [tags]
  }
}

#------------------------------------------------------------------------------
# Jump Box Network Security Group
#------------------------------------------------------------------------------

resource "azurerm_network_security_group" "jumpbox" {
  count = var.deploy_jumpbox ? 1 : 0

  name                = "nsg-${local.resource_prefix}-jumpbox"
  location            = var.location
  resource_group_name = azurerm_resource_group.this.name

  # Allow RDP from allowed IPs only
  dynamic "security_rule" {
    for_each = length(var.allowed_ip_addresses) > 0 ? [1] : []
    content {
      name                       = "AllowRDPFromAllowedIPs"
      priority                   = 100
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "3389"
      source_address_prefixes    = var.allowed_ip_addresses
      destination_address_prefix = "*"
    }
  }

  # Allow RDP from VNet
  security_rule {
    name                       = "AllowRDPFromVNet"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = "VirtualNetwork"
    destination_address_prefix = "*"
  }

  # Allow outbound to VNet
  security_rule {
    name                       = "AllowVNetOutbound"
    priority                   = 100
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "VirtualNetwork"
  }

  # Allow outbound HTTPS for Azure services
  security_rule {
    name                       = "AllowHTTPSOutbound"
    priority                   = 110
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "Internet"
  }

  tags = local.tags

  lifecycle {
    ignore_changes = [tags]
  }
}

resource "azurerm_network_interface_security_group_association" "jumpbox" {
  count = var.deploy_jumpbox ? 1 : 0

  network_interface_id      = azurerm_network_interface.jumpbox[0].id
  network_security_group_id = azurerm_network_security_group.jumpbox[0].id
}

#------------------------------------------------------------------------------
# Jump Box Admin Password
#------------------------------------------------------------------------------

resource "random_password" "jumpbox_admin" {
  count = var.deploy_jumpbox ? 1 : 0

  length           = 24
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

resource "azurerm_key_vault_secret" "jumpbox_admin_password" {
  count = var.deploy_jumpbox ? 1 : 0

  name         = "jumpbox-admin-password"
  value        = random_password.jumpbox_admin[0].result
  key_vault_id = azurerm_key_vault.this.id

  depends_on = [
    azurerm_role_assignment.terraform_spn_secrets_officer,
    azurerm_role_assignment.cloud_team_secrets_officer,
    azurerm_private_endpoint.keyvault
  ]
}

#------------------------------------------------------------------------------
# Windows Virtual Machine
#------------------------------------------------------------------------------

resource "azurerm_windows_virtual_machine" "jumpbox" {
  count = var.deploy_jumpbox ? 1 : 0

  name                = "vm-${local.resource_prefix}-jmp"
  resource_group_name = azurerm_resource_group.this.name
  location            = var.location
  size                = var.jumpbox_vm_size
  admin_username      = var.jumpbox_admin_username
  admin_password      = random_password.jumpbox_admin[0].result

  network_interface_ids = [
    azurerm_network_interface.jumpbox[0].id
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2022-datacenter-azure-edition-smalldisk"
    version   = "latest"
  }

  # Enable Azure AD login
  identity {
    type = "SystemAssigned"
  }

  tags = local.tags

  lifecycle {
    ignore_changes = [tags, admin_password]
  }
}

#------------------------------------------------------------------------------
# AAD Login Extension (optional - enables Entra ID authentication)
#------------------------------------------------------------------------------

resource "azurerm_virtual_machine_extension" "aad_login" {
  count = var.deploy_jumpbox && var.jumpbox_enable_aad_login ? 1 : 0

  name                       = "AADLoginForWindows"
  virtual_machine_id         = azurerm_windows_virtual_machine.jumpbox[0].id
  publisher                  = "Microsoft.Azure.ActiveDirectory"
  type                       = "AADLoginForWindows"
  type_handler_version       = "2.0"
  auto_upgrade_minor_version = true

  tags = local.tags
}

#------------------------------------------------------------------------------
# Role Assignment for AAD Login
#------------------------------------------------------------------------------

# Cloud Team - Virtual Machine Administrator Login
resource "azurerm_role_assignment" "cloud_team_vm_admin" {
  count = var.deploy_jumpbox ? 1 : 0

  scope                = azurerm_windows_virtual_machine.jumpbox[0].id
  role_definition_name = "Virtual Machine Administrator Login"
  principal_id         = var.cloud_team_group_id
}
