locals {
  subnets = {
    for subnet in var.virtual_network_object.subnet : subnet.name => merge(
      subnet, {
        first_available_ip = cidrhost(element(subnet.address_prefixes, 0), 4)
        # This extracts the fourth IP address from the subnet address prefix, which is the first available IP address in the subnet (as Azure reserves the first three IP addresses in each subnet)
      }
    )
  }

  additional_forwarding_rules = {
    for item in flatten([
      for ruleset_key, ruleset in var.additional_forwarding_rulesets : [
        for rule in ruleset.rules : {
          key         = "${ruleset_key}/${rule.name}"
          ruleset_key = ruleset_key
          rule        = rule
        }
      ]
    ]) : item.key => item
  }
}
