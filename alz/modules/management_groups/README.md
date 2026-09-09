# management_groups

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.12 |

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_management_groups"></a> [management\_groups](#module\_management\_groups) | Azure/avm-ptn-alz/azurerm | 0.12.3 |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_dependencies"></a> [dependencies](#input\_dependencies) | Place dependent values into this variable to ensure that resources are created in the correct order.<br/>Ensure that the values placed here are computed/known after apply, e.g. the resource ids.<br/><br/>This is necessary as the unknown values and `depends_on` are not supported by this module as we use the alz provider.<br/>See the "Unknown Values & Depends On" section above for more information.<br/><br/>e.g.<pre>hcl<br/>dependencies = {<br/>  policy_role_assignments = [<br/>    module.dependency_example1.output,<br/>    module.dependency_example2.output,<br/>  ]<br/>}</pre> | <pre>object({<br/>    policy_role_assignments = optional(any, null)<br/>    policy_assignments      = optional(any, null)<br/>  })</pre> | `{}` | no |
| <a name="input_enable_telemetry"></a> [enable\_telemetry](#input\_enable\_telemetry) | This variable controls whether or not telemetry is enabled for the module.<br/>For more information see <https://aka.ms/avm/telemetryinfo>.<br/>If it is set to false, then no telemetry will be collected. | `bool` | `true` | no |
| <a name="input_management_group_settings"></a> [management\_group\_settings](#input\_management\_group\_settings) | The settings for the management groups. | `any` | `{}` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
