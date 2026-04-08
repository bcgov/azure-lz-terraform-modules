#------------------------------------------------------------------------------
# MCCS Observability Platform
# Multi-Cloud Connectivity Service Monitoring Solution
#
# This module deploys a comprehensive observability platform for monitoring
# Azure ExpressRoute and AWS Direct Connect connections (Phase 2).
#
# Components:
# - Azure Managed Grafana for visualization
# - PostgreSQL Flexible Server for Netbox database
# - Azure Container Instances for Netbox and Prometheus
# - Log Analytics Workspace for diagnostic data
# - Key Vault for secrets management
# - Logic App for alert routing
# - Alert rules for ExpressRoute monitoring
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# Resource Group
#------------------------------------------------------------------------------

resource "azurerm_resource_group" "this" {
  name     = local.resource_group_name
  location = var.location
  tags     = local.tags
}

#------------------------------------------------------------------------------
# Random suffix for globally unique names
#------------------------------------------------------------------------------

resource "random_string" "suffix" {
  length  = 4
  special = false
  upper   = false
}
