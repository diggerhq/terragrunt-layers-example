variable "environment" {
  description = "Environment name"
  type        = string
}

variable "project_name" {
  description = "Project name"
  type        = string
}

variable "bucket_names" {
  description = "Bucket names from layer 1 storage"
  type        = list(string)
}

variable "rds_endpoint" {
  description = "RDS endpoint from layer 1 storage"
  type        = string
}

variable "log_group_names" {
  description = "Log group names from layer 1 monitoring"
  type        = list(string)
}

variable "instance_ids" {
  description = "Instance IDs from layer 1 compute"
  type        = list(string)
}

resource "null_resource" "data_pipeline" {
  triggers = {
    environment   = var.environment
    source_bucket = var.bucket_names[1] # Use second bucket for analytics data
    rds_endpoint  = var.rds_endpoint
    pipeline_name = "${var.project_name}-${var.environment}-pipeline"
  }

  provisioner "local-exec" {
    command = "echo 'Creating data pipeline ${self.triggers.pipeline_name} from bucket ${self.triggers.source_bucket} to RDS ${var.rds_endpoint}'"
  }
}

resource "null_resource" "analytics_jobs" {
  count = 2

  triggers = {
    environment = var.environment
    pipeline_id = null_resource.data_pipeline.id
    job_name    = "analytics-job-${count.index + 1}"
    compute_id  = var.instance_ids[count.index % length(var.instance_ids)]
    log_group   = var.log_group_names[count.index % length(var.log_group_names)]
  }

  provisioner "local-exec" {
    command = "echo 'Creating analytics job ${self.triggers.job_name} on compute ${self.triggers.compute_id} logging to ${self.triggers.log_group}'"
  }

  depends_on = [null_resource.data_pipeline]
}

resource "null_resource" "data_warehouse" {
  triggers = {
    environment    = var.environment
    pipeline_id    = null_resource.data_pipeline.id
    warehouse_name = "${var.project_name}-${var.environment}-warehouse"
    target_bucket  = var.bucket_names[2] # Use third bucket for processed data
  }

  provisioner "local-exec" {
    command = "echo 'Creating data warehouse ${self.triggers.warehouse_name} storing results in ${self.triggers.target_bucket}'"
  }

  depends_on = [null_resource.analytics_jobs]
}

output "data_pipeline_id" {
  value = null_resource.data_pipeline.id
}

output "analytics_job_ids" {
  value = null_resource.analytics_jobs[*].id
}

output "data_warehouse_id" {
  value = null_resource.data_warehouse.id
}

output "analytics_config" {
  value = {
    data_pipeline_id  = null_resource.data_pipeline.id
    analytics_job_ids = null_resource.analytics_jobs[*].id
    data_warehouse_id = null_resource.data_warehouse.id
  }
} 
