output client_id {
  value = data.azurerm_key_vault_secret.sp_id.value
}

output client_secret {
  value = data.azurerm_key_vault_secret.sp_secret.value
}
