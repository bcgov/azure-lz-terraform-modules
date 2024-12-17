# Azure Firewall IDPS Signature Rules Overrides

This code is incompleted/work in progress. It is being kept for future reference.

## Of Note

The primary process for using this code is as follows:

1. Run the `idps_signature_rules.sh` script to get all of the IDPS signature rules from Azure Firewall.
  - This will create multiple JSON files (each with up to 1000 rules) in the `idps_signature_rules` directory.
2. Run the `merge_results.sh` script to merge all of the JSON files into a single JSON file.
  - This will create a single JSON file (called `merged_results_formatted.json`) in the `temp` directory.
3. Run the Terraform code, that should read/extract each respective signature rule ID from the merged results, and loop over them, setting the desired **Intrusion Detection** `signatureOverrides` action for each rule.

Additionally, there is some other (incomplete) code that reads the `SampleThreatExport.json` file, extracts the object names, and creates a list of `fqdn_names` and `ip_addresses`. This code would then be used to set the **Threat Intelligence Allow List** (ie. `threatIntelWhitelist`).
