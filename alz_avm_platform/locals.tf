locals {
  parent_resource_id = var.parent_resource_id != "" ? var.parent_resource_id : data.azapi_client_config.current.tenant_id
}
