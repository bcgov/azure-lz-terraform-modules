locals {
  # threat_intelligence_allowlist = {
  #   fqdns        = ["example.com", "subdomain.example.com"]
  #   ip_addresses = ["192.168.1.10", "10.0.0.1"]
  # }

  json_data = jsondecode(file("${path.module}/SampleThreatExport.json"))
  
  # Extracting all object names by removing the prefix
  object_names = [
    for obj in local.json_data.objects : replace(obj.name, regex("[^:]+: ", obj.name), "")
  ]

  # Regular expression for matching an IPv4 address
  ip_regex = "^([0-9]{1,3}\\.){3}[0-9]{1,3}$"

  # Separate FQDNs and IP addresses
  fqdn_names = [for name in local.object_names : name if !can(regex(local.ip_regex, name))]
  ip_addresses = [for name in local.object_names : name if can(regex(local.ip_regex, name))]
}
