resource "azurerm_route_map" "this" {
  for_each = var.route_maps

  name           = each.value.name
  virtual_hub_id = var.virtual_hub_id

  dynamic "rule" {
    for_each = each.value.rules

    content {
      name                 = rule.value.name
      next_step_if_matched = rule.value.next_step_if_matched

      dynamic "match_criterion" {
        for_each = rule.value.match_criteria

        content {
          match_condition = match_criterion.value.match_condition
          as_path         = length(match_criterion.value.as_path) > 0 ? match_criterion.value.as_path : null
          community       = length(match_criterion.value.community) > 0 ? match_criterion.value.community : null
          route_prefix    = length(match_criterion.value.route_prefix) > 0 ? match_criterion.value.route_prefix : null
        }
      }

      dynamic "action" {
        for_each = rule.value.actions

        content {
          type = action.value.type

          dynamic "parameter" {
            for_each = action.value.type == "Drop" ? [] : [action.value]

            content {
              as_path      = length(parameter.value.as_path) > 0 ? parameter.value.as_path : null
              community    = length(parameter.value.community) > 0 ? parameter.value.community : null
              route_prefix = length(parameter.value.route_prefix) > 0 ? parameter.value.route_prefix : null
            }
          }
        }
      }
    }
  }
}
