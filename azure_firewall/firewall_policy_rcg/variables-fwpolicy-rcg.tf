# Firewall Policy Rule Collection Group
variable "firewall_policy_rule_collection_group" {
  description = "The Azure Firewall Policy Rule Collection Group."
  type = list(object({
    name     = string
    priority = number

    application_rule_collection = optional(list(object({
      name     = string
      action   = string
      priority = number
      rule = list(object({
        name        = string
        description = optional(string)
        protocols = optional(list(object({
          type = string
          port = number
        })))
        http_headers = optional(list(object({
          name  = string
          value = string
        })))
        source_addresses      = optional(list(string))
        source_ip_groups      = optional(list(string))
        destination_addresses = optional(list(string))
        destination_urls      = optional(list(string))
        destination_fqdns     = optional(list(string))
        destination_fqdn_tags = optional(list(string))
        terminate_tls         = optional(bool)
        web_categories        = optional(list(string))
      }))
    })))

    network_rule_collection = optional(list(object({
      name     = string
      action   = string
      priority = number

      rule = list(object({
        name                  = string
        description           = optional(string)
        protocols             = optional(list(string))
        destination_ports     = list(string)
        source_addresses      = optional(list(string))
        source_ip_groups      = optional(list(string))
        destination_addresses = optional(list(string))
        destination_ip_groups = optional(list(string))
        destination_fqdns     = optional(list(string))
      }))
    })))

    nat_rule_collection = optional(list(object({
      name     = string
      action   = string
      priority = number

      rule = object({
        name                = string
        description         = optional(string)
        protocols           = list(string)
        source_addresses    = optional(list(string))
        source_ip_groups    = optional(list(string))
        destination_address = optional(string)
        destination_ports   = optional(list(string))
        translated_address  = optional(string)
        translated_fqdn     = optional(string)
        translated_port     = string
      })
    })))
  }))
  default = []
}
