# This is based off of the individual variables defined here: https://github.com/Azure/terraform-azure-avm-ptn-alz-sub-vending/blob/main/variables.subscription.tf
variable "platform_subscriptions" {
  type = map(object({
    subscription_alias_enabled                        = optional(bool, false)
    subscription_alias_name                           = optional(string)
    subscription_billing_scope                        = optional(string)
    subscription_display_name                         = optional(string)
    subscription_id                                   = optional(string)
    subscription_management_group_association_enabled = optional(bool, false)
    subscription_management_group_id                  = optional(string)
    subscription_tags                                 = optional(map(string), {})
    subscription_update_existing                      = optional(bool, false)
    subscription_workload                             = optional(string)
    wait_for_subscription_before_subscription_operations = optional(object({
      create  = optional(string, "30s")
      destroy = optional(string, "0s")
    }), {})
  }))
  default     = {}
  description = <<DESCRIPTION
A map of platform subscription definitions keyed by a stable subscription instance name.

Use this to pass one or more subscription definitions into a module with `for_each`:

```terraform
module "platform_subscriptions" {
  source   = "./modules/platform_subscriptions"
  for_each = var.platform_subscriptions

  subscription_alias_enabled                        = each.value.subscription_alias_enabled
  subscription_alias_name                           = each.value.subscription_alias_name
  subscription_billing_scope                        = each.value.subscription_billing_scope
  subscription_display_name                         = each.value.subscription_display_name
  subscription_id                                   = each.value.subscription_id
  subscription_management_group_association_enabled = each.value.subscription_management_group_association_enabled
  subscription_management_group_id                  = each.value.subscription_management_group_id
  subscription_tags                                 = each.value.subscription_tags
  subscription_update_existing                      = each.value.subscription_update_existing
  subscription_workload                             = each.value.subscription_workload
  wait_for_subscription_before_subscription_operations = each.value.wait_for_subscription_before_subscription_operations
}
```

When `subscription_alias_enabled` is `true`, supply:

- `subscription_alias_name`
- `subscription_display_name`
- `subscription_billing_scope`
- `subscription_workload`

Optionally, supply the following to place the subscription into a management group:

- `subscription_management_group_id`
- `subscription_management_group_association_enabled`

When `subscription_alias_enabled` is `false`, supply `subscription_id` to use an existing subscription instead.

When using an existing subscription and managing management group membership, set `subscription_management_group_association_enabled` to `true` and supply `subscription_management_group_id`.

Set `subscription_update_existing` to `true` to update an existing subscription with the supplied tags and display name. When enabled, `subscription_id` must also be supplied.

`subscription_workload` can be either `Production` or `DevTest` and is case sensitive.

`wait_for_subscription_before_subscription_operations` controls the duration to wait after vending a subscription before performing subscription operations.
DESCRIPTION
  nullable    = false
}

