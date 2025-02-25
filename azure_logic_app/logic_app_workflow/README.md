# logic_app_workflow

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >=1.9.0, < 2.0.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | ~>4.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | ~>4.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_logic_app_workflow.alerts_logic_app_workflow](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/logic_app_workflow) | resource |
| [azurerm_resource_group.alerts_logic_app](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_location"></a> [location](#input\_location) | The location in which the Logic App will be created. | `string` | n/a | yes |
| <a name="input_parameters"></a> [parameters](#input\_parameters) | (Optional) A map of Key-Value pairs. Any parameters specified must exist in the Schema defined in workflow\_parameters. | `map(string)` | `null` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | The name of the resource group in which the Logic App will be created. | `string` | n/a | yes |
| <a name="input_workflow_name"></a> [workflow\_name](#input\_workflow\_name) | The name of the Logic App workflow. | `string` | n/a | yes |
| <a name="input_workflow_parameters"></a> [workflow\_parameters](#input\_workflow\_parameters) | (Optional) A map of Key-Value pairs of the Parameter Definitions to use for this Logic App Workflow. The key is the parameter name, and the value is a JSON encoded string of the parameter definition. | `map(string)` | `null` | no |
| <a name="input_workflow_schema"></a> [workflow\_schema](#input\_workflow\_schema) | (Optional) Specifies the Schema to use for this Logic App Workflow. | `string` | `null` | no |
| <a name="input_workflow_version"></a> [workflow\_version](#input\_workflow\_version) | (Optional) Specifies the version of the Schema used for this Logic App Workflow. Defaults to 1.0.0.0. | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_workflow"></a> [workflow](#output\_workflow) | The Logic App Workflow object. |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
