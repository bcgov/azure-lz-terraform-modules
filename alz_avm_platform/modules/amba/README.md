<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.9, < 2.0 |
| <a name="requirement_azapi"></a> [azapi](#requirement\_azapi) | ~> 2.2 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | ~> 4.0 |
| <a name="requirement_modtm"></a> [modtm](#requirement\_modtm) | ~> 0.3 |
| <a name="requirement_random"></a> [random](#requirement\_random) | ~> 3.6 |

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_amba"></a> [amba](#module\_amba) | Azure/avm-ptn-monitoring-amba-alz/azurerm | 0.4.0 |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_amba_resource_group_name"></a> [amba\_resource\_group\_name](#input\_amba\_resource\_group\_name) | The resource group where the resources will be deployed. | `string` | `"rg-amba-monitoring-001"` | no |
| <a name="input_amba_role_definition_id"></a> [amba\_role\_definition\_id](#input\_amba\_role\_definition\_id) | The role definition ID to assign to the User Assigned Managed Identity. Defaults to Monitoring Reader. | `string` | `"43d0d8ad-25c7-4714-9337-8ba259a9fe05"` | no |
| <a name="input_amba_user_assigned_managed_identity_name"></a> [amba\_user\_assigned\_managed\_identity\_name](#input\_amba\_user\_assigned\_managed\_identity\_name) | The name of the user-assigned managed identity. | `string` | `"id-amba-prod-001"` | no |
| <a name="input_description"></a> [description](#input\_description) | The description used for the role assignment to identify the resource as deployed by AMBA. | `string` | `"_deployed_by_amba"` | no |
| <a name="input_location"></a> [location](#input\_location) | Azure region where the resource should be deployed. | `string` | n/a | yes |
| <a name="input_lock"></a> [lock](#input\_lock) | Controls the Resource Lock configuration for this resource. The following properties can be specified:<br/><br/>- `kind` - (Required) The type of lock. Possible values are `\"CanNotDelete\"` and `\"ReadOnly\"`.<br/>- `name` - (Optional) The name of the lock. If not specified, a name will be generated based on the `kind` value. Changing this forces the creation of a new resource. | <pre>object({<br/>    kind = string<br/>    name = optional(string, null)<br/>  })</pre> | `null` | no |
| <a name="input_role_assignments"></a> [role\_assignments](#input\_role\_assignments) | A map of role assignments to create on the resource group. The map key is deliberately arbitrary to avoid issues where map keys maybe unknown at plan time.<br/><br/>- `role_definition_id_or_name` - The ID or name of the role definition to assign to the principal.<br/>- `principal_id` - The ID of the principal to assign the role to.<br/>- `description` - The description of the role assignment.<br/>- `skip_service_principal_aad_check` - If set to true, skips the Azure Active Directory check for the service principal in the tenant. Defaults to false.<br/>- `condition` - The condition which will be used to scope the role assignment.<br/>- `condition_version` - The version of the condition syntax. Valid values are '2.0'.<br/><br/>> Note: only set `skip_service_principal_aad_check` to true if you are assigning a role to a service principal. | <pre>map(object({<br/>    role_definition_id_or_name             = string<br/>    principal_id                           = string<br/>    description                            = optional(string, null)<br/>    skip_service_principal_aad_check       = optional(bool, false)<br/>    condition                              = optional(string, null)<br/>    condition_version                      = optional(string, null)<br/>    delegated_managed_identity_resource_id = optional(string, null)<br/>    principal_type                         = optional(string, null)<br/>  }))</pre> | `{}` | no |
| <a name="input_subscription_id_management"></a> [subscription\_id\_management](#input\_subscription\_id\_management) | Subscription ID to use for "management" resources. | `string` | `""` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | (Optional) Tags of the resource. | `map(string)` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_amba"></a> [amba](#output\_amba) | The outputs from the AMBA module. |
<!-- END_TF_DOCS -->
