variable "ip_group" {
  description = "Configuration for creating IP Groups"
  type = list(object({
    name         = string
    ip_addresses = set(string)
    tags         = optional(map(string), {})
  }))
  default = []

  validation {
    condition = alltrue([
      for obj in var.ip_group : can(regex("^[a-zA-Z0-9][a-zA-Z0-9._-]*[a-zA-Z0-9_]$", obj.name))
    ])
    error_message = "Each IP Group's name must begin with a letter or number, end with a letter, number or underscore, and may contain only letters, numbers, underscores, periods, or hyphens."
  }

  validation {
    condition = alltrue([
      for obj in var.ip_group : alltrue([
        for ip in obj.ip_addresses : provider::assert::cidrv4(ip) || provider::assert::ipv4(ip) || can(regex("^((25[0-5]|2[0-4][0-9]|1?[0-9][0-9]?)\\.){3}(25[0-5]|2[0-4][0-9]|1?[0-9][0-9]?)\\-((25[0-5]|2[0-4][0-9]|1?[0-9][0-9]?)\\.){3}(25[0-5]|2[0-4][0-9]|1?[0-9][0-9]?)$", ip))
      ])
    ])
    error_message = <<DESCRIPTION
Each IP address in every IP Group must be either:
- A valid IPv4 address (e.g., '192.168.1.1'),
- A valid IPv4 range (e.g., '192.168.1.1-192.168.1.100'), or
- A valid CIDR block (e.g., '192.168.1.0/24').
DESCRIPTION
  }
}
