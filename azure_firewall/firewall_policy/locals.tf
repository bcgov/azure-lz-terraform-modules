locals {
  # combined_ignore_changes = concat(var.lifecycle_ignore_enabled, [
  #   # Add any additional attributes you want to ignore changes for
  #   # For example:
  #   # "some_other_attribute",
  # ])

  ignore_changes = [
      base_policy_id,
      dns,
      identity,
      insights,
      intrusion_detection,      
      private_ip_ranges,
      auto_learn_private_ranges_enabled,
      sku,
      tags,
      threat_intelligence_mode,
      threat_intelligence_allowlist,
      tls_certificate,
      sql_redirect_allowed,
      explicit_proxy
    ]
}