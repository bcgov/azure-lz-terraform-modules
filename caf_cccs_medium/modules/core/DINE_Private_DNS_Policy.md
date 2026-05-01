# Adding a Private DNS DINE Policy to the CAF

This document explains how to create and deploy a new **DeployIfNotExists (DINE)** Azure Policy for private DNS zone integration when a new Azure service needs private endpoint support. The Azure Managed Redis service is used as the running example throughout.

## Background

The Cloud Adoption Framework (CAF) Terraform module (`Azure/caf-enterprise-scale/azurerm`) reads JSON files from a `lib/` directory to configure Azure Policy definitions, assignments, policy set definitions (initiatives), and archetype extensions. The upstream CAF module used to ship built-in DINE policies for most Azure services, but updates have slowed. When a new Azure service appears (or an existing service changes in a way that requires a new private DNS zone), we now have to add custom policies ourselves.

A DINE policy for private DNS does the following: when someone creates a private endpoint for a given Azure service, the policy automatically creates a private DNS zone group on that endpoint and links it to the correct `privatelink.*` DNS zone. This ensures private endpoint DNS resolution works without manual intervention.

## Prerequisites

Before writing any policy JSON, **provision an instance of the target service** in a test/sandbox account (e.g. one of the Public Cloud team's testing subscriptions in Forge). Creating a real instance lets you:

- Discover the correct **resource provider type** (e.g. `Microsoft.Cache/RedisEnterprise`)
- Discover the correct **private link group ID** (e.g. `redisEnterprise`)
- Identify the required **privatelink DNS zone name** (e.g. `privatelink.redis.azure.net`)
- Check whether the service has multiple variants/kinds that require different DNS zones

This research step saves significant trial-and-error time.

## Architecture Overview

There are **five files** (across four directories) that must be touched when adding a new private DNS DINE policy:

```
modules/core/lib/
├── policy_definitions/
│   └── policy_definition_deploy_private_dns_<service>.json    ← 1. Define the policy
├── policy_assignments/
│   └── policy_assignment_deploy_private_dns_<service>.json    ← 2. Assign the policy
├── archetype_extensions/
│   └── archetype_extension_es_root.tmpl.json                  ← 3. Register definition + assignment
└── (settings.core.tf in parent directory)                     ← 4. Provide parameter values
```

Optionally, the policy set definition (initiative) in `policy_set_definitions/` may also need updating if the new service should be part of the bundled `Deploy-Private-DNS-Zones-Custom` initiative rather than a standalone assignment.

## Step-by-Step Guide

### Step 1: Create the Policy Definition

Create a new JSON file in `modules/core/lib/policy_definitions/`.

**Naming convention:** `policy_definition_deploy_private_dns_<service>.json`

The JSON `name` field has a **24-character limit** for policy definition names. Use a short, recognizable abbreviation (e.g. `Deploy-Private-DNS-Redis`, `Deploy-Private-DNS-CgSrv`).

Here is the annotated structure using Azure Managed Redis as an example:

```json
{
  "name": "Deploy-Private-DNS-Redis",
  "type": "Microsoft.Authorization/policyDefinitions",
  "apiVersion": "2024-05-01",
  "properties": {
    "displayName": "Deploy-Private-DNS-Redis",
    "policyType": "Custom",
    "mode": "Indexed",
    "description": "Use private DNS zones to override the DNS resolution for Azure Managed Redis private endpoint.",
    "metadata": {
      "version": "1.0.0",
      "category": "Cache (Azure Managed Redis)"
    },
    "parameters": {
      "effect": {
        "type": "String",
        "metadata": {
          "displayName": "Effect",
          "description": "The effect of the policy.",
          "strongType": "Effect",
          "defaultValue": "DeployIfNotExists"
        }
      },
      "managedRedisPrivateDnsZoneId": {
        "type": "String",
        "metadata": {
          "displayName": "Azure Managed Redis Private DNS Zone ID",
          "description": "The Private DNS Zone ID for Azure Managed Redis (privatelink.redis.azure.net).",
          "strongType": "Microsoft.Network/privateDnsZones"
        }
      }
    },
    "policyRule": { ... }
  }
}
```

#### Key sections of the policy rule

**The `if` block** — determines which resources trigger the policy. For private DNS DINE policies, this always matches `Microsoft.Network/privateEndpoints` where the private link service connection targets the specific resource provider and group ID:

```json
"if": {
  "allOf": [
    {
      "equals": "Microsoft.Network/privateEndpoints",
      "field": "type"
    },
    {
      "count": {
        "field": "Microsoft.Network/privateEndpoints/privateLinkServiceConnections[*]",
        "where": {
          "allOf": [
            {
              "field": "Microsoft.Network/privateEndpoints/privateLinkServiceConnections[*].privateLinkServiceId",
              "contains": "Microsoft.Cache/RedisEnterprise"
            },
            {
              "field": "Microsoft.Network/privateEndpoints/privateLinkServiceConnections[*].groupIds[*]",
              "equals": "redisEnterprise"
            }
          ]
        }
      },
      "greaterOrEquals": 1
    }
  ]
}
```

Things to change for your service:
- `contains`: the ARM resource provider path (e.g. `Microsoft.Cache/RedisEnterprise`, `Microsoft.App/managedEnvironments`, `Microsoft.CognitiveServices/accounts`)
- `equals` (groupIds): the private link sub-resource group ID (e.g. `redisEnterprise`, `managedEnvironments`, `account`)

You can find these values by creating the service with a private endpoint in the Azure Portal and inspecting the private endpoint resource, or from the [Azure Private Link documentation](https://learn.microsoft.com/en-us/azure/private-link/private-endpoint-dns).

**The `then` block** — the DINE deployment. It creates a `privateDnsZoneGroups` child resource on the private endpoint via an ARM template deployment:

```json
"then": {
  "effect": "[parameters('effect')]",
  "details": {
    "type": "Microsoft.Network/privateEndpoints/privateDnsZoneGroups",
    "roleDefinitionIds": [
      "/providers/Microsoft.Authorization/roleDefinitions/4d97b98b-1d4f-4787-a291-c67834d212e7",
      "/providers/Microsoft.Authorization/roleDefinitions/acdd72a7-3385-48ef-bd42-f606fba81ae7"
    ],
    "deployment": {
      "properties": {
        "mode": "incremental",
        "template": {
          "resources": [
            {
              "type": "Microsoft.Network/privateEndpoints/privateDnsZoneGroups",
              "name": "[concat(parameters('privateEndpointName'), '/deployedByPolicy')]",
              "properties": {
                "privateDnsZoneConfigs": [
                  {
                    "name": "<service>-private-dns-zone",
                    "properties": {
                      "privateDnsZoneId": "[parameters('yourPrivateDnsZoneId')]"
                    }
                  }
                ]
              }
            }
          ]
        }
      }
    }
  }
}
```

The two `roleDefinitionIds` are standard and should be kept as-is:
- `4d97b98b-...` = Network Contributor
- `acdd72a7-...` = Reader

If a service has multiple variants that need different DNS zones (e.g. Azure Managed Redis v2 vs Redis Enterprise), use conditional logic in the ARM template with `reference()` calls to inspect the linked resource's `kind` or other properties. See the Managed Redis and Cognitive Services definitions for examples of this pattern.

### Step 2: Create the Policy Assignment

Create a new JSON file in `modules/core/lib/policy_assignments/`.

**Naming convention:** `policy_assignment_deploy_private_dns_<service>.json`

The assignment `name` also has a **24-character limit**. It should match the policy definition `name` for clarity.

```json
{
  "name": "Deploy-Private-DNS-Redis",
  "type": "Microsoft.Authorization/policyAssignments",
  "apiVersion": "2022-06-01",
  "properties": {
    "displayName": "Deploy Private DNS Zone for Azure Managed Redis Private Endpoints",
    "description": "This policy automatically creates and links private DNS zones for Azure Managed Redis private endpoints.",
    "metadata": {
      "version": "1.0.0",
      "category": "Cache (Azure Managed Redis)"
    },
    "policyDefinitionId": "${root_scope_resource_id}/providers/Microsoft.Authorization/policyDefinitions/Deploy-Private-DNS-Redis",
    "parameters": {
      "managedRedisPrivateDnsZoneId": {
        "value": "/subscriptions/[[subscriptionId]]/resourceGroups/[[resourceGroupName]]/providers/Microsoft.Network/privateDnsZones/privatelink.redis.azure.net"
      },
      "effect": {
        "value": "DeployIfNotExists"
      }
    }
  },
  "location": "${default_location}",
  "identity": {
    "type": "SystemAssigned"
  }
}
```

Key points:

- **`policyDefinitionId`**: uses the `${root_scope_resource_id}` template variable followed by the path to your custom policy definition. The name after `policyDefinitions/` must exactly match the `name` field in your policy definition JSON.
- **`identity`**: must be `SystemAssigned`. DINE policies need a managed identity to perform deployments.
- **`parameters`**: placeholder values here (e.g. `[[subscriptionId]]`); the real values come from `settings.core.tf` via `archetype_config_overrides`.

### Step 3: Register in the Archetype Extension

Edit `modules/core/lib/archetype_extensions/archetype_extension_es_root.tmpl.json` to register both the definition and the assignment.

Add **three** entries:

**a) Add the policy definition name to the `policy_definitions` array:**

```json
"policy_definitions": [
  "Inherit-Account-Code-Tag",
  ...
  "Deploy-Private-DNS-Redis"    ← add this
]
```

**b) Add the policy assignment name to the `policy_assignments` array:**

```json
"policy_assignments": [
  "CanadaFederalPBMM",
  ...
  "Deploy-Private-DNS-Redis"    ← add this
]
```

**c) Add default parameter values in `archetype_config.parameters`:**

```json
"archetype_config": {
  "parameters": {
    ...
    "Deploy-Private-DNS-Redis": {
      "managedRedisPrivateDnsZoneId": "SET using local.archetype_config_overrides",
      "redisEnterprisePrivateDnsZoneId": "SET using local.archetype_config_overrides"
    }
  }
}
```

The placeholder text `"SET using local.archetype_config_overrides"` is a convention to indicate the real values come from Terraform.

### Step 4: Add Parameter Overrides in `settings.core.tf`

Edit `modules/core/settings.core.tf` and add parameter values under the `root` archetype config overrides:

```hcl
Deploy-Private-DNS-Redis = {
  managedRedisPrivateDnsZoneId : "/subscriptions/${var.subscription_id_connectivity}/resourceGroups/${var.root_id}-dns/providers/Microsoft.Network/privateDnsZones/privatelink.redis.azure.net",
  redisEnterprisePrivateDnsZoneId : "/subscriptions/${var.subscription_id_connectivity}/resourceGroups/${var.root_id}-dns/providers/Microsoft.Network/privateDnsZones/privatelink.redisenterprise.cache.azure.net",
}
```

This provides the actual private DNS zone resource IDs using Terraform variables so they resolve correctly per environment.

### Step 5: Deploy (Two-Stage Process)

> **Important gotcha:** Custom policy definitions must exist in Azure before they can be assigned. The CAF module processes definitions and assignments as a flat list of JSON files — it cannot infer dependency ordering between them. This means you likely need **two separate deployments** (i.e., two pull requests).

**PR 1 — Deploy the definition:**
1. Add the policy definition JSON file (Step 1)
2. Add the definition name to the archetype extension `policy_definitions` array (Step 3a)
3. Merge and deploy via your pipeline

**PR 2 — Deploy the assignment:**
1. Add the policy assignment JSON file (Step 2)
2. Add the assignment name to the archetype extension `policy_assignments` array (Step 3b)
3. Add the parameter defaults in the archetype extension (Step 3c)
4. Add the parameter overrides in `settings.core.tf` (Step 4)
5. Merge and deploy via your pipeline

If you try to do it all in one PR, Terraform will attempt to create the assignment referencing a definition that doesn't exist yet, which will fail.

> **Note:** This two-stage deployment is only required for **custom** policy definitions. Built-in Azure policies (those with a `policyDefinitionId` starting with `/providers/Microsoft.Authorization/policyDefinitions/`) already exist in Azure and can be assigned immediately.

## Policy Set Definitions (Initiatives)

The file `policy_set_definition_es_deploy_private_dns_zones_custom.json` defines the `Deploy-Private-DNS-Zones-Custom` initiative. This is a collection of **built-in** Azure DINE policies for private DNS, all bundled together into a single assignable unit. Its corresponding assignment is `policy_assignment_es_deploy_private_dns_zones_custom.json` (named `DINE-Private-DNS-Zones`).

### When to use the initiative vs. a standalone assignment

- **Use the initiative** when a built-in Azure policy already exists for the service. Add a reference to the built-in policy's `policyDefinitionId` (a GUID like `/providers/Microsoft.Authorization/policyDefinitions/abcdef12-...`) inside the initiative's `policyDefinitions` array. No custom policy definition is needed.
- **Use a standalone custom definition + assignment** when no built-in policy exists and you need to write one from scratch. This is the process described in Steps 1-5 above.

A policy set definition does **not** deploy individual policy definitions — it only **references** definitions that already exist in Azure (either built-in or previously deployed custom ones).

## Quick Reference: Files to Touch

| Step | File | What to do |
|------|------|------------|
| 1 | `lib/policy_definitions/policy_definition_deploy_private_dns_<service>.json` | Create the DINE policy definition |
| 2 | `lib/policy_assignments/policy_assignment_deploy_private_dns_<service>.json` | Create the policy assignment |
| 3 | `lib/archetype_extensions/archetype_extension_es_root.tmpl.json` | Register definition + assignment + default params |
| 4 | `modules/core/settings.core.tf` | Add real parameter values (DNS zone resource IDs) |

## Template Variables Available in JSON

The CAF module provides these template variables for use in JSON files:

| Variable | Description |
|----------|-------------|
| `${root_scope_resource_id}` | The resource ID of the root management group |
| `${current_scope_resource_id}` | The resource ID of the management group where the policy is assigned |
| `${default_location}` | The default Azure region (set via `default_location` in `main.tf`) |
| `${private_dns_zone_prefix}` | Prefix path for private DNS zones in the connectivity subscription |
| `${connectivity_location_short}` | Short code for the connectivity subscription's location |

## Naming Constraints

- Policy definition `name`: **24 characters max** (the `name` field in JSON, not `displayName`)
- Policy assignment `name`: **24 characters max**
- The `displayName` field has no practical limit and can be descriptive
- The definition `name` does not have to match the assignment `name`, but keeping them the same (or similar) makes the relationship obvious

## Common Gotchas

1. **Race condition on first deploy**: Custom definitions must be deployed before their assignments. Requires two PRs. See Step 5.
2. **JSON files cannot have comments**: Unlike Terraform (HCL), JSON does not support comments. You cannot comment out sections for testing — you must remove and re-add them.
3. **Name length limits**: Both policy definitions and assignments have a 24-character limit on the `name` field. This forces abbreviated names.
4. **Role definition IDs**: DINE policies need `roleDefinitionIds` in the `details` block so the managed identity has permissions to create DNS zone groups. The standard pair (Network Contributor + Reader) covers most cases.
5. **Managed identity**: The assignment must have `"identity": { "type": "SystemAssigned" }`. Without this, the DINE policy has no permissions to remediate.
6. **Parameter flow**: Parameters flow through three layers: policy definition declares them → assignment provides placeholder values → `archetype_config_overrides` in `settings.core.tf` supplies the real Terraform-interpolated values.

## Existing Private DNS DINE Policies (for Reference)

| Service | Definition Name | Definition File |
|---------|----------------|-----------------|
| SQL Server | `Deploy-Private-DNS-Generic` (built-in) | _(uses built-in; assignment only)_ |
| API Management | `Deploy-Private-DNS-Generic` (built-in) | _(uses built-in; assignment only)_ |
| PostgreSQL Server | `Deploy-Private-DNS-Generic` (built-in) | _(uses built-in; assignment only)_ |
| Cognitive Services / AI | `Deploy-Private-DNS-CgSrv` | `policy_definition_deploy_private_dns_cognitive_services.json` |
| OpenAI | `Deploy-Private-DNS-OpenAI` | `policy_definition_deploy_private_dns_openai.json` |
| Container Apps | `Deploy-Private-DNS-ACA` | `policy_definition_deploy_private_dns_containerapps.json` |
| Azure Managed Redis | `Deploy-Private-DNS-Redis` | `policy_definition_deploy_private_dns_managed_redis.json` |
| Microsoft Fabric | `Deploy-Private-DNS-Fbrc` | `policy_definition_deploy_private_dns_fabric.json` |
| Many built-in services | _(bundled in initiative)_ | `policy_set_definition_es_deploy_private_dns_zones_custom.json` |
