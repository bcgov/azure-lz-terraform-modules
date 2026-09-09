# Terraform State Transformation Script

## Overview

The `transform_state.py` script is a comprehensive tool for transforming Terraform state files when upgrading from **v4 to v6** of the [Azure Landing Zone Vending module](https://github.com/Azure/terraform-azurerm-lz-vending). It enables safe migration of existing Azure infrastructure state without destroying and recreating resources.

## Purpose

This script specifically addresses the migration from **v4 to v6** of the Azure Landing Zone Vending module, which includes:

- **Provider Migration**: Upgrading from `azurerm` provider to `azapi` provider for certain resources (subscriptions, management group associations)
- **Module Refactoring**: Moving resources into nested modules (e.g., virtual networks into `module.virtual_networks`)
- **Resource Renaming**: Updating resource names to match new module structure (e.g., `vhubconnection` → `vhubconnection_routing_intent`)
- **Provider Version Updates**: Aligning with newer `azapi` provider versions (v1.x → v2.x) that introduce schema changes
- **Schema Version Updates**: Updating resource schema versions to match new provider expectations

The script preserves all existing Azure resources by maintaining their Azure resource IDs while updating the Terraform state representation to match the v6 module structure.

### Related Resources

- **Module Repository**: [Azure/terraform-azurerm-lz-vending](https://github.com/Azure/terraform-azurerm-lz-vending)
- **Terraform Registry**: [registry.terraform.io/modules/Azure/lz-vending/azurerm](https://registry.terraform.io/modules/Azure/lz-vending/azurerm)

## Features

- **Self-contained**: Uses hardcoded transformation patterns (no external reference state required)
- **Resource preservation**: Maintains Azure resource IDs to prevent resource recreation
- **Address transformation**: Updates resource addresses to match new module structures
- **Provider conversion**: Converts `azurerm` resources to `azapi` equivalents
- **Schema alignment**: Aligns resource schemas with newer provider versions
- **Attribute cleanup**: Removes unsupported attributes that cause decoding errors

## Migration Workflow

The typical workflow for upgrading from v4 to v6:

1. **Update Terraform Configuration** (`main.tf`):
   - Update module source to v6.x version
   - Update provider version constraints:
     - `azurerm`: `>= 3.109.0, ~> 4.0`
     - `azapi`: `>= 1.13.1, ~> 2.2`
   - Remove obsolete resources (e.g., `null_resource.move_subscriptions_to_decom`)

2. **Pull Current State**:
   ```bash
   cd projects/<project_name>
   terraform init  # Reinitialize with new module version
   terraform state pull > <project>_current.tfstate
   ```

3. **Transform State**:
   ```bash
   python3 transform_state.py transform <project>_current.tfstate <project>_transformed.tfstate
   ```

4. **Verify Transformation**:
   ```bash
   terraform state list -state=<project>_transformed.tfstate
   terraform plan -state=<project>_transformed.tfstate
   ```

5. **Push Transformed State**:
   ```bash
   terraform state push <project>_transformed.tfstate
   terraform plan  # Should show minimal or no changes
   terraform apply  # Apply any necessary updates
   ```

## Usage

### Basic Usage

```bash
python3 transform_state.py transform <old_state_file> [output_file]
```

### Examples

```bash
# Transform a state file (output will be old_state_transformed.tfstate)
python3 transform_state.py transform projects/abc123/abc123_current.tfstate

# Specify custom output path
python3 transform_state.py transform projects/db78da/db78da_current.tfstate projects/db78da/db78da_transformed.tfstate

# With custom working directory
python3 transform_state.py transform old.tfstate new.tfstate --work-dir /path/to/terraform/project
```

## What Changed Between v4 and v6

The Azure Landing Zone Vending module underwent significant changes between v4 and v6:

1. **Provider Migration**: Subscription and management group resources moved from `azurerm` to `azapi` provider
2. **Module Restructuring**: Virtual networks moved into nested `module.virtual_networks` modules
3. **Resource Renaming**: Virtual hub connections renamed to routing intents
4. **Resource Group Organization**: Resource groups moved from `virtualnetwork` module to dedicated `resourcegroup` module
5. **Obsolete Resources**: Some resources like `azapi_update_resource.vnet` were removed
6. **Schema Updates**: `azapi` provider v2.x introduced new schema requirements for body types

## Transformation Patterns

The script applies the following hardcoded transformation patterns to migrate from v4 to v6:

### 1. Virtual Hub Connection → Routing Intent

**Pattern:**
```
azapi_resource.vhubconnection[{sub_key}] → azapi_resource.vhubconnection_routing_intent[{sub_key}]
```

**Example:**
```
module.project_set.module.lz_vending["dev"].module.virtualnetwork[0].azapi_resource.vhubconnection["vwan_spoke"]
→
module.project_set.module.lz_vending["dev"].module.virtualnetwork[0].azapi_resource.vhubconnection_routing_intent["vwan_spoke"]
```

### 2. Virtual Network → Nested Module

**Pattern:**
```
azapi_resource.vnet[{sub_key}] → module.virtual_networks[{sub_key}].azapi_resource.vnet
```

**Example:**
```
module.project_set.module.lz_vending["dev"].module.virtualnetwork[0].azapi_resource.vnet["vwan_spoke"]
→
module.project_set.module.lz_vending["dev"].module.virtualnetwork[0].module.virtual_networks["vwan_spoke"].azapi_resource.vnet
```

### 3. Virtual Network Update Resource → Nested Module

**Pattern:**
```
azapi_update_resource.vnet[{sub_key}] → module.virtual_networks[{sub_key}].azapi_update_resource.vnet
```

**Note:** This resource is typically removed as obsolete (see below).

### 4. Resource Groups → Resource Group Module

**Pattern:**
```
module.virtualnetwork[0].azapi_resource.rg[{rg_name}] → module.resourcegroup[{rg_name}].azapi_resource.rg
```

**Example:**
```
module.project_set.module.lz_vending["dev"].module.virtualnetwork[0].azapi_resource.rg["abc123-dev-networking"]
→
module.project_set.module.lz_vending["dev"].module.resourcegroup["abc123-dev-networking"].azapi_resource.rg
```

### 5. Network Watcher Resource Group

**Pattern:**
```
module.resourcegroup_networkwatcherrg[0].azapi_resource.rg → module.resourcegroup["NetworkWatcherRG"].azapi_resource.rg
```

**Example:**
```
module.project_set.module.lz_vending["dev"].module.resourcegroup_networkwatcherrg[0].azapi_resource.rg
→
module.project_set.module.lz_vending["dev"].module.resourcegroup["NetworkWatcherRG"].azapi_resource.rg
```

## Resource Conversions

### azurerm_subscription → azapi_resource.subscription

Converts `azurerm_subscription.this` resources to `azapi_resource.subscription` format:

- **Type**: `Microsoft.Subscription/aliases@2021-10-01`
- **Body**: Contains subscription properties (billing scope, display name, workload)
- **Output**: Contains subscription ID and properties

### azurerm_management_group_subscription_association → azapi_resource_action.subscription_association

Converts management group subscription associations to `azapi_resource_action`:

- **Type**: `Microsoft.Management/managementGroups/subscriptions@2021-04-01`
- **Method**: `PUT`
- **Resource ID**: Points to the management group subscription resource

## Schema Updates

### Schema Version Updates

- `azapi_update_resource` instances are updated to `schema_version = 2`

### Identity Schema Version

- Adds `identity_schema_version: 0` to all resource instances if not present

### Terraform Version

- Updates `terraform_version` to `1.13.4`
- Increments `serial` by 1

## Attribute Cleanup

The script removes unsupported attributes that cause decoding errors:

### Common Attributes (all resources)
- `ignore_body_changes`
- `removing_special_chars`

### azapi_resource_action Specific
- `ignore_casing`
- `ignore_missing_property`
- `location`

## Body Schema Alignment

The script aligns `azapi` resource `body` fields with expected schemas using a built-in registry:

### Object-Type Bodies (parsed from JSON strings)
- `azapi_resource.vnet`: Complex object with properties
- `azapi_update_resource.vnet`: Complex object with properties
- `azapi_resource.vhubconnection_routing_intent`: Object with `enableInternetSecurity` and `remoteVirtualNetwork`
- `azapi_resource.subscription`: Object with `properties.subscriptionId`
- `azapi_update_resource.subscription_tags`: Object with tags map

### String-Type Bodies (kept as JSON strings)
- `azapi_resource.telemetry_root`: String
- `azapi_resource.rg`: String

## Obsolete Resource Removal

The script removes resources that are no longer part of the configuration:

- `azapi_update_resource.vnet`: Removed as obsolete (no longer in config)

## Output

The script provides detailed output during transformation:

```
============================================================
STEP 1: Learning transformation patterns
============================================================

Using hardcoded transformation patterns (no reference state)

Using 5 transformation patterns:
  azapi_resource.vhubconnection[{sub_key}] -> azapi_resource.vhubconnection_routing_intent[{sub_key}] (vhubconnection -> vhubconnection_routing_intent)
  ...

============================================================
STEP 2: Transforming state file
============================================================

Loading old state from: projects/abc123/abc123_current.tfstate
Converting azurerm_subscription.this to azapi_resource.subscription
Converting azurerm_management_group_subscription_association.this to azapi_resource_action.subscription_association
Converted 1 azurerm_subscription resources
Converted 1 azurerm_management_group_subscription_association resources

Applying 5 address transformation patterns...
  Transformed: module.project_set.module.lz_vending["dev"].module.virtualnetwork[0].azapi_resource.vhubconnection["vwan_spoke"] -> module.project_set.module.lz_vending["dev"].module.virtualnetwork[0].azapi_resource.vhubconnection_routing_intent["vwan_spoke"]
  ...
Transformed 5 resource addresses (all resources preserved)
Removing unsupported attributes...
Removed unsupported attributes from 16 resources
Updating schema versions...
Updated schema_version for 1 resources
Aligning azapi bodies to builtin schemas...
Aligned body schema/value for 4 azapi resources
Updating terraform_version to: 1.13.4
Incrementing serial from 156 to 157
Removed 1 obsolete resource(s) (e.g., azapi_update_resource.vnet)
Saving transformed state to: projects/abc123/abc123_current_transformed.tfstate
Transformation complete!
```

## Verification

After transformation, verify the state file:

```bash
# List resources in transformed state
terraform state list -state=projects/abc123/abc123_current_transformed.tfstate

# Run terraform plan to verify no unexpected changes
cd projects/abc123
terraform plan -state=abc123_current_transformed.tfstate
```

## Version Compatibility

- **Source Version**: Azure Landing Zone Vending module v4.x
- **Target Version**: Azure Landing Zone Vending module v6.x
- **Terraform Version**: Updated to 1.13.4
- **azapi Provider**: v1.x → v2.x (>= 1.13.1, ~> 2.2)
- **azurerm Provider**: >= 3.109.0, ~> 4.0

## Important Notes

1. **Backup First**: Always backup your original state file before transformation
2. **Test in Non-Production**: Test the transformation on a non-production environment first
3. **Verify Plan**: Run `terraform plan` after transformation to ensure no unexpected changes
4. **Azure IDs Preserved**: The script preserves Azure resource IDs to prevent resource recreation
5. **Project-Specific Resources**: Resources that don't match transformation patterns are preserved as-is
6. **Module Version**: Ensure your `main.tf` references the v6.x version of the module before applying the transformed state
7. **Provider Versions**: Update your provider version constraints to match v6 requirements before running `terraform plan`

## Troubleshooting

### Empty State File

If you get a JSON decode error, ensure the state file was pulled correctly:

```bash
cd projects/<project_name>
terraform init
terraform state pull > <project>_current.tfstate
```

### Unsupported Attributes Warning

If you see warnings about unsupported attributes, the script should handle these automatically. If not, check that you're using the latest version of the script.

### Schema Version Errors

If you encounter schema version errors, ensure the script has updated `schema_version` for `azapi_update_resource` resources. Check the output for "Updated schema_version" messages.

### Body Format Errors

If Terraform complains about body format (e.g., "cannot unmarshal string into Go value"), verify that the script has aligned the body schemas. Check the output for "Aligned body schema/value" messages.

## Architecture

The script uses a two-step process:

1. **Pattern Learning**: Identifies transformation patterns (hardcoded, no external reference)
2. **State Transformation**: Applies patterns to transform the state file

Key components:
- `StateTransformer`: Main transformation class
- `_get_hardcoded_transformation_patterns()`: Returns hardcoded patterns
- `_apply_move_patterns()`: Applies address transformations
- `_align_azapi_bodies_to_reference()`: Aligns body schemas using built-in registry
- `_remove_unsupported_attributes()`: Cleans up unsupported attributes
- `_update_schema_versions()`: Updates schema versions

## Contributing

When adding new transformation patterns:

1. Add the pattern to `_get_hardcoded_transformation_patterns()`
2. Add any required body schemas to `_get_builtin_body_types()`
3. Test on a sample state file
4. Update this documentation
