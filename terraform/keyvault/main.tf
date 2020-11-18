module "azure-region" {
  source  = "claranet/regions/azurerm"
  version = "x.x.x"

  azure_region = var.azure_region
}

module "rg" {
  source  = "claranet/rg/azurerm"
  version = "x.x.x"

  location    = module.azure-region.location
  client_name = var.client_name
  environment = var.environment
  stack       = var.stack
}

data "azuread_group" "admin_group" {
  name = "Admin"
}

module "key_vault" {
  source  = "claranet/keyvault/azurerm"
  version = "x.x.x"

  client_name         = var.client_name
  environment         = var.environment
  location            = module.azure-region.location
  location_short      = module.azure-region.location_short
  resource_group_name = module.rg.resource_group_name
  stack               = var.stack

  enable_logs_to_storage  = "true"
  logs_storage_account_id = data.terraform_remote_state.run.outputs.logs_storage_account_id

  enable_logs_to_log_analytics    = "true"
  logs_log_analytics_workspace_id = data.terraform_remote_state.run.outputs.log_analytics_workspace_id

  reader_objects_ids = var.webapp_service_principal_id

  # Current user should be here to be able to create keys and secrets
  admin_objects_ids = data.azuread_group.admin_group.id

  # Specify Network ACLs
  network_acls = {
    bypass         = "None"
    default_action = "Deny"
    ip_rules       = ["10.10.0.0/26", "1.2.3.4/32"]

    virtual_network_subnet_ids = module.subnet.subnet_ids
  }
}