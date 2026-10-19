# Policy exemptions

Imports existing Azure Policy exemptions and manages them in place. Names, scope ids, and assignment ids are copied from Azure so the first apply does not create a second exemption.

`expires_on` null means the waiver has no end date. An empty `policy_definition_reference_ids` list waives the whole assignment. `reviewBy` is written only for those exemptions. `reviewers` is a list of email addresses. `extra` is merged into the exemption metadata for keys that only one exemption has.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.9.0, < 2.0.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | ~> 4.0 |

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | ~> 4.0 |

## Modules

No modules.

## Resources

| Name | Type |
| ---- | ---- |
| [azurerm_resource_group_policy_exemption.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group_policy_exemption) | resource |
| [azurerm_resource_policy_exemption.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_policy_exemption) | resource |
| [azurerm_subscription_policy_exemption.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subscription_policy_exemption) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_exemptions"></a> [exemptions](#input\_exemptions) | Policy exemptions to import and manage. scope\_type is subscription, resource\_group, or resource. An empty policy\_definition\_reference\_ids list waives the whole assignment. reviewers is a list of email addresses. extra holds metadata keys that only this exemption has. | <pre>map(object({<br/>    scope_type                      = string<br/>    scope_id                        = string<br/>    name                            = string<br/>    policy_assignment_id            = string<br/>    display_name                    = string<br/>    description                     = string<br/>    policy_definition_reference_ids = list(string)<br/>    exemption_category              = string<br/>    expires_on                      = optional(string)<br/>    reviewers                       = optional(list(string), [])<br/>    last_reviewed_on                = optional(string)<br/>    reason                          = optional(string)<br/>    ticket                          = optional(string)<br/>    extra                           = optional(map(string), {})<br/>  }))</pre> | n/a | yes |
| <a name="input_managed_by"></a> [managed\_by](#input\_managed\_by) | Value stored in exemption metadata as managedBy. | `string` | n/a | yes |
| <a name="input_review_by"></a> [review\_by](#input\_review\_by) | Next review date (YYYY-MM-DD) stored as reviewBy on exemptions with no expires\_on. | `string` | n/a | yes |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_policy_exemption_ids"></a> [policy\_exemption\_ids](#output\_policy\_exemption\_ids) | Resource IDs of the policy exemptions managed by this module. |
<!-- END_TF_DOCS -->
