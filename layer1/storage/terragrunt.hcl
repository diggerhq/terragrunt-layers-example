include "root" {
  path = find_in_parent_folders()
}

terraform {
  source = "../../modules/layer1-storage"
}

dependency "network" {
  config_path = "../../core/network"
  
  mock_outputs = {
    vpc_id = "mock-vpc-id"
  }
}

dependency "security" {
  config_path = "../../core/security"
  
  mock_outputs = {
    iam_role_arns = ["mock-role-1", "mock-role-2", "mock-role-3"]
  }
}

inputs = {
  environment   = "development"
  project_name  = "terragrunt-example"
  vpc_id       = dependency.network.outputs.vpc_id
  iam_role_arns = dependency.security.outputs.iam_role_arns
} 