# Terraform Remote State POC

## Workspaces

- `config` = Controls how much state `global-ip` workspaces should manage
- `global-ip` = Creates global IP within the project once project is created
- `project-[N]` = Creates customer projects

## State Dependencies

![State Dependencies](doc/state-dependencies.png)

## Workflow

## One time activity
1. `config`: Initialize workspace... code cert, plan/apply to set up initial state
2. `global-ip`: Initialize workspace... code cert, plan/apply to set up initial state

### Project Creation 

1. `project-[N]`: Create a project... code cert, plan/apply to expose project info 
2. `config`: Add an entry... code cert, plan/apply to expose output
3. `global-ip`: No code changes... plan/apply to create global IP
4. `project-[N]`No code changes... plan/apply to create GLB

### Project Deletion

1. `config`: Delete an entry... code cert, plan/apply to remove config
2. `global-ip`: No code changes... plan/apply to remove global IP
3. `project-[N]`: Remove project info... code cert, plan/apply to remove project
