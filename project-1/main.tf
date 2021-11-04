#################################################
# Creates N projects
#################################################

#################################################
# Local vars
#################################################

locals {
  # Customer input
  projects = {
    #    abc = {
    #      data_owner = "mike"
    #    }
    #    xyz = {
    #      data_owner = "ken"
    #    }
  }

  # Get global ips if there's any
  projects_with_global_ip = {
    for app_code, data in data.terraform_remote_state.global_ip_workspace.outputs.global_ips : app_code => data if lookup(local.projects, app_code, "") != ""
  }
}

#################################################
# Remote state
#################################################

data "terraform_remote_state" "global_ip_workspace" {
  backend = "local"
  config = {
    path = "../global-ip/terraform.tfstate"
  }
}

#################################################
# Mock implementation
#################################################

# Let's assume this block creates the project...
resource "random_pet" "project" {
  for_each = local.projects

  keepers = {
    app_code   = each.key
    data_owner = each.value["data_owner"]
  }
}

# Let's assume this block creates GLB...
resource "random_pet" "glb" {
  for_each = local.projects_with_global_ip

  keepers = {
    app_code  = each.key
    global_ip = each.value["global_ip"]
  }
}

#################################################
# Output
#################################################

output "projects" {
  value = {
    for app_code, data in local.projects : app_code => merge(data, {
      project_id = random_pet.project[app_code].id
      global_ip  = try(local.projects_with_global_ip[app_code]["global_ip"], "")
      glb_id     = try(random_pet.glb[app_code].id, "")
    })
  }
}
