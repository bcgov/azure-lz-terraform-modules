locals {
  subscription_exemptions = {
    for k, v in var.exemptions : k => v if v.scope_type == "subscription"
  }
  resource_group_exemptions = {
    for k, v in var.exemptions : k => v if v.scope_type == "resource_group"
  }
  resource_exemptions = {
    for k, v in var.exemptions : k => v if v.scope_type == "resource"
  }

  metadata = {
    for k, v in var.exemptions : k => jsonencode(merge(
      {
        for key, value in {
          managedBy      = var.managed_by
          reviewBy       = v.expires_on == null ? var.review_by : null
          lastReviewedOn = v.last_reviewed_on
          reason         = v.reason
          ticket         = v.ticket
        } : key => value if value != null
      },
      { reviewers = coalesce(v.reviewers, []) },
      coalesce(v.extra, {}),
    ))
  }
}

resource "azurerm_subscription_policy_exemption" "this" {
  for_each = local.subscription_exemptions

  name                            = each.value.name
  subscription_id                 = each.value.scope_id
  policy_assignment_id            = each.value.policy_assignment_id
  exemption_category              = each.value.exemption_category
  expires_on                      = each.value.expires_on
  display_name                    = each.value.display_name
  description                     = each.value.description
  policy_definition_reference_ids = each.value.policy_definition_reference_ids
  metadata                        = local.metadata[each.key]
}

resource "azurerm_resource_group_policy_exemption" "this" {
  for_each = local.resource_group_exemptions

  name                            = each.value.name
  resource_group_id               = each.value.scope_id
  policy_assignment_id            = each.value.policy_assignment_id
  exemption_category              = each.value.exemption_category
  expires_on                      = each.value.expires_on
  display_name                    = each.value.display_name
  description                     = each.value.description
  policy_definition_reference_ids = each.value.policy_definition_reference_ids
  metadata                        = local.metadata[each.key]
}

resource "azurerm_resource_policy_exemption" "this" {
  for_each = local.resource_exemptions

  name                            = each.value.name
  resource_id                     = each.value.scope_id
  policy_assignment_id            = each.value.policy_assignment_id
  exemption_category              = each.value.exemption_category
  expires_on                      = each.value.expires_on
  display_name                    = each.value.display_name
  description                     = each.value.description
  policy_definition_reference_ids = each.value.policy_definition_reference_ids
  metadata                        = local.metadata[each.key]
}

import {
  for_each = local.subscription_exemptions
  to       = azurerm_subscription_policy_exemption.this[each.key]
  id       = "${each.value.scope_id}/providers/Microsoft.Authorization/policyExemptions/${each.value.name}"
}

import {
  for_each = local.resource_group_exemptions
  to       = azurerm_resource_group_policy_exemption.this[each.key]
  id       = "${each.value.scope_id}/providers/Microsoft.Authorization/policyExemptions/${each.value.name}"
}

import {
  for_each = local.resource_exemptions
  to       = azurerm_resource_policy_exemption.this[each.key]
  id       = "${each.value.scope_id}/providers/Microsoft.Authorization/policyExemptions/${each.value.name}"
}
