#################################################
# Vertical slice repo for creating global IPs
#################################################

#################################################
# Local vars
#################################################

locals {
  # The name of this workspace
  workspace_name = "global-ip"

  # Find the config tied to this workspace
  config = data.terraform_remote_state.config_workspace.outputs["global_ip_workspaces"][local.workspace_name]

  # Get all project's app codes
  app_codes = flatten([for project_workspace, app_codes in local.config : app_codes])

  # Get all project's details from project workspaces
  nullable_projects = merge([
    for project_workspace, data in data.terraform_remote_state.project_workspaces : data.outputs["projects"]
  ]...)

  # Keep only projects that this workspace care
  projects = local.nullable_projects == null ? {} : {
    for app_code, data in local.nullable_projects : app_code => data if contains(local.app_codes, app_code)
  }
}

#################################################
# Remote state
#################################################

data "terraform_remote_state" "config_workspace" {
  backend = "local"
  config = {
    path = "../config/terraform.tfstate"
  }
}

data "terraform_remote_state" "project_workspaces" {
  for_each = local.config

  backend = "local"
  config = {
    path = "../${each.key}/terraform.tfstate"
  }
}

#################################################
# Mock implementation
#################################################

## Let's assume this block creates global ip...
resource "random_pet" "main" {
  for_each = local.projects

  keepers = {
    app_code = each.key
  }
}

#################################################
# Output - for inspection purposes
#################################################

output "debug_project_inputs" {
  value = merge([
    for project_workspace, data in data.terraform_remote_state.project_workspaces : data.outputs["projects"]
  ]...)
}

output "debug_config" {
  value = local.config
}

output "debug_projects" {
  value = local.projects
}

output "debug_app_codes" {
  value = flatten([for project_workspace, app_codes in local.config : app_codes])
}

output "global_ips" {
  value = {
    for app_code, data in local.projects : app_code => {
      global_ip = random_pet.main[app_code].id
    }
  }
}
