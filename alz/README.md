# Azure Verified Modules for Platform Landing Zone (ALZ)

This module provides a Terraform implementation of the Azure Verified Modules for Platform Landing Zone (ALZ), migrated from the classic CAF Enterprise Scale module. It includes comprehensive platform landing zone functionality with connectivity, management, and identity resources.

## Features

- **Management Groups**: Hierarchical organization structure
- **Management Resources**: Log Analytics workspace, Security Center, automation
- **Connectivity Resources**: Virtual WAN, Azure Firewall, VPN/ExpressRoute gateways
- **Identity Resources**: Azure AD integration and RBAC
- **Policy Management**: Custom policy definitions, assignments, and policy sets
- **Role Management**: Custom role definitions and assignments
- **Platform Landing Zone**: Complete platform infrastructure with hub-and-spoke or Virtual WAN connectivity
- **Resource Groups**: Automated resource group creation and management
- **Configuration Templating**: Dynamic configuration generation for complex deployments

## Usage

### Basic ALZ Configuration

```hcl
module "alz" {
  source = "git::https://github.com/bcgov/azure-lz-terraform-modules.git//alz"

  providers = {
    azurerm              = azurerm
    azurerm.connectivity = azurerm.connectivity
    azurerm.management   = azurerm.management
    azurerm.identity     = azurerm.identity
  }

  # Core ALZ configuration
  architecture_name  = "bcgov-alz"
  parent_resource_id = "/providers/Microsoft.Management/managementGroups/BCGOV-MGD-LZ"
  location           = "Canada Central"

  # Platform Landing Zone configuration
  enable_telemetry = true
  starter_locations = ["Canada Central", "Canada East"]

  subscription_ids = {
    connectivity = "00000000-0000-0000-0000-000000000001"
    management   = "00000000-0000-0000-0000-000000000002"
    identity     = "00000000-0000-0000-0000-000000000003"
    security     = "00000000-0000-0000-0000-000000000004"
  }

  # Connectivity configuration
  connectivity_type = "virtual_wan"  # or "hub_and_spoke_vnet" or "none"

  connectivity_resource_groups = {
    connectivity_rg = {
      name     = "rg-connectivity-cac"
      location = "Canada Central"
      tags = {
        Environment = "Production"
        CostCenter  = "IT"
      }
    }
  }

  virtual_wan_settings = {
    ddos_protection_plan = {
      enabled = true
      config = {
        name     = "ddos-protection-plan"
        location = "Canada Central"
      }
    }
  }

  virtual_wan_virtual_hubs = {
    hub_cac = {
      hub = {
        enabled = true
        config = {
          name                = "vwan-hub-cac"
          location            = "Canada Central"
          address_prefix      = "10.41.252.0/22"
          sku                 = "Standard"
          hub_routing_preference = "ExpressRoute"
        }
      }
      firewall = {
        enabled = true
        config = {
          name     = "azfw-hub-cac"
          sku_name = "AZFW_Hub"
          sku_tier = "Standard"
        }
      }
    }
  }

  # Management configuration
  management_resource_settings = {
    enabled = true
    log_analytics = {
      enabled = true
      config = {
        name                = "law-alz-cac"
        location            = "Canada Central"
        retention_in_days   = 90
        sku                 = "PerGB2018"
      }
    }
    security_center = {
      enabled = true
      config = {
        email_security_contact = "cloud.pathfinder@gov.bc.ca"
        pricing_tier          = "Standard"
      }
    }
  }

  management_group_settings = {
    enabled = true
    # Additional management group configuration
  }

  tags = {
    Environment = "Production"
    CostCenter  = "IT"
    Owner       = "Cloud Team"
  }
}
```

### Hub and Spoke Configuration

```hcl
module "alz_hub_spoke" {
  source = "git::https://github.com/bcgov/azure-lz-terraform-modules.git//alz"

  # ... basic configuration ...

  connectivity_type = "hub_and_spoke_vnet"

  hub_and_spoke_vnet_settings = {
    ddos_protection_plan = {
      enabled = true
      config = {
        name     = "ddos-protection-plan"
        location = "Canada Central"
      }
    }
  }

  hub_and_spoke_vnet_virtual_networks = {
    hub_cac = {
      hub_virtual_network = {
        enabled = true
        config = {
          name                = "vnet-hub-cac"
          location            = "Canada Central"
          address_space       = ["10.41.0.0/16"]
          dns_servers         = ["10.41.0.4", "10.41.0.5"]
        }
        subnets = {
          AzureFirewallSubnet = {
            name             = "AzureFirewallSubnet"
            address_prefixes = ["10.41.0.0/26"]
          }
          GatewaySubnet = {
            name             = "GatewaySubnet"
            address_prefixes = ["10.41.1.0/27"]
          }
        }
      }
      firewall = {
        enabled = true
        config = {
          name     = "azfw-hub-cac"
          sku_name = "AZFW_VNet"
          sku_tier = "Standard"
        }
      }
    }
  }
}
```

## Requirements

| Name | Version |
|------|---------|
| azurerm | ~> 3.116.0 |
| alz | ~> 0.17, >= 0.17.4 |

## Providers

| Name | Version |
|------|---------|
| azurerm | ~> 3.116.0 |
| azurerm.connectivity | ~> 3.116.0 |
| azurerm.management | ~> 3.116.0 |
| azurerm.identity | ~> 3.116.0 |
| alz | ~> 0.17, >= 0.17.4 |

## Inputs

### Core ALZ Configuration

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| architecture_name | Architecture name for the ALZ deployment | `string` | n/a | yes |
| parent_resource_id | Parent management group resource ID | `string` | n/a | yes |
| location | Azure region for resource deployment | `string` | n/a | yes |
| dependencies | Dependencies for resource creation order | `map(list(string))` | `{}` | no |
| policy_assignments_to_modify | Policy assignments to modify | `map(object)` | `{}` | no |

### Platform Landing Zone Configuration

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| enable_telemetry | Flag to enable/disable telemetry | `bool` | `true` | no |
| starter_locations | The default for Azure resources (e.g 'uksouth') | `list(string)` | n/a | yes |
| subscription_ids | The list of subscription IDs to deploy the Platform Landing Zones into | `map(string)` | `{}` | no |
| subscription_id_connectivity | DEPRECATED: The identifier of the Connectivity Subscription | `string` | `null` | no |
| subscription_id_identity | DEPRECATED: The identifier of the Identity Subscription | `string` | `null` | no |
| subscription_id_management | DEPRECATED: The identifier of the Management Subscription | `string` | `null` | no |
| root_parent_management_group_id | The id of the management group that the ALZ hierarchy will be nested under | `string` | `""` | no |
| custom_replacements | Custom replacements | `object` | `{}` | no |
| tags | Tags of the resource | `map(string)` | `null` | no |

### Connectivity Configuration

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| connectivity_type | The type of network connectivity technology to use | `string` | `"hub_and_spoke_vnet"` | no |
| connectivity_resource_groups | A map of resource groups to create | `map(object)` | `{}` | no |
| hub_and_spoke_vnet_settings | The shared settings for the hub and spoke networks | `any` | `{}` | no |
| hub_and_spoke_vnet_virtual_networks | A map of hub networks to create | `map(object)` | `{}` | no |
| virtual_wan_settings | The shared settings for the Virtual WAN | `any` | `{}` | no |
| virtual_wan_virtual_hubs | A map of virtual hubs to create | `map(object)` | `{}` | no |

### Management Configuration

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| management_resource_settings | The settings for the management resources | `any` | `{}` | no |
| management_group_settings | The settings for the management groups | `any` | `{}` | no |

## Outputs

### Core ALZ Outputs

| Name | Description |
|------|-------------|
| management_groups | The management groups created by the ALZ module |
| policy_assignments | The policy assignments created by the ALZ module |
| policy_definitions | The policy definitions created by the ALZ module |
| policy_set_definitions | The policy set definitions created by the ALZ module |
| configuration | Configuration object for compatibility with CAF module |

### Platform Landing Zone Outputs

| Name | Description |
|------|-------------|
| dns_server_ip_address | DNS server IP address from connectivity module |
| templated_inputs | Templated inputs from configuration module |
| management_resources | Management resources module output |
| resource_groups | Resource groups created by the module |

### Hub and Spoke Virtual Network Outputs

| Name | Description |
|------|-------------|
| hub_and_spoke_vnet_virtual_network_resource_ids | Hub and spoke virtual network resource IDs |
| hub_and_spoke_vnet_virtual_network_resource_names | Hub and spoke virtual network resource names |
| hub_and_spoke_vnet_firewall_resource_ids | Hub and spoke firewall resource IDs |
| hub_and_spoke_vnet_firewall_resource_names | Hub and spoke firewall resource names |
| hub_and_spoke_vnet_firewall_private_ip_address | Hub and spoke firewall private IP addresses |
| hub_and_spoke_vnet_firewall_public_ip_addresses | Hub and spoke firewall public IP addresses |
| hub_and_spoke_vnet_firewall_policy_ids | Hub and spoke firewall policy IDs |
| hub_and_spoke_vnet_route_tables_firewall | Hub and spoke route tables for firewall |
| hub_and_spoke_vnet_route_tables_user_subnets | Hub and spoke route tables for user subnets |
| hub_and_spoke_vnet_full_output | Full hub and spoke virtual network module output |

### Virtual WAN Outputs

| Name | Description |
|------|-------------|
| virtual_wan_resource_id | Virtual WAN resource ID |
| virtual_wan_name | Virtual WAN name |
| virtual_wan_virtual_hub_resource_ids | Virtual WAN virtual hub resource IDs |
| virtual_wan_virtual_hub_resource_names | Virtual WAN virtual hub resource names |
| virtual_wan_firewall_resource_ids | Virtual WAN firewall resource IDs |
| virtual_wan_firewall_resource_names | Virtual WAN firewall resource names |
| virtual_wan_firewall_private_ip_address | Virtual WAN firewall private IP address |
| virtual_wan_firewall_public_ip_addresses | Virtual WAN firewall public IP addresses |
| virtual_wan_firewall_policy_ids | Virtual WAN firewall policy IDs |
| virtual_wan_express_route_gateway_resource_ids | Virtual WAN ExpressRoute gateway resource IDs |
| virtual_wan_bastion_host_public_ip_address | Virtual WAN bastion host public IP address |
| virtual_wan_bastion_host_resource_ids | Virtual WAN bastion host resource IDs |
| virtual_wan_bastion_host_resources | Virtual WAN bastion host resources |
| virtual_wan_private_dns_resolver_resource_ids | Virtual WAN private DNS resolver resource IDs |
| virtual_wan_private_dns_resolver_resources | Virtual WAN private DNS resolver resources |
| virtual_wan_sidecar_virtual_network_resource_ids | Virtual WAN sidecar virtual network resource IDs |
| virtual_wan_sidecar_virtual_network_resources | Virtual WAN sidecar virtual network resources |
| virtual_wan_full_output | Full virtual WAN module output |

## Configuration Files

### Example Configuration Files

The module includes example configuration files to help you get started:

- **`example.tfvars`**: A simplified example showing basic ALZ configuration
- **`forge.tfvars`**: Complete BCGov Forge environment configuration based on existing CAF setup

### Using the Configuration Files

```bash
# Apply with example configuration
terraform apply -var-file="example.tfvars"

# Apply with BCGov Forge configuration
terraform apply -var-file="forge.tfvars"

# Apply with custom configuration
terraform apply -var-file="my-custom.tfvars"
```

### Key Configuration Sections

1. **Core ALZ Configuration**: Basic module settings (architecture name, parent resource ID, location)
2. **Platform Landing Zone**: Telemetry, starter locations, subscription IDs
3. **Connectivity Configuration**: Network architecture (Virtual WAN or hub-and-spoke)
4. **Management Configuration**: Log Analytics, Security Center, automation accounts
5. **Custom Replacements**: Resource naming and identifier overrides
6. **Tags**: Standardized tagging across all resources

## Migration from CAF Enterprise Scale

This module is designed to replace the classic CAF Enterprise Scale module (`caf_cccs_medium`). The migration process involves:

1. **State Import**: Use Terraform State Importer tool to migrate existing resources
2. **Configuration Mapping**: Map CAF configuration to ALZ module parameters
3. **Policy Migration**: Migrate custom policies and archetype overrides
4. **Validation**: Verify all resources are properly imported and functional

The `forge.tfvars` file demonstrates how to map existing CAF configuration to the new ALZ module structure.

For detailed migration guidance, see the [Microsoft ALZ Migration Guide](https://azure.github.io/Azure-Landing-Zones/terraform/migration/).

## License

This module is licensed under the MIT License.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_alz"></a> [alz](#requirement\_alz) | ~> 0.17, >= 0.17.4 |
| <a name="requirement_azapi"></a> [azapi](#requirement\_azapi) | >= 1.0.0, < 3.0.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >= 3.71.0, < 5.0.0 |
| <a name="requirement_external"></a> [external](#requirement\_external) | >= 2.0.0 |
| <a name="requirement_local"></a> [local](#requirement\_local) | >= 2.0.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_external"></a> [external](#provider\_external) | >= 2.0.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_avm_ptn_alz"></a> [avm\_ptn\_alz](#module\_avm\_ptn\_alz) | Azure/avm-ptn-alz/azurerm | 0.13.0 |
| <a name="module_config"></a> [config](#module\_config) | ./modules/config-templating | n/a |
| <a name="module_hub_and_spoke_vnet"></a> [hub\_and\_spoke\_vnet](#module\_hub\_and\_spoke\_vnet) | Azure/avm-ptn-alz-connectivity-hub-and-spoke-vnet/azurerm | 0.12.0 |
| <a name="module_management_groups"></a> [management\_groups](#module\_management\_groups) | ./modules/management_groups | n/a |
| <a name="module_management_resources"></a> [management\_resources](#module\_management\_resources) | ./modules/management_resources | n/a |
| <a name="module_resource_groups"></a> [resource\_groups](#module\_resource\_groups) | Azure/avm-res-resources-resourcegroup/azurerm | 0.2.1 |
| <a name="module_virtual_wan"></a> [virtual\_wan](#module\_virtual\_wan) | Azure/avm-ptn-alz-connectivity-virtual-wan/azurerm | 0.11.8 |

## Resources

| Name | Type |
|------|------|
| [external_external.architecture_template](https://registry.terraform.io/providers/hashicorp/external/latest/docs/data-sources/external) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_architecture_name"></a> [architecture\_name](#input\_architecture\_name) | Architecture name for the ALZ deployment | `string` | n/a | yes |
| <a name="input_connectivity_resource_groups"></a> [connectivity\_resource\_groups](#input\_connectivity\_resource\_groups) | A map of resource groups to create. These must be created before the connectivity module is applied.<br/><br/>The following attributes are supported:<br/><br/>  - name: The name of the resource group<br/>  - location: The location of the resource group<br/>  - settings: (Optional) An object, which can include an `enabled` setting value that indicates whether the resource group should be created. | <pre>map(object({<br/>    name     = string<br/>    location = string<br/>    tags     = optional(map(string))<br/>    settings = optional(any)<br/>  }))</pre> | `{}` | no |
| <a name="input_connectivity_type"></a> [connectivity\_type](#input\_connectivity\_type) | The type of network connectivity technology to use for the private DNS zones | `string` | `"hub_and_spoke_vnet"` | no |
| <a name="input_custom_replacements"></a> [custom\_replacements](#input\_custom\_replacements) | Custom replacements | <pre>object({<br/>    names                      = optional(map(string), {})<br/>    resource_group_identifiers = optional(map(string), {})<br/>    resource_identifiers       = optional(map(string), {})<br/>  })</pre> | <pre>{<br/>  "names": {},<br/>  "resource_group_identifiers": {},<br/>  "resource_identifiers": {}<br/>}</pre> | no |
| <a name="input_dependencies"></a> [dependencies](#input\_dependencies) | Dependencies for resource creation order | `map(list(string))` | `{}` | no |
| <a name="input_enable_telemetry"></a> [enable\_telemetry](#input\_enable\_telemetry) | Flag to enable/disable telemetry | `bool` | `true` | no |
| <a name="input_hub_and_spoke_vnet_settings"></a> [hub\_and\_spoke\_vnet\_settings](#input\_hub\_and\_spoke\_vnet\_settings) | The shared settings for the hub and spoke networks. This is where global resources are defined.<br/><br/>The following attributes are supported:<br/><br/>  - ddos\_protection\_plan: (Optional) The DDoS protection plan settings. Detailed information about the DDoS protection plan can be found in the module's README: https://registry.terraform.io/modules/Azure/avm-ptn-ddosprotectionplan | `any` | `{}` | no |
| <a name="input_hub_and_spoke_vnet_virtual_networks"></a> [hub\_and\_spoke\_vnet\_virtual\_networks](#input\_hub\_and\_spoke\_vnet\_virtual\_networks) | A map of hub networks to create.<br/><br/>The following attributes are supported:<br/><br/>  - hub\_virtual\_network: The hub virtual network settings. Detailed information about the hub virtual network can be found in the module's README: https://registry.terraform.io/modules/Azure/avm-ptn-hubnetworking<br/>  - virtual\_network\_gateways: (Optional) The virtual network gateway settings. Detailed information about the virtual network gateway can be found in the module's README: https://registry.terraform.io/modules/Azure/avm-ptn-vnetgateway<br/>  - private\_dns\_zones: (Optional) The private DNS zone settings. Detailed information about the private DNS zone can be found in the module's README: https://registry.terraform.io/modules/Azure/avm-ptn-network-private-link-private-dns-zones<br/>  - private\_dns\_resolver: (Optional) The private DNS resolver settings. Detailed information about the private DNS resolver can be found in the module's README: https://registry.terraform.io/modules/Azure/avm-res-network-dnsresolver/<br/>  - bastion: (Optional) The bastion host settings. Detailed information about the bastion can be found in the module's README: https://registry.terraform.io/modules/Azure/avm-res-network-bastionhost/ | <pre>map(object({<br/>    hub_virtual_network = any<br/>    virtual_network_gateways = optional(object({<br/>      subnet_address_prefix                     = string<br/>      subnet_default_outbound_access_enabled    = optional(bool, false)<br/>      route_table_creation_enabled              = optional(bool, false)<br/>      route_table_name                          = optional(string)<br/>      route_table_bgp_route_propagation_enabled = optional(bool, false)<br/>      express_route                             = optional(any)<br/>      vpn                                       = optional(any)<br/>    }))<br/>    private_dns_zones    = optional(any)<br/>    private_dns_resolver = optional(any)<br/>    bastion              = optional(any)<br/>  }))</pre> | `{}` | no |
| <a name="input_location"></a> [location](#input\_location) | Azure region for resource deployment | `string` | n/a | yes |
| <a name="input_management_group_settings"></a> [management\_group\_settings](#input\_management\_group\_settings) | The settings for the management groups. Details of the settings can be found in the module documentation at https://registry.terraform.io/modules/Azure/avm-ptn-alz | `any` | `{}` | no |
| <a name="input_management_resource_settings"></a> [management\_resource\_settings](#input\_management\_resource\_settings) | The settings for the management resources. Details of the settings can be found in the module documentation at https://registry.terraform.io/modules/Azure/avm-ptn-alz-management | `any` | `{}` | no |
| <a name="input_parent_resource_id"></a> [parent\_resource\_id](#input\_parent\_resource\_id) | Parent management group resource ID | `string` | n/a | yes |
| <a name="input_policy_assignments_to_modify"></a> [policy\_assignments\_to\_modify](#input\_policy\_assignments\_to\_modify) | Policy assignments to modify | <pre>map(object({<br/>    policy_assignments = map(object({<br/>      enforcement_mode = optional(string, null)<br/>      identity         = optional(string, null)<br/>      identity_ids     = optional(list(string), null)<br/>      parameters       = optional(map(any), null)<br/>    }))<br/>  }))</pre> | `{}` | no |
| <a name="input_root_display_name"></a> [root\_display\_name](#input\_root\_display\_name) | Display name for the root management group | `string` | `""` | no |
| <a name="input_root_id"></a> [root\_id](#input\_root\_id) | Root management group ID for the ALZ hierarchy | `string` | `""` | no |
| <a name="input_root_parent_management_group_id"></a> [root\_parent\_management\_group\_id](#input\_root\_parent\_management\_group\_id) | This is the id of the management group that the ALZ hierarchy will be nested under, will default to the Tenant Root Group | `string` | `""` | no |
| <a name="input_starter_locations"></a> [starter\_locations](#input\_starter\_locations) | The default for Azure resources. (e.g 'uksouth') | `list(string)` | n/a | yes |
| <a name="input_subscription_id_connectivity"></a> [subscription\_id\_connectivity](#input\_subscription\_id\_connectivity) | DEPRECATED (use subscription\_ids instead): The identifier of the Connectivity Subscription | `string` | `null` | no |
| <a name="input_subscription_id_identity"></a> [subscription\_id\_identity](#input\_subscription\_id\_identity) | DEPRECATED (use subscription\_ids instead): The identifier of the Identity Subscription | `string` | `null` | no |
| <a name="input_subscription_id_management"></a> [subscription\_id\_management](#input\_subscription\_id\_management) | DEPRECATED (use subscription\_ids instead): The identifier of the Management Subscription | `string` | `null` | no |
| <a name="input_subscription_ids"></a> [subscription\_ids](#input\_subscription\_ids) | The list of subscription IDs to deploy the Platform Landing Zones into | `map(string)` | `{}` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | (Optional) Tags of the resource. | `map(string)` | `null` | no |
| <a name="input_virtual_wan_settings"></a> [virtual\_wan\_settings](#input\_virtual\_wan\_settings) | The shared settings for the Virtual WAN. This is where global resources are defined.<br/><br/>The following attributes are supported:<br/><br/>  - ddos\_protection\_plan: (Optional) The DDoS protection plan settings. Detailed information about the DDoS protection plan can be found in the module's README: https://registry.terraform.io/modules/Azure/avm-ptn-ddosprotectionplan<br/><br/>The Virtual WAN module attributes are also supported. Detailed information about the Virtual WAN module variables can be found in the module's README: https://registry.terraform.io/modules/Azure/avm-ptn-virtualwan | `any` | `{}` | no |
| <a name="input_virtual_wan_virtual_hubs"></a> [virtual\_wan\_virtual\_hubs](#input\_virtual\_wan\_virtual\_hubs) | A map of virtual hubs to create.<br/><br/>The following attributes are supported:<br/><br/>  - hub: The virtual hub settings. Detailed information about the virtual hub can be found in the module's README: https://registry.terraform.io/modules/Azure/avm-ptn-virtualwan<br/>  - firewall: (Optional) The firewall settings. Detailed information about the firewall can be found in the Virtual WAN module's README: https://registry.terraform.io/modules/Azure/avm-ptn-virtualwan<br/>  - firewall\_policy: (Optional) The firewall policy settings. Detailed information about the firewall policy can be found in the module's README: https://registry.terraform.io/modules/Azure/avm-ptn-firewall-policy<br/>  - private\_dns\_zones: (Optional) The private DNS zone settings. Detailed information about the private DNS zone can be found in the module's README: https://registry.terraform.io/modules/Azure/avm-ptn-network-private-link-private-dns-zones<br/>  - private\_dns\_resolver: (Optional) The private DNS resolver settings. Detailed information about the private DNS resolver can be found in the module's README: https://registry.terraform.io/modules/Azure/avm-res-network-dnsresolver/<br/>  - bastion: (Optional) The bastion host settings. Detailed information about the bastion can be found in the module's README: https://registry.terraform.io/modules/Azure/avm-res-network-bastionhost/<br/>  - virtual\_network\_gateways: (Optional) The virtual network gateway settings. Detailed information about the virtual network gateway can be found in the Virtual WAN module's README: https://registry.terraform.io/modules/Azure/avm-ptn-virtualwan<br/>  - side\_car\_virtual\_network: (Optional) The side car virtual network settings. Detailed information about the side car virtual network can be found in the module's README: https://registry.terraform.io/modules/Azure/avm-res-network-virtualnetwork | <pre>map(object({<br/>    hub                  = any<br/>    firewall             = optional(any)<br/>    firewall_policy      = optional(any)<br/>    private_dns_zones    = optional(any)<br/>    private_dns_resolver = optional(any)<br/>    bastion              = optional(any)<br/>    virtual_network_gateways = optional(object({<br/>      express_route = optional(any)<br/>      vpn           = optional(any)<br/>    }))<br/>    side_car_virtual_network = optional(any)<br/>  }))</pre> | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_configuration"></a> [configuration](#output\_configuration) | Configuration object for compatibility with CAF module |
| <a name="output_dns_server_ip_address"></a> [dns\_server\_ip\_address](#output\_dns\_server\_ip\_address) | DNS server IP address from connectivity module |
| <a name="output_hub_and_spoke_vnet_firewall_policy_ids"></a> [hub\_and\_spoke\_vnet\_firewall\_policy\_ids](#output\_hub\_and\_spoke\_vnet\_firewall\_policy\_ids) | Hub and spoke firewall policy IDs |
| <a name="output_hub_and_spoke_vnet_firewall_private_ip_address"></a> [hub\_and\_spoke\_vnet\_firewall\_private\_ip\_address](#output\_hub\_and\_spoke\_vnet\_firewall\_private\_ip\_address) | Hub and spoke firewall private IP addresses |
| <a name="output_hub_and_spoke_vnet_firewall_public_ip_addresses"></a> [hub\_and\_spoke\_vnet\_firewall\_public\_ip\_addresses](#output\_hub\_and\_spoke\_vnet\_firewall\_public\_ip\_addresses) | Hub and spoke firewall public IP addresses |
| <a name="output_hub_and_spoke_vnet_firewall_resource_ids"></a> [hub\_and\_spoke\_vnet\_firewall\_resource\_ids](#output\_hub\_and\_spoke\_vnet\_firewall\_resource\_ids) | Hub and spoke firewall resource IDs |
| <a name="output_hub_and_spoke_vnet_firewall_resource_names"></a> [hub\_and\_spoke\_vnet\_firewall\_resource\_names](#output\_hub\_and\_spoke\_vnet\_firewall\_resource\_names) | Hub and spoke firewall resource names |
| <a name="output_hub_and_spoke_vnet_full_output"></a> [hub\_and\_spoke\_vnet\_full\_output](#output\_hub\_and\_spoke\_vnet\_full\_output) | Full hub and spoke virtual network module output |
| <a name="output_hub_and_spoke_vnet_route_tables_firewall"></a> [hub\_and\_spoke\_vnet\_route\_tables\_firewall](#output\_hub\_and\_spoke\_vnet\_route\_tables\_firewall) | Hub and spoke route tables for firewall |
| <a name="output_hub_and_spoke_vnet_route_tables_user_subnets"></a> [hub\_and\_spoke\_vnet\_route\_tables\_user\_subnets](#output\_hub\_and\_spoke\_vnet\_route\_tables\_user\_subnets) | Hub and spoke route tables for user subnets |
| <a name="output_hub_and_spoke_vnet_virtual_network_resource_ids"></a> [hub\_and\_spoke\_vnet\_virtual\_network\_resource\_ids](#output\_hub\_and\_spoke\_vnet\_virtual\_network\_resource\_ids) | Hub and spoke virtual network resource IDs |
| <a name="output_hub_and_spoke_vnet_virtual_network_resource_names"></a> [hub\_and\_spoke\_vnet\_virtual\_network\_resource\_names](#output\_hub\_and\_spoke\_vnet\_virtual\_network\_resource\_names) | Hub and spoke virtual network resource names |
| <a name="output_management_groups"></a> [management\_groups](#output\_management\_groups) | The management groups created by the ALZ module |
| <a name="output_management_resources"></a> [management\_resources](#output\_management\_resources) | Management resources module output |
| <a name="output_policy_assignments"></a> [policy\_assignments](#output\_policy\_assignments) | The policy assignments created by the ALZ module |
| <a name="output_policy_definitions"></a> [policy\_definitions](#output\_policy\_definitions) | The policy definitions created by the ALZ module |
| <a name="output_policy_set_definitions"></a> [policy\_set\_definitions](#output\_policy\_set\_definitions) | The policy set definitions created by the ALZ module |
| <a name="output_resource_groups"></a> [resource\_groups](#output\_resource\_groups) | Resource groups created by the module |
| <a name="output_templated_inputs"></a> [templated\_inputs](#output\_templated\_inputs) | Templated inputs from configuration module |
| <a name="output_virtual_wan_bastion_host_public_ip_address"></a> [virtual\_wan\_bastion\_host\_public\_ip\_address](#output\_virtual\_wan\_bastion\_host\_public\_ip\_address) | Virtual WAN bastion host public IP address |
| <a name="output_virtual_wan_bastion_host_resource_ids"></a> [virtual\_wan\_bastion\_host\_resource\_ids](#output\_virtual\_wan\_bastion\_host\_resource\_ids) | Virtual WAN bastion host resource IDs |
| <a name="output_virtual_wan_bastion_host_resources"></a> [virtual\_wan\_bastion\_host\_resources](#output\_virtual\_wan\_bastion\_host\_resources) | Virtual WAN bastion host resources |
| <a name="output_virtual_wan_express_route_gateway_resource_ids"></a> [virtual\_wan\_express\_route\_gateway\_resource\_ids](#output\_virtual\_wan\_express\_route\_gateway\_resource\_ids) | Virtual WAN ExpressRoute gateway resource IDs |
| <a name="output_virtual_wan_firewall_policy_ids"></a> [virtual\_wan\_firewall\_policy\_ids](#output\_virtual\_wan\_firewall\_policy\_ids) | Virtual WAN firewall policy IDs |
| <a name="output_virtual_wan_firewall_private_ip_address"></a> [virtual\_wan\_firewall\_private\_ip\_address](#output\_virtual\_wan\_firewall\_private\_ip\_address) | Virtual WAN firewall private IP address |
| <a name="output_virtual_wan_firewall_public_ip_addresses"></a> [virtual\_wan\_firewall\_public\_ip\_addresses](#output\_virtual\_wan\_firewall\_public\_ip\_addresses) | Virtual WAN firewall public IP addresses |
| <a name="output_virtual_wan_firewall_resource_ids"></a> [virtual\_wan\_firewall\_resource\_ids](#output\_virtual\_wan\_firewall\_resource\_ids) | Virtual WAN firewall resource IDs |
| <a name="output_virtual_wan_firewall_resource_names"></a> [virtual\_wan\_firewall\_resource\_names](#output\_virtual\_wan\_firewall\_resource\_names) | Virtual WAN firewall resource names |
| <a name="output_virtual_wan_full_output"></a> [virtual\_wan\_full\_output](#output\_virtual\_wan\_full\_output) | Full virtual WAN module output |
| <a name="output_virtual_wan_name"></a> [virtual\_wan\_name](#output\_virtual\_wan\_name) | Virtual WAN name |
| <a name="output_virtual_wan_private_dns_resolver_resource_ids"></a> [virtual\_wan\_private\_dns\_resolver\_resource\_ids](#output\_virtual\_wan\_private\_dns\_resolver\_resource\_ids) | Virtual WAN private DNS resolver resource IDs |
| <a name="output_virtual_wan_private_dns_resolver_resources"></a> [virtual\_wan\_private\_dns\_resolver\_resources](#output\_virtual\_wan\_private\_dns\_resolver\_resources) | Virtual WAN private DNS resolver resources |
| <a name="output_virtual_wan_resource_id"></a> [virtual\_wan\_resource\_id](#output\_virtual\_wan\_resource\_id) | Virtual WAN resource ID |
| <a name="output_virtual_wan_sidecar_virtual_network_resource_ids"></a> [virtual\_wan\_sidecar\_virtual\_network\_resource\_ids](#output\_virtual\_wan\_sidecar\_virtual\_network\_resource\_ids) | Virtual WAN sidecar virtual network resource IDs |
| <a name="output_virtual_wan_sidecar_virtual_network_resources"></a> [virtual\_wan\_sidecar\_virtual\_network\_resources](#output\_virtual\_wan\_sidecar\_virtual\_network\_resources) | Virtual WAN sidecar virtual network resources |
| <a name="output_virtual_wan_virtual_hub_resource_ids"></a> [virtual\_wan\_virtual\_hub\_resource\_ids](#output\_virtual\_wan\_virtual\_hub\_resource\_ids) | Virtual WAN virtual hub resource IDs |
| <a name="output_virtual_wan_virtual_hub_resource_names"></a> [virtual\_wan\_virtual\_hub\_resource\_names](#output\_virtual\_wan\_virtual\_hub\_resource\_names) | Virtual WAN virtual hub resource names |
<!-- END_TF_DOCS -->
