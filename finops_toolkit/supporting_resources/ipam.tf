resource "azureipam_reservation" "finops_toolkit" {
  space       = "bcgov-managed-lz-${lower(var.environment)}"
  blocks      = ["bcgov-managed-lz-${lower(var.environment)}"]
  size        = 24
  description = "finops-toolkit"
}
