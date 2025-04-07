resource "azurerm_fabric_capacity" "this" {
  name                = lower(var.fabric_capacity_name)
  resource_group_name = var.existing_resource_group_name
  location            = var.location

  administration_members = var.administration_members

  sku {
    name = var.sku
    tier = "Fabric"
  }

  tags = var.tags
}

# It's recommended to use `lifecycle` with `postcondition` block to handle the state of the capacity.
data "fabric_capacity" "this" {
  display_name = lower(var.fabric_capacity_name)

  lifecycle {
    postcondition {
      condition     = self.state == "Active"
      error_message = "Fabric Capacity is not in Active state. Please check the Fabric Capacity status."
    }
  }
}
