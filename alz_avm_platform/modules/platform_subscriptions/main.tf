module "lz_vending" {
  source  = "Azure/avm-ptn-alz-sub-vending/azure"
  version = "0.3.1" # Reference: https://github.com/Azure/terraform-azure-avm-ptn-alz-sub-vending

  # Set the default location for resources
  location = var.location

  for_each = var.platform_subscriptions

  # subscription variables
  subscription_alias_enabled   = each.value.subscription_alias_enabled
  subscription_alias_name      = each.value.subscription_alias_name
  subscription_billing_scope   = each.value.subscription_billing_scope
  subscription_display_name    = each.value.subscription_display_name
  subscription_id              = each.value.subscription_id
  subscription_tags            = each.value.subscription_tags
  subscription_update_existing = each.value.subscription_update_existing
  subscription_workload        = each.value.subscription_workload

  # Management Group association variables
  subscription_management_group_association_enabled = each.value.subscription_management_group_association_enabled
  subscription_management_group_id                  = each.value.subscription_management_group_id

  wait_for_subscription_before_subscription_operations = each.value.wait_for_subscription_before_subscription_operations
}
