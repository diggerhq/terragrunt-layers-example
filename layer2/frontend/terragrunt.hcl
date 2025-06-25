include "root" {
  path = find_in_parent_folders()
}

terraform {
  source = "../../modules/layer2-frontend"
}

dependency "storage" {
  config_path = "../../layer1/storage"
  
  mock_outputs = {
    bucket_names = ["mock-bucket-1", "mock-bucket-2", "mock-bucket-3"]
  }
}

dependency "monitoring" {
  config_path = "../../layer1/monitoring"
  
  mock_outputs = {
    dashboard_names  = ["mock-dashboard-1", "mock-dashboard-2"]
    log_group_names = ["mock-log-group-1", "mock-log-group-2", "mock-log-group-3"]
  }
}

inputs = {
  environment      = "development"
  project_name     = "terragrunt-example"
  bucket_names    = dependency.storage.outputs.bucket_names
  dashboard_names = dependency.monitoring.outputs.dashboard_names
  log_group_names = dependency.monitoring.outputs.log_group_names
} 