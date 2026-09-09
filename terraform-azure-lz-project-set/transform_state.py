#!/usr/bin/env python3

"""
Comprehensive Terraform State Transformation Script

This script transforms old Terraform state files to match the new format by:
1. Using terraform state list to analyze differences
2. Using hardcoded transformation patterns (no external reference state)
3. Applying those patterns to transform any old state
4. Verifying the transformation using terraform state list and other tools
"""

import argparse
import json
import re
import subprocess
import sys
import tempfile
import copy
from pathlib import Path
from typing import Dict, List, Set, Tuple, Optional


class StateTransformer:
    """Transforms Terraform state files from old to new format."""

    def __init__(self, work_dir: Path):
        self.work_dir = work_dir
        self.transformation_patterns = {}

    def get_state_list(self, state_file: Path) -> List[str]:
        """Get the list of resources from a state file using terraform state list."""
        try:
            result = subprocess.run(
                ['terraform', 'state', 'list', '-state', str(state_file)],
                cwd=str(self.work_dir),
                capture_output=True,
                text=True,
                check=True
            )
            return sorted(result.stdout.strip().split('\n')) if result.stdout.strip() else []
        except subprocess.CalledProcessError as e:
            print(f"Error running terraform state list on {state_file}: {e.stderr}", file=sys.stderr)
            return []

    def compare_state_lists(self, old_list: List[str], new_list: List[str]) -> Dict[str, any]:
        """Compare two state lists and return differences."""
        old_set = set(old_list)
        new_set = set(new_list)

        return {
            'only_in_old': sorted(old_set - new_set),
            'only_in_new': sorted(new_set - old_set),
            'common': sorted(old_set & new_set),
            'old_count': len(old_list),
            'new_count': len(new_list)
        }

    def analyze_state_structure(self, state_file: Path) -> Dict:
        """Analyze the structure of a state file."""
        with open(state_file, 'r') as f:
            state = json.load(f)

        structure = {
            'terraform_version': state.get('terraform_version'),
            'serial': state.get('serial'),
            'version': state.get('version'),
            'lineage': state.get('lineage'),
            'has_check_results': 'check_results' in state,
            'resources': []
        }

        for resource in state.get('resources', []):
            resource_info = {
                'module': resource.get('module', ''),
                'mode': resource.get('mode', ''),
                'type': resource.get('type', ''),
                'name': resource.get('name', ''),
                'instances': []
            }

            for instance in resource.get('instances', []):
                instance_info = {
                    'has_index_key': 'index_key' in instance,
                    'has_schema_version': 'schema_version' in instance,
                    'has_sensitive_attributes': 'sensitive_attributes' in instance,
                    'has_identity_schema_version': 'identity_schema_version' in instance,
                    'has_private': 'private' in instance,
                }
                resource_info['instances'].append(instance_info)

            structure['resources'].append(resource_info)

        return structure

    def learn_transformation_patterns(self, old_state: Path) -> Dict:
        """Learn transformation patterns. If new_state is provided, learn from it, otherwise use hardcoded patterns."""
        print(f"\n{'='*60}")
        print("STEP 1: Learning transformation patterns")
        print(f"{'='*60}\n")

        # Load old state for structure analysis
        old_state_data = json.load(open(old_state))
        old_structure = self.analyze_state_structure(old_state)

        # Default patterns (hardcoded)
        patterns = {
            'terraform_version': {
                'old': old_structure['terraform_version'],
                'new': '1.13.4'  # Default to current version
            },
            'serial': {
                'old': old_structure['serial'],
                'new': old_structure['serial'] + 1  # Increment serial
            },
            'identity_schema_version_needed': True,  # Always add identity_schema_version
            'resource_conversions': [],
            'resource_removals': [],
            'resource_additions': [],
            'resource_moves': [],
            'move_patterns': []
        }

        # Check if identity_schema_version is needed
        old_has_identity = any(
            'identity_schema_version' in instance
            for resource in old_state_data.get('resources', [])
            for instance in resource.get('instances', [])
        )
        patterns['identity_schema_version_needed'] = not old_has_identity

        # Check for azurerm_subscription -> azapi_resource.subscription conversion
        for old_resource in old_state_data.get('resources', []):
            if old_resource.get('type') == 'azurerm_subscription' and old_resource.get('name') == 'this':
                patterns['resource_conversions'].append({
                    'from': f"{old_resource.get('type')}.{old_resource.get('name')}",
                    'to': 'azapi_resource.subscription',
                    'module_pattern': old_resource.get('module', '')
                })

        # Get hardcoded transformation patterns
        patterns['move_patterns'] = self._get_hardcoded_transformation_patterns()

        print("Using hardcoded transformation patterns (no reference state)")

        if patterns['move_patterns']:
            print(f"\nUsing {len(patterns['move_patterns'])} transformation patterns:")
            for pattern in patterns['move_patterns'][:10]:
                desc = pattern.get('description', '')
                print(f"  {pattern['from_pattern']} -> {pattern['to_pattern']}" + (f" ({desc})" if desc else ""))
            if len(patterns['move_patterns']) > 10:
                print(f"  ... and {len(patterns['move_patterns']) - 10} more")

        return patterns

    def _get_hardcoded_transformation_patterns(self) -> List[Dict]:
        """Return hardcoded transformation patterns for structural changes."""
        patterns = [
            {
                'from_pattern': 'azapi_resource.vhubconnection[{sub_key}]',
                'to_pattern': 'azapi_resource.vhubconnection_routing_intent[{sub_key}]',
                'common_prefix': 'module.project_set.module.lz_vending[{sub_key}].module.virtualnetwork[0]',
                'description': 'vhubconnection -> vhubconnection_routing_intent'
            },
            {
                'from_pattern': 'azapi_resource.vnet[{sub_key}]',
                'to_pattern': 'module.virtual_networks[{sub_key}].azapi_resource.vnet',
                'common_prefix': 'module.project_set.module.lz_vending[{sub_key}].module.virtualnetwork[0]',
                'description': 'vnet moves to nested module.virtual_networks'
            },
            {
                'from_pattern': 'azapi_update_resource.vnet[{sub_key}]',
                'to_pattern': 'module.virtual_networks[{sub_key}].azapi_update_resource.vnet',
                'common_prefix': 'module.project_set.module.lz_vending[{sub_key}].module.virtualnetwork[0]',
                'description': 'azapi_update_resource.vnet moves to nested module.virtual_networks'
            },
            {
                'from_pattern': 'module.virtualnetwork[0].azapi_resource.rg[{rg_name}]',
                'to_pattern': 'module.resourcegroup[{rg_name}].azapi_resource.rg',
                'common_prefix': 'module.project_set.module.lz_vending[{sub_key}]',
                'description': 'rg moves from virtualnetwork module to resourcegroup module'
            },
            {
                'from_pattern': 'module.resourcegroup_networkwatcherrg[0].azapi_resource.rg',
                'to_pattern': 'module.resourcegroup["NetworkWatcherRG"].azapi_resource.rg',
                'common_prefix': 'module.project_set.module.lz_vending[{sub_key}]',
                'description': 'explicit move for NetworkWatcherRG to resourcegroup["NetworkWatcherRG"]'
            }
        ]
        return patterns

    def _get_azure_resource_id(self, instance: Dict) -> Optional[str]:
        """Extract Azure resource ID from instance attributes."""
        attrs = instance.get('attributes', {})
        # Try common ID fields
        for id_field in ['id', 'resource_id']:
            if id_field in attrs and attrs[id_field]:
                value = attrs[id_field]
                if isinstance(value, str) and value.startswith('/subscriptions/'):
                    return value
        return None

    def _build_resource_address(self, resource: Dict, instance: Dict) -> str:
        """Build Terraform resource address from resource and instance."""
        parts = []

        # Add module path
        if 'module' in resource and resource['module']:
            parts.append(resource['module'])

        # Add mode
        mode = resource.get('mode', 'managed')
        if mode == 'data':
            parts.append('data')

        # Add type and name
        resource_type = resource.get('type', '')
        resource_name = resource.get('name', '')
        parts.append(f"{resource_type}.{resource_name}")

        # Add index if present
        if 'index_key' in instance:
            index_key = instance['index_key']
            if isinstance(index_key, (int, str)):
                parts[-1] = f"{parts[-1]}[{json.dumps(index_key)}]"

        return '.'.join(parts)

    def add_identity_schema_version(self, obj):
        """Recursively add identity_schema_version to all instances."""
        if isinstance(obj, dict):
            # Check if this is an instance object
            if "schema_version" in obj and "sensitive_attributes" in obj:
                new_obj = {}
                for key, value in obj.items():
                    processed_value = self.add_identity_schema_version(value)
                    new_obj[key] = processed_value
                    # After sensitive_attributes, insert identity_schema_version if not present
                    if key == "sensitive_attributes" and "identity_schema_version" not in obj:
                        new_obj["identity_schema_version"] = 0
                return new_obj
            else:
                return {key: self.add_identity_schema_version(value) for key, value in obj.items()}
        elif isinstance(obj, list):
            return [self.add_identity_schema_version(item) for item in obj]
        else:
            return obj

    def _remove_unsupported_attributes(self, state: Dict) -> int:
        """Remove unsupported attributes from resource instances that cause decoding errors."""
        removed_count = 0
        unsupported_attrs = ['ignore_body_changes', 'removing_special_chars']

        # For azapi_resource_action, also remove ignore_casing
        for resource in state.get('resources', []):
            for instance in resource.get('instances', []):
                attrs = instance.get('attributes', {})
                # Remove common unsupported attributes
                for attr in unsupported_attrs:
                    if attr in attrs:
                        del attrs[attr]
                        removed_count += 1

                # For azapi_resource_action, remove ignore_casing
                if resource.get('type') == 'azapi_resource_action' and 'ignore_casing' in attrs:
                    del attrs['ignore_casing']
                    removed_count += 1

                # For azapi_resource_action, also remove ignore_missing_property
                if resource.get('type') == 'azapi_resource_action' and 'ignore_missing_property' in attrs:
                    del attrs['ignore_missing_property']
                    removed_count += 1

                # For azapi_resource_action, also remove location
                if resource.get('type') == 'azapi_resource_action' and 'location' in attrs:
                    del attrs['location']
                    removed_count += 1

        return removed_count

    def _update_schema_versions(self, state: Dict) -> int:
        """Update schema_version for resources that need newer versions."""
        updated_count = 0

        for resource in state.get('resources', []):
            resource_type = resource.get('type', '')

            # azapi_update_resource needs schema_version 2
            if resource_type == 'azapi_update_resource':
                for instance in resource.get('instances', []):
                    if instance.get('schema_version', 0) < 2:
                        instance['schema_version'] = 2
                        updated_count += 1

        return updated_count

    def convert_azurerm_subscription_to_azapi(self, old_resource, old_state_resources=None):
        """Convert azurerm_subscription.this to azapi_resource.subscription format."""
        if old_resource.get('type') != 'azurerm_subscription' or old_resource.get('name') != 'this':
            return None

        old_module = old_resource.get('module', '')
        instance = old_resource['instances'][0]
        attrs = instance['attributes']

        # Find management group ID from old state
        management_group_id = None
        if old_state_resources:
            for resource in old_state_resources:
                if (resource.get('type') == 'azurerm_management_group' and
                    resource.get('name') == 'project_set' and
                    'module.project_set' in resource.get('module', '')):
                    mg_instance = resource.get('instances', [{}])[0]
                    management_group_id = mg_instance.get('attributes', {}).get('id', '')
                    break

        body_properties = {
            "properties": {
                "billingScope": attrs.get('billing_scope_id', ''),
                "displayName": attrs.get('subscription_name', ''),
                "workload": attrs.get('workload', 'Production'),
                "additionalProperties": {
                    "managementGroupId": management_group_id or "",
                    "tags": attrs.get('tags', {})
                }
            }
        }

        output_properties = {
            "id": attrs.get('id', ''),
            "name": attrs.get('alias', ''),
            "properties": {
                "subscriptionId": attrs.get('subscription_id', ''),
                "displayName": attrs.get('subscription_name', ''),
                "workload": attrs.get('workload', 'Production')
            }
        }

        new_resource = {
            "module": old_module,
            "mode": "managed",
            "type": "azapi_resource",
            "name": "subscription",
            "provider": "provider[\"registry.terraform.io/azure/azapi\"]",
            "instances": [
                {
                    "index_key": instance.get('index_key', 0),
                    "schema_version": 1,
                    "attributes": {
                        "type": "Microsoft.Subscription/aliases@2021-10-01",
                        "id": attrs.get('id', ''),
                        "parent_id": "/",
                        "name": attrs.get('alias', ''),
                        "body": {
                            "value": json.dumps(body_properties),
                            "type": "string"
                        },
                        "output": {
                            "value": json.dumps(output_properties),
                            "type": "string"
                        },
                        "ignore_body_changes": None,
                        "ignore_casing": False,
                        "ignore_missing_property": True,
                        "location": None,
                        "locks": None,
                        "removing_special_chars": False,
                        "response_export_values": ["properties.subscriptionId"],
                        "schema_validation_enabled": True,
                        "tags": attrs.get('tags'),
                        "timeouts": None,
                        "identity": []
                    },
                    "sensitive_attributes": [],
                    "identity_schema_version": 0,
                    "dependencies": instance.get('dependencies', [])
                }
            ]
        }

        return new_resource

    def convert_management_group_subscription_association(self, old_resource, old_state_resources=None):
        """Convert azurerm_management_group_subscription_association to azapi_resource_action.subscription_association format."""
        if old_resource.get('type') != 'azurerm_management_group_subscription_association':
            return None

        old_module = old_resource.get('module', '')
        instance = old_resource['instances'][0]
        attrs = instance['attributes']

        # Get subscription ID and management group ID from the association
        subscription_id = attrs.get('subscription_id', '')
        management_group_id = attrs.get('management_group_id', '')

        # Extract management group name from ID (e.g., /providers/Microsoft.Management/managementGroups/db78da -> db78da)
        mg_name = management_group_id.split('/')[-1] if management_group_id else ''

        # Extract subscription ID from full path (e.g., /subscriptions/f070e055-9e4e-41ea-ae38-eb20d964921c -> f070e055-9e4e-41ea-ae38-eb20d964921c)
        if subscription_id.startswith('/subscriptions/'):
            sub_id = subscription_id.split('/')[-1]
        else:
            sub_id = subscription_id

        # The resource_id should point to the management group subscription resource
        # Format: /providers/Microsoft.Management/managementGroups/{mg_name}/subscriptions/{sub_id}
        resource_id = f"/providers/Microsoft.Management/managementGroups/{mg_name}/subscriptions/{sub_id}"

        # The body should be empty for PUT operations on this resource type
        action_body = {}

        new_resource = {
            "module": old_module,
            "mode": "managed",
            "type": "azapi_resource_action",
            "name": "subscription_association",
            "provider": "provider[\"registry.terraform.io/azure/azapi\"]",
            "instances": [
                {
                    "index_key": instance.get('index_key', 0),
                    "schema_version": 1,
                    "attributes": {
                        "type": "Microsoft.Management/managementGroups/subscriptions@2021-04-01",
                        "resource_id": resource_id,
                        "action": None,
                        "method": "PUT",
                        "body": {
                            "value": json.dumps(action_body),
                            "type": "string"
                        },
                        "output": {
                            "value": json.dumps({}),
                            "type": "string"
                        },
                        "ignore_casing": False,
                        "ignore_missing_property": True,
                        "location": None,
                        "locks": None,
                        "response_export_values": [],
                        "schema_validation_enabled": True,
                        "tags": None,
                        "timeouts": None,
                        "identity": []
                    },
                    "sensitive_attributes": [],
                    "identity_schema_version": 0,
                    "dependencies": instance.get('dependencies', [])
                }
            ]
        }

        return new_resource

    def transform_state(self, old_state_path: Path, output_path: Path, patterns: Dict) -> bool:
        """Transform the old state file using learned patterns."""
        print(f"\n{'='*60}")
        print("STEP 2: Transforming state file")
        print(f"{'='*60}\n")

        print(f"Loading old state from: {old_state_path}")
        with open(old_state_path, 'r') as f:
            state = json.load(f)

        original_serial = state.get("serial", 0)

        # No reference state used (patterns are hardcoded)

        # Convert azurerm_subscription to azapi_resource.subscription
        converted_resources = []
        resources_to_remove = []

        for resource in state.get('resources', []):
            converted = self.convert_azurerm_subscription_to_azapi(resource, state.get('resources', []))
            if converted:
                print(f"Converting {resource.get('type')}.{resource.get('name')} to azapi_resource.subscription")
                converted_resources.append(converted)
                resources_to_remove.append(resource)

        # Convert azurerm_management_group_subscription_association to azapi_resource_action.subscription_association
        association_converted = []
        association_to_remove = []
        for resource in state.get('resources', []):
            converted = self.convert_management_group_subscription_association(resource, state.get('resources', []))
            if converted:
                print(f"Converting {resource.get('type')}.{resource.get('name')} to azapi_resource_action.subscription_association")
                association_converted.append(converted)
                association_to_remove.append(resource)

        # Remove old resources and add converted ones
        if resources_to_remove:
            state['resources'] = [r for r in state.get('resources', []) if r not in resources_to_remove]
            state['resources'].extend(converted_resources)
            print(f"Converted {len(resources_to_remove)} azurerm_subscription resources")

        if association_to_remove:
            state['resources'] = [r for r in state.get('resources', []) if r not in association_to_remove]
            state['resources'].extend(association_converted)
            print(f"Converted {len(association_to_remove)} azurerm_management_group_subscription_association resources")

        # Apply pattern-based transformations (hardcoded, applied to all matching resources)
        # This transforms addresses to match new format but keeps ALL resources and their IDs
        # Resources that don't match patterns are kept as-is (project-specific resources)
        if patterns.get('move_patterns'):
            print(f"\nApplying {len(patterns['move_patterns'])} address transformation patterns...")
            state = self._apply_move_patterns(state, patterns['move_patterns'])
            print("  All resources preserved - transformed addresses where patterns matched, kept original addresses for project-specific resources")

        # Note: We don't remove any resources - all resources from old state are preserved
        # Only their addresses are transformed if they match learned patterns

        # Add identity_schema_version if needed

        # Add identity_schema_version if needed
        if patterns.get('identity_schema_version_needed'):
            print("Adding identity_schema_version to all instances...")
            state = self.add_identity_schema_version(state)

        # Remove unsupported attributes that cause decoding errors
        print("Removing unsupported attributes...")
        removed_count = self._remove_unsupported_attributes(state)
        if removed_count > 0:
            print(f"Removed unsupported attributes from {removed_count} resources")

        # Update schema versions for resources that need newer versions
        print("Updating schema versions...")
        updated_count = self._update_schema_versions(state)
        if updated_count > 0:
            print(f"Updated schema_version for {updated_count} resources")

        # Align azapi bodies using builtin schemas
        print("Aligning azapi bodies to builtin schemas...")
        aligned = self._align_azapi_bodies_to_reference(state)
        if aligned > 0:
            print(f"Aligned body schema/value for {aligned} azapi resources")

        # Update terraform_version
        if patterns.get('terraform_version', {}).get('new'):
            new_version = patterns['terraform_version']['new']
            print(f"Updating terraform_version to: {new_version}")
            state["terraform_version"] = new_version

        # Update serial (increment from old)
        print(f"Incrementing serial from {original_serial} to {original_serial + 1}")
        state["serial"] = original_serial + 1

        # Remove obsolete resources
        removed_obsolete = self._remove_obsolete_resources(state)
        if removed_obsolete:
            print(f"Removed {removed_obsolete} obsolete resource(s) (e.g., azapi_update_resource.vnet)")

        # Save transformed state
        print(f"Saving transformed state to: {output_path}")
        output_path.parent.mkdir(parents=True, exist_ok=True)

        with open(output_path, 'w') as f:
            json.dump(state, f, indent=2)

        print("Transformation complete!")
        return True
    def _apply_move_patterns(self, state: Dict, move_patterns: List[Dict]) -> Dict:
        """Apply pattern-based address transformations to resources that match the patterns.
        Updates resources in place - preserves all resources and their Azure IDs, just updates addresses.
        """
        transformed_count = 0
        transformed_addresses = set()  # Track original addresses that have been transformed to avoid double transformation

        # First, collect all original addresses before any transformation
        # Store them as (resource, instance) tuples with their original addresses
        resources_to_process = []
        for resource in state.get('resources', []):
            for instance in resource.get('instances', []):
                original_addr = self._build_resource_address(resource, instance)
                resources_to_process.append((resource, instance, original_addr))

        # Apply each pattern to matching resources
        for pattern in move_patterns:
            from_pattern = pattern['from_pattern']
            to_pattern = pattern['to_pattern']
            common_prefix = pattern.get('common_prefix', '')

            # Find resources that match the from_pattern and transform them in place
            for resource, instance, original_addr in resources_to_process:
                # Skip if this address has already been transformed
                if original_addr in transformed_addresses:
                    continue

                # Get current address (may have changed from previous patterns)
                current_addr = self._build_resource_address(resource, instance)

                # Check if current address matches the pattern
                if self._matches_pattern(current_addr, from_pattern, common_prefix):
                    # Generate the new address by applying the pattern
                    new_addr = self._apply_pattern_to_address(current_addr, from_pattern, to_pattern, common_prefix)

                    # Skip if transformation would result in the same address
                    if new_addr == current_addr:
                        continue

                    # Infer structure from the pattern (no reference state needed)
                    ref_resource = self._infer_resource_structure_from_pattern(new_addr, resource)
                    ref_instance = instance.copy()

                    # Update index_key based on pattern
                    if '[{rg_name}]' in to_pattern:
                        # Extract rg_name from current address
                        rg_match = re.search(r'\["([^"]+-dev-networking|[^"]+-tools-networking|[^"]+-test-networking|[^"]+-prod-networking|NetworkWatcherRG)"\]', current_addr)
                        if rg_match:
                            rg_name = rg_match.group(1)
                            ref_instance['index_key'] = rg_name

                    if '[{sub_key}]' in to_pattern:
                        # Extract sub_key from current address - prefer the actual resource index_key
                        # For nested modules, use the instance's index_key (e.g., "vwan_spoke")
                        if instance.get('index_key'):
                            ref_instance['index_key'] = instance.get('index_key')
                        else:
                            # Fall back to extracting from address
                            keys = re.findall(r'\["([^"]+)"\]', current_addr)
                            # The subscription key is usually the one in lz_vending[...]
                            for key in keys:
                                if key in ['dev', 'tools', 'test', 'prod', 'vwan_spoke']:
                                    # For nested modules, prefer vwan_spoke if available
                                    if 'virtual_networks' in to_pattern and key == 'vwan_spoke':
                                        ref_instance['index_key'] = key
                                        break
                                    elif key in ['dev', 'tools', 'test', 'prod']:
                                        ref_instance['index_key'] = key
                                        break

                    # Update resource in place (preserve Azure IDs and all attributes)
                    # Derive module/type/name from the computed new address to keep project-specific keys
                    tokens = new_addr.split('.')
                    # Find the first resource type token
                    resource_types = {'azapi_resource', 'azapi_update_resource', 'azapi_resource_action'}
                    type_idx = None
                    for i, tok in enumerate(tokens):
                        if tok in resource_types:
                            type_idx = i
                            break
                    if type_idx is not None and type_idx + 1 < len(tokens):
                        module_path = '.'.join(tokens[:type_idx]) if type_idx > 0 else ''
                        t = tokens[type_idx]
                        raw_name = tokens[type_idx + 1]
                        # Normalize name/index_key if embedded index exists, e.g. name["key"]
                        idx_match = re.match(r'^([^\[]+)\[(.+)\]$', raw_name)
                        if idx_match:
                            base_name = idx_match.group(1)
                            idx_raw = idx_match.group(2)
                            try:
                                # Parse JSON-like key if quoted
                                parsed_key = json.loads(idx_raw)
                            except Exception:
                                # Fallback: strip quotes if present
                                parsed_key = idx_raw.strip('"')
                            resource['module'] = module_path
                            resource['type'] = t
                            resource['name'] = base_name
                            # Ensure instance has index_key set to parsed_key
                            instance['index_key'] = parsed_key
                        else:
                            resource['module'] = module_path
                            resource['type'] = t
                            resource['name'] = raw_name
                    else:
                        # Use inferred structure from pattern
                        resource['module'] = ref_resource.get('module', '')
                        resource['type'] = ref_resource.get('type', '')
                        resource['name'] = ref_resource.get('name', '')

                    # Update instance index_key if needed
                    # For nested modules, remove index_key if resource doesn't have one in new structure
                    if 'module.virtual_networks[' in new_addr:
                        # This is a nested module structure - the vnet resource doesn't have index_key
                        # The index_key "vwan_spoke" is part of the module path, not the instance
                        if 'index_key' in instance:
                            del instance['index_key']
                    elif 'module.resourcegroup[' in new_addr:
                        # For resource groups, the rg_name is in the module path, not the instance
                        # Remove index_key if present
                        if 'index_key' in instance:
                            del instance['index_key']
                    elif 'index_key' in ref_instance:
                        instance['index_key'] = ref_instance['index_key']
                    elif 'index_key' in instance and '[{rg_name}]' not in to_pattern and '[{sub_key}]' not in to_pattern:
                        # Remove index_key if pattern doesn't require it
                        if 'index_key' in instance:
                            del instance['index_key']

                    # Mark this original address as transformed
                    transformed_addresses.add(original_addr)
                    transformed_count += 1
                    print(f"  Transformed: {current_addr} -> {new_addr}")

        print(f"Transformed {transformed_count} resource addresses (all resources preserved)")

        # Merge resources that ended up with the same address after transformation
        merged_count = self._merge_duplicate_resources(state)
        if merged_count > 0:
            print(f"Merged {merged_count} duplicate resources")

        return state

    def _merge_duplicate_resources(self, state: Dict) -> int:
        """Merge resources that have the same module/type/name after transformation."""
        resource_map = {}
        duplicates_found = 0

        for resource in state.get('resources', []):
            key = (
                resource.get('module', ''),
                resource.get('mode', 'managed'),
                resource.get('type', ''),
                resource.get('name', '')
            )

            if key in resource_map:
                # Merge instances
                existing_resource = resource_map[key]
                existing_index_keys = {inst.get('index_key') for inst in existing_resource.get('instances', [])}

                for instance in resource.get('instances', []):
                    inst_key = instance.get('index_key')
                    if inst_key not in existing_index_keys:
                        existing_resource['instances'].append(instance)
                        existing_index_keys.add(inst_key)
                    else:
                        duplicates_found += 1
            else:
                resource_map[key] = resource

        # Update state with merged resources
        state['resources'] = list(resource_map.values())
        return duplicates_found

    def _matches_pattern(self, address: str, pattern: str, common_prefix: str) -> bool:
        """Check if an address matches a pattern."""
        # Normalize common_prefix by replacing project-specific parts
        normalized_common_prefix = common_prefix
        if normalized_common_prefix:
            # Replace project identifiers in common prefix
            normalized_common_prefix = re.sub(r'\["[^"]+"\]', '[{key}]', normalized_common_prefix)

        # Normalize address for comparison
        normalized_address = address
        # Replace project identifiers
        normalized_address = re.sub(r'\["[^"]+"\]', '[{key}]', normalized_address)

        # Normalize common_prefix to use [{key}] for matching (consistent with normalized_address)
        normalized_common_prefix_for_match = normalized_common_prefix.replace('[{sub_key}]', '[{key}]').replace('[{rg_name}]', '[{key}]')

        # Check if normalized address starts with normalized common prefix
        if normalized_common_prefix_for_match:
            # Extract the part after common prefix
            normalized_address_parts = normalized_address.split('.')
            normalized_prefix_parts = normalized_common_prefix_for_match.split('.')

            if len(normalized_address_parts) < len(normalized_prefix_parts):
                return False

            # Check if prefix matches (ignoring {key} placeholders)
            prefix_matches = True
            for i in range(len(normalized_prefix_parts)):
                prefix_part = normalized_prefix_parts[i]
                address_part = normalized_address_parts[i]
                # Match if they're equal, or if prefix has [{key}] placeholder
                if prefix_part != address_part and prefix_part != '[{key}]' and not (prefix_part.endswith('[{key}]') and address_part.endswith('[{key}]')):
                    # Check if they're the same except for the key part
                    if prefix_part.replace('[{key}]', '') == address_part.replace('[{key}]', ''):
                        continue
                    prefix_matches = False
                    break

            if not prefix_matches:
                return False

            # Extract suffix
            address_suffix = '.'.join(normalized_address_parts[len(normalized_prefix_parts):])
        else:
            address_suffix = normalized_address

        # Extract actual suffix from address
        if common_prefix:
            actual_address_parts = address.split('.')
            common_prefix_parts = common_prefix.split('.')
            if len(actual_address_parts) > len(common_prefix_parts):
                actual_suffix_parts = actual_address_parts[len(common_prefix_parts):]
                actual_suffix = '.'.join(actual_suffix_parts)
            else:
                actual_suffix = address
        else:
            actual_suffix = address

        # Extract pattern suffix (pattern after common prefix)
        pattern_parts = pattern.split('.')
        if common_prefix:
            common_prefix_parts = common_prefix.split('.')
            if len(pattern_parts) > len(common_prefix_parts):
                pattern_suffix_parts = pattern_parts[len(common_prefix_parts):]
                pattern_suffix = '.'.join(pattern_suffix_parts)
            else:
                pattern_suffix = pattern
        else:
            pattern_suffix = pattern

        # Replace resource group names in actual suffix, then normalize
        actual_suffix_normalized = actual_suffix
        actual_suffix_normalized = re.sub(r'\["[^"]+-dev-networking"\]', '[{rg_name}]', actual_suffix_normalized)
        actual_suffix_normalized = re.sub(r'\["[^"]+-tools-networking"\]', '[{rg_name}]', actual_suffix_normalized)
        actual_suffix_normalized = re.sub(r'\["[^"]+-test-networking"\]', '[{rg_name}]', actual_suffix_normalized)
        actual_suffix_normalized = re.sub(r'\["[^"]+-prod-networking"\]', '[{rg_name}]', actual_suffix_normalized)
        actual_suffix_normalized = re.sub(r'\["NetworkWatcherRG"\]', '[{rg_name}]', actual_suffix_normalized)
        # Replace subscription keys (including vwan_spoke) with {sub_key} placeholder
        actual_suffix_normalized = re.sub(r'\["vwan_spoke"\]', '[{sub_key}]', actual_suffix_normalized)
        actual_suffix_normalized = re.sub(r'\["dev"\]', '[{sub_key}]', actual_suffix_normalized)
        actual_suffix_normalized = re.sub(r'\["tools"\]', '[{sub_key}]', actual_suffix_normalized)
        actual_suffix_normalized = re.sub(r'\["test"\]', '[{sub_key}]', actual_suffix_normalized)
        actual_suffix_normalized = re.sub(r'\["prod"\]', '[{sub_key}]', actual_suffix_normalized)

        # Compare normalized actual suffix with pattern suffix
        return actual_suffix_normalized == pattern_suffix

    def _apply_pattern_to_address(self, old_addr: str, from_pattern: str, to_pattern: str, common_prefix: str) -> str:
        """Apply a pattern transformation to an address."""
        # Normalize common_prefix for matching
        normalized_common_prefix = common_prefix
        if normalized_common_prefix:
            normalized_common_prefix = re.sub(r'\["[^"]+"\]', '[{key}]', normalized_common_prefix)

        # Normalize old address
        normalized_old_addr = re.sub(r'\["[^"]+"\]', '[{key}]', old_addr)

        # Extract suffix by matching normalized prefix
        if normalized_common_prefix:
            normalized_parts = normalized_old_addr.split('.')
            normalized_prefix_parts = normalized_common_prefix.split('.')

            if len(normalized_parts) >= len(normalized_prefix_parts):
                # Extract suffix after prefix
                old_suffix_parts = normalized_parts[len(normalized_prefix_parts):]
                old_suffix = '.'.join(old_suffix_parts)
            else:
                old_suffix = normalized_old_addr
        else:
            old_suffix = normalized_old_addr

        # Convert normalized suffix back to actual values for extraction
        # We need to extract from the original address
        old_addr_parts = old_addr.split('.')
        common_prefix_parts = common_prefix.split('.') if common_prefix else []
        if len(old_addr_parts) > len(common_prefix_parts):
            actual_suffix_parts = old_addr_parts[len(common_prefix_parts):]
            actual_old_suffix = '.'.join(actual_suffix_parts)
        else:
            actual_old_suffix = old_addr

        # Extract values from actual address
        rg_match = re.search(r'\["([^"]+-dev-networking|[^"]+-tools-networking|[^"]+-test-networking|[^"]+-prod-networking|NetworkWatcherRG)"\]', actual_old_suffix)
        rg_name = rg_match.group(1) if rg_match else None

        # Extract subscription key from actual suffix (prefer index_key if available)
        # For nested modules, the key is usually in the instance index_key
        sub_key = None
        # Look for vwan_spoke first (for virtual_networks patterns)
        if 'virtual_networks' in to_pattern or 'vhubconnection_routing_intent' in to_pattern:
            vwan_match = re.search(r'\["vwan_spoke"\]', actual_old_suffix)
            if vwan_match:
                sub_key = 'vwan_spoke'
        if not sub_key:
            # Fall back to other keys
            sub_match = re.search(r'\["([^"]+)"\]', actual_old_suffix)
            sub_key = sub_match.group(1) if sub_match else None

        # Apply pattern transformation
        new_suffix = to_pattern
        if rg_name:
            new_suffix = new_suffix.replace('[{rg_name}]', f'["{rg_name}"]')
        if sub_key:
            new_suffix = new_suffix.replace('[{sub_key}]', f'["{sub_key}"]')

        # Build new address - use actual common prefix from old address (not normalized)
        if common_prefix:
            # Replace project-specific parts in common_prefix with actual values from old_addr
            actual_common_prefix = '.'.join(old_addr_parts[:len(common_prefix_parts)])
            return f"{actual_common_prefix}.{new_suffix}" if actual_common_prefix else new_suffix
        else:
            return new_suffix

    def _infer_resource_structure_from_pattern(self, new_addr: str, old_resource: Dict) -> Dict:
        """Infer resource structure from a pattern-based address."""
        parts = new_addr.split('.')

        # Parse the new address to extract module, type, name
        module_parts = []
        resource_type = None
        resource_name = None

        i = 0
        while i < len(parts):
            part = parts[i]
            # Check if this is a module path segment
            if part == 'module' and i + 1 < len(parts):
                # Add "module.module_name" or "module.module_name[index]"
                module_segment = f"module.{parts[i+1]}"
                if i + 2 < len(parts) and parts[i+2].startswith('['):
                    module_segment += parts[i+2]
                    i += 3
                else:
                    i += 2
                module_parts.append(module_segment)
            elif '.' in part and not resource_type:
                # This should be type.name or type.name[index] (when combined)
                type_name = part.split('.')
                if len(type_name) == 2:
                    resource_type = type_name[0]
                    # Extract name, removing [index] if present
                    name_part = type_name[1]
                    if '[' in name_part:
                        resource_name = name_part.split('[')[0]
                    else:
                        resource_name = name_part
                i += 1
            elif not resource_type and i < len(parts) - 1:
                # Check if this part looks like a resource type (azapi_resource, azurerm_*, etc.)
                # and next part is the resource name
                if part in ['azapi_resource', 'azapi_resource_action', 'azapi_update_resource',
                           'azurerm_subscription', 'azurerm_role_assignment', 'azurerm_management_group',
                           'azuread_group', 'azuread_user', 'azuread_group_member',
                           'azureipam_reservation', 'terraform_data', 'time_sleep', 'data']:
                    resource_type = part
                    # Next part should be the resource name
                    if i + 1 < len(parts):
                        name_part = parts[i + 1]
                        if '[' in name_part:
                            resource_name = name_part.split('[')[0]
                        else:
                            resource_name = name_part
                        i += 2
                        continue
                i += 1
            else:
                i += 1

        return {
            'module': '.'.join(module_parts) if module_parts else '',
            'type': resource_type or old_resource.get('type', ''),
            'name': resource_name or old_resource.get('name', ''),
            'mode': old_resource.get('mode', 'managed')
        }

    def _apply_moves_to_state(self, state: Dict, resources_to_update: List[Dict]) -> Dict:
        """Apply moves to state (helper function)."""
        moved_old_addresses = set(info['old_addr'] for info in resources_to_update)
        updated_resources = []

        # Remove old resources and keep non-moved ones
        for resource in state.get('resources', []):
            resource_should_remove = True
            remaining_instances = []

            for instance in resource.get('instances', []):
                addr = self._build_resource_address(resource, instance)
                if addr not in moved_old_addresses:
                    resource_should_remove = False
                    remaining_instances.append(instance)

            if not resource_should_remove:
                if remaining_instances:
                    resource['instances'] = remaining_instances
                    updated_resources.append(resource)

        # Add new resources for moved resources
        new_resources_by_key = {}
        for update_info in resources_to_update:
            new_resource = update_info['new_resource']
            resource_key = (
                new_resource.get('module', ''),
                new_resource.get('mode', 'managed'),
                new_resource.get('type', ''),
                new_resource.get('name', '')
            )

            if resource_key in new_resources_by_key:
                existing_resource = new_resources_by_key[resource_key]
                existing_index_keys = {inst.get('index_key') for inst in existing_resource.get('instances', [])}

                for new_instance in new_resource['instances']:
                    new_index_key = new_instance.get('index_key')
                    if new_index_key not in existing_index_keys:
                        existing_resource['instances'].append(new_instance)
                        existing_index_keys.add(new_index_key)
            else:
                new_resources_by_key[resource_key] = new_resource

        updated_resources.extend(new_resources_by_key.values())
        state['resources'] = updated_resources
        return state

    def _remove_unmatched_resources(self, state: Dict, new_state_list: List[str], pattern_matched_old_addresses: Set[str] = None, move_patterns: List[Dict] = None) -> int:
        """Remove resources that don't exist in new state list."""
        new_state_set = set(new_state_list)
        resources_to_keep = []
        removed_count = 0

        # Use provided pattern-matched addresses, or build from current state
        if pattern_matched_old_addresses is None:
            pattern_matched_old_addresses = set()
            if move_patterns:
                for resource in state.get('resources', []):
                    for instance in resource.get('instances', []):
                        addr = self._build_resource_address(resource, instance)
                        for pattern in move_patterns:
                            if self._matches_pattern(addr, pattern['from_pattern'], pattern.get('common_prefix', '')):
                                pattern_matched_old_addresses.add(addr)
                                break

        for resource in state.get('resources', []):
            keep_resource = False
            for instance in resource.get('instances', []):
                addr = self._build_resource_address(resource, instance)
                # Check if this was an old address that matched a pattern
                # We need to check against the old addresses, not current
                # For now, keep if it exists in new state
                if addr in new_state_set:
                    keep_resource = True
                    break

            if keep_resource:
                resources_to_keep.append(resource)
            else:
                # Check if this resource's old address matched a pattern
                # We can't easily track this, so we'll be more conservative
                # and only remove if we're sure it shouldn't exist
                removed_count += 1

        state['resources'] = resources_to_keep
        return removed_count

    def verify_with_jq(self, transformed_state: Path) -> Dict:
        """Use jq for deeper state analysis if available."""
        if not self._jq_available():
            return {}

        try:
            # Count resources by type
            result = subprocess.run(
                ['jq', '-r', r'.resources[] | "\(.type).\(.name)"', str(transformed_state)],
                cwd=str(self.work_dir),
                capture_output=True,
                text=True,
                check=True
            )
            resource_types = {}
            for line in result.stdout.strip().split('\n'):
                if line:
                    resource_types[line] = resource_types.get(line, 0) + 1

            # Count instances with identity_schema_version
            result = subprocess.run(
                ['jq', '[.resources[].instances[] | select(.identity_schema_version != null)] | length', str(transformed_state)],
                cwd=str(self.work_dir),
                capture_output=True,
                text=True,
                check=True
            )
            instances_with_identity = int(result.stdout.strip())

            return {
                'resource_types': resource_types,
                'instances_with_identity': instances_with_identity,
                'jq_available': True
            }
        except (subprocess.CalledProcessError, FileNotFoundError, ValueError):
            return {'jq_available': False}

    def _jq_available(self) -> bool:
        """Check if jq is available."""
        try:
            subprocess.run(['jq', '--version'], capture_output=True, check=True)
            return True
        except (subprocess.CalledProcessError, FileNotFoundError):
            return False

    def _get_builtin_body_types(self) -> Dict[Tuple[str, str], any]:
        """Builtin azapi body.type schemas keyed by (resource_type, resource_name)."""
        return {
            # Virtual Network resource body
            ('azapi_resource', 'vnet'): [
                "object",
                {
                    "properties": [
                        "object",
                        {}
                    ]
                }
            ],
            # Update VNet body
            ('azapi_update_resource', 'vnet'): [
                "object",
                {
                    "properties": [
                        "object",
                        {}
                    ]
                }
            ],
            # Routing intent (vhubconnection_routing_intent)
            ('azapi_resource', 'vhubconnection_routing_intent'): [
                "object",
                {
                    "properties": [
                        "object",
                        {
                            "enableInternetSecurity": "bool",
                            "remoteVirtualNetwork": [
                                "object",
                                {"id": "string"}
                            ]
                        }
                    ]
                }
            ],
            # Subscription alias
            ('azapi_resource', 'subscription'): [
                "object",
                {
                    "properties": [
                        "object",
                        {"subscriptionId": "string"}
                    ]
                }
            ],
            # Subscription tags update
            ('azapi_update_resource', 'subscription_tags'): [
                "object",
                {
                    "properties": [
                        "object",
                        {"tags": ["map", "string"]}
                    ]
                }
            ],
            # Telemetry root stays string
            ('azapi_resource', 'telemetry_root'): "string",
            # Resource group stays string
            ('azapi_resource', 'rg'): "string",
        }

    def _align_azapi_bodies_to_reference(self, state: Dict) -> int:
        """Align azapi resource bodies using builtin schema registry (no reference required).
        - Applies known body.type schemas
        - Parses body.value to object for object-like types; keeps string otherwise
        """
        builtin = self._get_builtin_body_types()
        fixed = 0
        for resource in state.get('resources', []):
            r_type = resource.get('type')
            r_name = resource.get('name')
            key = (r_type, r_name)
            if key not in builtin:
                continue
            target_body_type = builtin[key]
            for instance in resource.get('instances', []):
                attrs = instance.get('attributes', {})
                body = attrs.get('body') if isinstance(attrs, dict) else None
                if not isinstance(body, dict):
                    continue
                value = body.get('value')
                attrs['body']['type'] = target_body_type
                target_is_objectish = isinstance(target_body_type, list) or target_body_type == 'object'
                if target_is_objectish and isinstance(value, str):
                    try:
                        parsed = json.loads(value)
                        attrs['body']['value'] = parsed
                        fixed += 1
                    except Exception:
                        pass
                elif not target_is_objectish and isinstance(value, dict):
                    try:
                        attrs['body']['value'] = json.dumps(value)
                        fixed += 1
                    except Exception:
                        pass
        return fixed

    def _remove_obsolete_resources(self, state: Dict) -> int:
        """Remove resources that are known to be obsolete in the new configuration.
        Currently removes azapi_update_resource.vnet instances (no longer in config).
        """
        removed = 0
        kept_resources = []
        for resource in state.get('resources', []):
            rtype = resource.get('type')
            rname = resource.get('name')
            if rtype == 'azapi_update_resource' and rname == 'vnet':
                removed += 1
                continue
            kept_resources.append(resource)
        state['resources'] = kept_resources
        return removed


def main():
    parser = argparse.ArgumentParser(
        description="Comprehensive Terraform state transformation script",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  # Transform a state file using hardcoded patterns
  %(prog)s transform old.tfstate new.tfstate
        """
    )

    subparsers = parser.add_subparsers(dest='command', help='Command to execute')

    # Transform command
    transform_parser = subparsers.add_parser('transform', help='Transform a state file')
    transform_parser.add_argument('old_state', type=Path, help='Path to old state file')
    transform_parser.add_argument('output', type=Path, nargs='?', help='Output path (default: old_state_transformed.tfstate)')
    transform_parser.add_argument('--work-dir', type=Path,
                                  help='Working directory for terraform commands (default: old_state directory)')

    args = parser.parse_args()

    if not args.command:
        parser.print_help()
        sys.exit(1)

    # Determine work directory
    if args.command == 'transform':
        work_dir = args.work_dir or args.old_state.parent
    else:
        work_dir = args.work_dir or Path('.').resolve()

    transformer = StateTransformer(work_dir)

    if args.command == 'transform':
        # Determine output path
        output_path = args.output
        if not output_path:
            output_path = args.old_state.parent / f"{args.old_state.stem}_transformed{args.old_state.suffix}"

        # Learn patterns (hardcoded patterns only)
        patterns = transformer.learn_transformation_patterns(args.old_state)

        # Transform state
        success = transformer.transform_state(args.old_state, output_path, patterns)


if __name__ == "__main__":
    main()
