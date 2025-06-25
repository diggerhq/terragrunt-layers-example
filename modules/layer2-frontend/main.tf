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

variable "dashboard_names" {
  description = "Dashboard names from layer 1 monitoring"
  type        = list(string)
}

variable "log_group_names" {
  description = "Log group names from layer 1 monitoring"
  type        = list(string)
}

resource "null_resource" "cloudfront_distribution" {
  triggers = {
    environment = var.environment
    s3_bucket   = var.bucket_names[0] # Use first bucket for static content
    cdn_name    = "${var.project_name}-${var.environment}-cdn"
  }

  provisioner "local-exec" {
    command = "echo 'Creating CloudFront distribution ${self.triggers.cdn_name} for bucket ${self.triggers.s3_bucket}'"
  }
}

resource "null_resource" "web_assets" {
  count = 2

  triggers = {
    environment    = var.environment
    cdn_id         = null_resource.cloudfront_distribution.id
    asset_name     = "web-asset-${count.index + 1}"
    storage_bucket = var.bucket_names[count.index % length(var.bucket_names)]
  }

  provisioner "local-exec" {
    command = "echo 'Deploying web asset ${self.triggers.asset_name} to bucket ${self.triggers.storage_bucket}'"
  }

  depends_on = [null_resource.cloudfront_distribution]
}

resource "null_resource" "frontend_monitoring" {
  triggers = {
    environment  = var.environment
    cdn_id       = null_resource.cloudfront_distribution.id
    dashboard_id = var.dashboard_names[0]
    log_group    = var.log_group_names[0]
  }

  provisioner "local-exec" {
    command = "echo 'Setting up frontend monitoring with dashboard ${self.triggers.dashboard_id} and logs ${self.triggers.log_group}'"
  }

  depends_on = [null_resource.cloudfront_distribution]
}

output "cloudfront_distribution_id" {
  value = null_resource.cloudfront_distribution.id
}

output "web_asset_ids" {
  value = null_resource.web_assets[*].id
}

output "frontend_config" {
  value = {
    cloudfront_distribution_id = null_resource.cloudfront_distribution.id
    web_asset_ids              = null_resource.web_assets[*].id
  }
} 
