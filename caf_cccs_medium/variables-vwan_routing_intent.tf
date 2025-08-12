variable "rfc_1918_address_ranges" {
  description = "List of RFC 1918 address ranges."
  type        = list(string)
  default = [
    "10.0.0.0/8",
    "172.16.0.0/12",
    "192.168.0.0/16",
    "100.64.0.0/10"
  ]
}

variable "onpremises_address_ranges" {
  description = "List of on-premises address ranges."
  type        = list(string)
}

# variable "vhub_resource_id" {
#   description = "Resource ID of the Virtual Hub."
#   type        = string
# }

# variable "firewall_resource_id" {
#   description = "Resource ID of the Azure Firewall."
#   type        = string
# }
