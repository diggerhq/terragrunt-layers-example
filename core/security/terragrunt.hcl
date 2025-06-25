include "root" {
  path = find_in_parent_folders()
}

terraform {
  source = "../../modules/core-security"
}

inputs = {
  environment  = "development"
  project_name = "terragrunt-example"
} 