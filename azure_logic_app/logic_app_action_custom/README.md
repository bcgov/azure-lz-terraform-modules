# logic_app_action_custom

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
| <a name="provider_local"></a> [local](#provider\_local) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_logic_app_action_custom.create_jira_issue](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/logic_app_action_custom) | resource |
| [azurerm_logic_app_action_custom.init_affected_resource_var](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/logic_app_action_custom) | resource |
| [local_file.logic_app_action_create_jira_issue](https://registry.terraform.io/providers/hashicorp/local/latest/docs/data-sources/file) | data source |
| [local_file.logic_app_trigger_actions_init_affectedresource_var](https://registry.terraform.io/providers/hashicorp/local/latest/docs/data-sources/file) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_api_connection_name"></a> [api\_connection\_name](#input\_api\_connection\_name) | (Required) The Name which should be used for this API Connection. | `string` | n/a | yes |
| <a name="input_logic_app_id"></a> [logic\_app\_id](#input\_logic\_app\_id) | The ID of the Logic App that the HTTP Request trigger is associated with. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_action_custom_create_jira_issue"></a> [action\_custom\_create\_jira\_issue](#output\_action\_custom\_create\_jira\_issue) | The custom action to create a new Jira issue |
| <a name="output_action_custom_init_affected_resource_var"></a> [action\_custom\_init\_affected\_resource\_var](#output\_action\_custom\_init\_affected\_resource\_var) | The custom action to initialize the affected resource variable |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
