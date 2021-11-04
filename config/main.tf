#################################################
# Controls state size of "vertical slice" workspaces
#################################################

#################################################
# Local vars
#################################################

locals {
  global_ip_workspaces = {
    global-ip = {
      #      project-1 = [
      #      ],
      #      project-2 = [
      #      ],
    }
  }
}

#################################################
# Outputs
#################################################

output "global_ip_workspaces" {
  value = local.global_ip_workspaces
}
