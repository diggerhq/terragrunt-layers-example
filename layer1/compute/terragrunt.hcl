include "root" {
  path = find_in_parent_folders()
}

terraform {
  source = "../../modules/layer1-compute"
}

dependency "network" {
  config_path = "../../core/network"
  
  mock_outputs = {
    vpc_id     = "mock-vpc-id"
    subnet_ids = ["mock-subnet-1", "mock-subnet-2", "mock-subnet-3"]
  }
}

dependency "security" {
  config_path = "../../core/security"
  
  mock_outputs = {
    security_group_ids = ["mock-sg-1", "mock-sg-2"]
  }
}

inputs = {
  environment        = "development"
  project_name       = "terragrunt-example"
  vpc_id            = dependency.network.outputs.vpc_id
  subnet_ids        = dependency.network.outputs.subnet_ids
  security_group_ids = dependency.security.outputs.security_group_ids
} 