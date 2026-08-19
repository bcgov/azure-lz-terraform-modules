# Private NAT mode creates a Linux NVA in the routable spoke. Expansion
# traffic to enterprise prefixes (and optionally 0.0.0.0/0) is steered to
# that VM, which SNATs isolated sources to the NVA's spoke IP before packets
# enter the enterprise routing domain. The isolated prefix is never advertised.

resource "azurerm_network_security_group" "private_nat" {
  count = local.private_nat_enabled ? 1 : 0

  name                = "${local.virtual_network_name}-nva"
  location            = var.location
  resource_group_name = var.routable_vnet.resource_group_name
  tags                = local.tags

  lifecycle {
    ignore_changes = [tags]
  }
}

resource "azurerm_network_security_rule" "private_nat" {
  for_each = {
    for key, rule in local.private_nat_nsg_rules : key => rule
    if local.private_nat_enabled
  }

  name                         = each.key
  resource_group_name          = var.routable_vnet.resource_group_name
  network_security_group_name  = azurerm_network_security_group.private_nat[0].name
  priority                     = each.value.priority
  direction                    = each.value.direction
  access                       = each.value.access
  protocol                     = each.value.protocol
  description                  = each.value.description
  source_port_range            = "*"
  destination_port_range       = each.value.destination_port_range
  source_address_prefix        = each.value.source_address_prefix
  source_address_prefixes      = each.value.source_address_prefixes
  destination_address_prefix   = each.value.destination_address_prefix
  destination_address_prefixes = each.value.destination_address_prefixes
}

resource "azapi_resource" "private_nat_subnet" {
  count = local.private_nat_enabled ? 1 : 0

  type      = "Microsoft.Network/virtualNetworks/subnets@2024-05-01"
  name      = local.private_nat_subnet_name
  parent_id = var.routable_vnet.id
  locks     = [var.routable_vnet.id]

  body = {
    properties = merge(
      {
        addressPrefix         = local.private_nat.subnet_address_prefix
        defaultOutboundAccess = false
        networkSecurityGroup = {
          id = azurerm_network_security_group.private_nat[0].id
        }
      },
      local.private_nat.spoke_route_table_id != null ? {
        routeTable = {
          id = local.private_nat.spoke_route_table_id
        }
      } : {}
    )
  }

  depends_on = [azurerm_network_security_rule.private_nat]
}

resource "azurerm_network_interface" "private_nat" {
  count = local.private_nat_enabled ? 1 : 0

  name                  = "${local.virtual_network_name}-nva"
  location              = var.location
  resource_group_name   = var.routable_vnet.resource_group_name
  ip_forwarding_enabled = true
  tags                  = local.tags

  ip_configuration {
    name                          = "primary"
    subnet_id                     = azapi_resource.private_nat_subnet[0].id
    private_ip_address_allocation = "Static"
    private_ip_address            = local.private_nat_ip
  }

  lifecycle {
    ignore_changes = [tags]
  }
}

resource "azurerm_linux_virtual_machine" "private_nat" {
  count = local.private_nat_enabled ? 1 : 0

  name                            = "${local.virtual_network_name}-nva"
  location                        = var.location
  resource_group_name             = var.routable_vnet.resource_group_name
  size                            = local.private_nat.vm_size
  admin_username                  = local.private_nat.admin_username
  network_interface_ids           = [azurerm_network_interface.private_nat[0].id]
  zone                            = local.private_nat.zone
  disable_password_authentication = true
  secure_boot_enabled             = false
  vtpm_enabled                    = false
  # Update Manager assessment is always on. Install/reboot only run when
  # patch_schedule is set (this module) or a landing-zone assignment exists.
  patch_assessment_mode                                  = "AutomaticByPlatform"
  patch_mode                                             = "AutomaticByPlatform"
  bypass_platform_safety_checks_on_user_schedule_enabled = true
  reboot_setting                                         = local.private_nat_patch_schedule_enabled ? local.private_nat_patch_schedule.reboot : "Never"
  custom_data = base64encode(templatefile("${path.module}/templates/private-nat-cloud-init.yaml.tftpl", {
    source_prefixes = var.address_space
  }))
  tags = local.tags

  admin_ssh_key {
    username   = local.private_nat.admin_username
    public_key = local.private_nat.ssh_public_key
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "StandardSSD_LRS"
    disk_size_gb         = local.private_nat.os_disk_size_gb
  }

  source_image_reference {
    publisher = local.private_nat_image.publisher
    offer     = local.private_nat_image.offer
    sku       = local.private_nat_image.sku
    version   = local.private_nat_image.version
  }

  boot_diagnostics {}

  lifecycle {
    ignore_changes = [identity, tags]
  }

  depends_on = [
    azurerm_virtual_network_peering.expansion_to_routable,
    azurerm_virtual_network_peering.routable_to_expansion
  ]
}

resource "azurerm_maintenance_configuration" "private_nat" {
  count = local.private_nat_patch_schedule_enabled ? 1 : 0

  name                     = "${local.virtual_network_name}-nva-patch"
  resource_group_name      = var.routable_vnet.resource_group_name
  location                 = var.location
  scope                    = "InGuestPatch"
  in_guest_user_patch_mode = "User"
  visibility               = "Custom"
  tags                     = local.tags

  window {
    start_date_time = local.private_nat_patch_schedule.start_date_time
    time_zone       = local.private_nat_patch_schedule.time_zone
    recur_every     = local.private_nat_patch_schedule.recur_every
    duration        = local.private_nat_patch_schedule.duration
  }

  install_patches {
    reboot = local.private_nat_patch_schedule.reboot

    linux {
      classifications_to_include = local.private_nat_patch_schedule.classifications_to_include
    }
  }

  lifecycle {
    ignore_changes = [tags]
  }
}

resource "azurerm_maintenance_assignment_virtual_machine" "private_nat" {
  count = local.private_nat_patch_schedule_enabled ? 1 : 0

  location                     = var.location
  maintenance_configuration_id = azurerm_maintenance_configuration.private_nat[0].id
  virtual_machine_id           = azurerm_linux_virtual_machine.private_nat[0].id
}
