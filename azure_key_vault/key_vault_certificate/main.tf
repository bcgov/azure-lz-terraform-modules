resource "azurerm_key_vault_certificate" "this" {
  name         = var.certificate_name
  key_vault_id = var.key_vault_id

  certificate {
    contents = filebase64(var.certificate.contents)
    password = var.certificate.password
  }

  # dynamic "certificate" {
  #   content {
  #     contents = filebase64(var.certificate.contents)
  #     password = certificate.value.password
  #   }
  # }
}
