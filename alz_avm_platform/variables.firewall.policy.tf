variable "fw_base_config" {
  description = "Configuration for the base firewall policy and its TLS inspection resources."
  type = object({
    resource_group_name                          = string
    tls_inspection_key_vault_name                = string
    tls_inspection_sku_name                      = string
    tls_inspection_enable_rbac_authorization     = bool
    tls_inspection_public_network_access_enabled = bool
    tls_inspection_user_assigned_identity_name   = string
    tls_inspection_certificate_name              = string
    tls_inspection_certificate = object({
      contents = string
      password = optional(string)
    })
    tls_inspection_secret_permissions = list(string)
    intrusion_detection = optional(object({
      mode = string
      traffic_bypass = optional(list(object({
        name                  = string
        protocol              = string
        description           = optional(string)
        destination_addresses = optional(list(string), [])
        destination_ip_groups = optional(list(string), [])
        destination_ports     = optional(list(string), [])
        source_addresses      = optional(list(string), [])
        source_ip_groups      = optional(list(string), [])
      })), [])
    }))
    policy_name = string
    sku         = string
  })
}

variable "fw_lz_config" {
  description = "Configuration for the AVM-managed child firewall policy and its rule collection groups."
  type = object({
    policy_name                  = string
    dns                          = optional(any)
    threat_intelligence_mode     = optional(string)
    private_ip_ranges            = optional(list(string), [])
    policy_rule_collection_group = any
  })
}
