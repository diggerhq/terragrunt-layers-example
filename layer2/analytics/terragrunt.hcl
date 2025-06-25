include "root" {
  path = find_in_parent_folders()
}

terraform {
  source = "../../modules/layer2-analytics"
}

dependency "compute" {
  config_path = "../../layer1/compute"
  
  mock_outputs = {
    instance_ids = ["mock-instance-1", "mock-instance-2"]
  }
}

dependency "storage" {
  config_path = "../../layer1/storage"
  
  mock_outputs = {
    bucket_names = ["mock-bucket-1", "mock-bucket-2", "mock-bucket-3"]
    rds_endpoint = "mock-rds-endpoint"
  }
}

dependency "monitoring" {
  config_path = "../../layer1/monitoring"
  
  mock_outputs = {
    log_group_names = ["mock-log-group-1", "mock-log-group-2", "mock-log-group-3"]
  }
}

inputs = {
  environment      = "development"
  project_name     = "terragrunt-example"
  instance_ids     = dependency.compute.outputs.instance_ids
  bucket_names    = dependency.storage.outputs.bucket_names
  rds_endpoint    = dependency.storage.outputs.rds_endpoint
  log_group_names = dependency.monitoring.outputs.log_group_names
} 