include "root" {
  path = find_in_parent_folders()
}

terraform {
  source = "../../modules/layer2-api"
}

dependency "compute" {
  config_path = "../../layer1/compute"
  
  mock_outputs = {
    instance_ids      = ["mock-instance-1", "mock-instance-2"]
    load_balancer_id = "mock-lb-id"
  }
}

dependency "storage" {
  config_path = "../../layer1/storage"
  
  mock_outputs = {
    bucket_names = ["mock-bucket-1", "mock-bucket-2", "mock-bucket-3"]
    rds_endpoint = "mock-rds-endpoint"
  }
}

inputs = {
  environment       = "development"
  project_name      = "terragrunt-example"
  instance_ids      = dependency.compute.outputs.instance_ids
  load_balancer_id = dependency.compute.outputs.load_balancer_id
  bucket_names     = dependency.storage.outputs.bucket_names
  rds_endpoint     = dependency.storage.outputs.rds_endpoint
} 