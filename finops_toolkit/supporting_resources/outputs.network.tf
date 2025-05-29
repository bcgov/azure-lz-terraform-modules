output "data_gateway_subnet" {
  description = "The subnet for the Power BI Data Gateway"
  value       = azapi_resource.powerbi_data_gateway_subnet
}
