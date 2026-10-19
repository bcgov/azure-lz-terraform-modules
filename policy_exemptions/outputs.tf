output "policy_exemption_ids" {
  description = "Resource IDs of the policy exemptions managed by this module."
  value = merge(
    { for k, v in azurerm_subscription_policy_exemption.this : k => v.id },
    { for k, v in azurerm_resource_group_policy_exemption.this : k => v.id },
    { for k, v in azurerm_resource_policy_exemption.this : k => v.id },
  )
}
