locals {
  # NOTE: These are recommended Resource Providers to pre-register in each Subscription to improve developer experience
  # See: https://github.com/Azure/terraform-azurerm-lz-vending?tab=readme-ov-file#input_subscription_register_resource_providers_and_features

  default_resource_providers_and_features = {
    "GitHub.Network" : [],
    "Microsoft.AlertsManagement" : [],
    "Microsoft.App" : [],
    "Microsoft.ContainerInstance" : [],
    "Microsoft.ContainerRegistry" : [],
    "Microsoft.ContainerService" : [],
    "Microsoft.CostManagementExports" : [],
    "Microsoft.DevCenter" : [],
    "Microsoft.DevOpsInfrastructure" : [],
    "Microsoft.Insights" : [],
    "Microsoft.OperationalInsights" : []
  }
}
