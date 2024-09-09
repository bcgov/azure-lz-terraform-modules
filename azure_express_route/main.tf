module "express_route_circuit" {
  source = "./express_route_circuit"

  subscription_id_connectivity = var.subscription_id_connectivity
  subscription_id_management   = var.subscription_id_management

  resource_group_name     = var.resource_group_name
  resource_group_location = var.resource_group_location

  express_route_circuit = var.express_route_circuit

  tags = var.tags
}

module "express_route_peering" {
  source = "./express_route_circuit_peering"

  subscription_id_connectivity = var.subscription_id_connectivity
  subscription_id_management   = var.subscription_id_management

  resource_group_name = module.express_route_circuit.resource_group_name
  circuit_peering     = var.circuit_peering
}

# IMPORTANT: The provider status of the Express Route Circuit must be set as provisioned while creating the Express Route Connection.
module "express_route_connection" {
  source = "./express_route_connection"

  subscription_id_connectivity = var.subscription_id_connectivity
  subscription_id_management   = var.subscription_id_management

  express_route_gateway_resource_group_name = var.express_route_gateway_resource_group_name
  express_route_circuit_resource_group_name = module.express_route_circuit.resource_group_name

  express_route_gateway_name    = var.express_route_gateway_name
  express_route_connection_name = var.express_route_connection_name

  express_route_circuit_name = var.express_route_circuit_name
  circuit_peering_type       = var.circuit_peering_type

  enable_internet_security             = var.enable_internet_security
  express_route_gateway_bypass_enabled = var.express_route_gateway_bypass_enabled
  private_link_fast_path_enabled       = var.private_link_fast_path_enabled
  routing_weight                       = var.routing_weight
  routing                              = var.routing
}
