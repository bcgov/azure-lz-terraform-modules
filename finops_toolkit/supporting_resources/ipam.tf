resource "azureipam_reservation" "finops_toolkit" {
  space       = "bcgov-managed-lz-${lower(var.environment)}"
  block       = "bcgov-managed-lz-${lower(var.environment)}"
  size        = 26
  description = "FinOps Toolkit"
}
