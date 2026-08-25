# platform_subscriptions

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.12, < 2.0 |
| <a name="requirement_azapi"></a> [azapi](#requirement\_azapi) | ~> 2.5 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | ~> 4.5 |

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_lz_vending"></a> [lz\_vending](#module\_lz\_vending) | Azure/avm-ptn-alz-sub-vending/azure | 0.3.1 |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_location"></a> [location](#input\_location) | The default location for resources in these Subscriptions. | `string` | n/a | yes |
| <a name="input_platform_subscriptions"></a> [platform\_subscriptions](#input\_platform\_subscriptions) | A map of platform subscription definitions keyed by a stable subscription instance name.<br/><br/>Use this to pass one or more subscription definitions into a module with `for_each`:<pre>terraform<br/>module "platform_subscriptions" {<br/>  source   = "./modules/platform_subscriptions"<br/>  for_each = var.platform_subscriptions<br/><br/>  subscription_alias_enabled                        = each.value.subscription_alias_enabled<br/>  subscription_alias_name                           = each.value.subscription_alias_name<br/>  subscription_billing_scope                        = each.value.subscription_billing_scope<br/>  subscription_display_name                         = each.value.subscription_display_name<br/>  subscription_id                                   = each.value.subscription_id<br/>  subscription_management_group_association_enabled = each.value.subscription_management_group_association_enabled<br/>  subscription_management_group_id                  = each.value.subscription_management_group_id<br/>  subscription_tags                                 = each.value.subscription_tags<br/>  subscription_update_existing                      = each.value.subscription_update_existing<br/>  subscription_workload                             = each.value.subscription_workload<br/>  wait_for_subscription_before_subscription_operations = each.value.wait_for_subscription_before_subscription_operations<br/>}</pre>When `subscription_alias_enabled` is `true`, supply:<br/><br/>- `subscription_alias_name`<br/>- `subscription_display_name`<br/>- `subscription_billing_scope`<br/>- `subscription_workload`<br/><br/>Optionally, supply the following to place the subscription into a management group:<br/><br/>- `subscription_management_group_id`<br/>- `subscription_management_group_association_enabled`<br/><br/>When `subscription_alias_enabled` is `false`, supply `subscription_id` to use an existing subscription instead.<br/><br/>When using an existing subscription and managing management group membership, set `subscription_management_group_association_enabled` to `true` and supply `subscription_management_group_id`.<br/><br/>Set `subscription_update_existing` to `true` to update an existing subscription with the supplied tags and display name. When enabled, `subscription_id` must also be supplied.<br/><br/>`subscription_workload` can be either `Production` or `DevTest` and is case sensitive.<br/><br/>`wait_for_subscription_before_subscription_operations` controls the duration to wait after vending a subscription before performing subscription operations. | <pre>map(object({<br/>    subscription_alias_enabled                        = optional(bool, false)<br/>    subscription_alias_name                           = optional(string)<br/>    subscription_billing_scope                        = optional(string)<br/>    subscription_display_name                         = optional(string)<br/>    subscription_id                                   = optional(string)<br/>    subscription_management_group_association_enabled = optional(bool, false)<br/>    subscription_management_group_id                  = optional(string)<br/>    subscription_tags                                 = optional(map(string), {})<br/>    subscription_update_existing                      = optional(bool, false)<br/>    subscription_workload                             = optional(string)<br/>    wait_for_subscription_before_subscription_operations = optional(object({<br/>      create  = optional(string, "30s")<br/>      destroy = optional(string, "0s")<br/>    }), {})<br/>  }))</pre> | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_lz_vending"></a> [lz\_vending](#output\_lz\_vending) | n/a |
<!-- END_TF_DOCS -->
