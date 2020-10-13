dependency "function_app" {
  config_path = "../function-app"
}

# Internal
dependency "resource_group" {
  config_path = "../../resource_group"
}

dependency "application_insights" {
  config_path = "../../application_insights"
}

# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

terraform {
  source = "git::git@github.com:pagopa/io-infrastructure-modules-new.git//azurerm_function_app_slot?ref=v2.1.0"
}

inputs = {
  name                       = "staging"
  resource_group_name        = dependency.resource_group.outputs.resource_name
  function_app_name          = dependency.function_app.outputs.name
  function_app_resource_name = dependency.function_app.outputs.resource_name
  app_service_plan_id        = dependency.function_app.outputs.app_service_plan_id
  storage_account_name       = dependency.function_app.outputs.storage_account.name
  storage_account_access_key = dependency.function_app.outputs.storage_account.primary_access_key

  runtime_version = "~3"

  # auto_swap_slot_name = "production"

  application_insights_instrumentation_key = dependency.application_insights.outputs.instrumentation_key

  # site_config
  pre_warmed_instance_count = 0

  app_settings = {
    FUNCTIONS_WORKER_RUNTIME     = "node"
    WEBSITE_NODE_DEFAULT_VERSION = "10.14.1"
    WEBSITE_RUN_FROM_PACKAGE     = "1"
    NODE_ENV                     = "production"

    SLOT_TASK_HUBNAME = "StagingTaskHub"
  }

  app_settings_secrets = {
    key_vault_id = "dummy"
    map          = {}
  }

}