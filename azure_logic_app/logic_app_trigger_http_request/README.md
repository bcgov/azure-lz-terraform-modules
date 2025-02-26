# logic_app_trigger_http_request

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
| [azurerm_logic_app_trigger_http_request.alerts_logic_app](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/logic_app_trigger_http_request) | resource |
| [local_file.logic_app_trigger_http_request](https://registry.terraform.io/providers/hashicorp/local/latest/docs/data-sources/file) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_logic_app_id"></a> [logic\_app\_id](#input\_logic\_app\_id) | The ID of the Logic App that the HTTP Request trigger is associated with. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_trigger_callback_url"></a> [trigger\_callback\_url](#output\_trigger\_callback\_url) | The Callback URL of the Logic App Trigger HTTP Request |
| <a name="output_trigger_id"></a> [trigger\_id](#output\_trigger\_id) | The ID of the Logic App Trigger HTTP Request |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
