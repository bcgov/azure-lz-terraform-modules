variable "virtual_hub_id" {
  description = "Resource ID of the Virtual Hub that owns the route maps."
  type        = string
}

variable "route_maps" {
  description = <<-EOT
    Map of Virtual Hub route maps to manage.
    Key is a stable Terraform identifier; each value.name is the Azure route map name.
    Rules are applied in list order.
  EOT
  type = map(object({
    name = string
    rules = list(object({
      name                 = string
      next_step_if_matched = optional(string, "Terminate")
      match_criteria = optional(list(object({
        match_condition = string
        as_path         = optional(list(string), [])
        community       = optional(list(string), [])
        route_prefix    = optional(list(string), [])
      })), [])
      actions = optional(list(object({
        type         = string
        as_path      = optional(list(string), [])
        community    = optional(list(string), [])
        route_prefix = optional(list(string), [])
      })), [])
    }))
  }))
}
