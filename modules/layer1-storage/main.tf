variable "environment" {
  description = "Environment name"
  type        = string
}

variable "project_name" {
  description = "Project name"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID from core network"
  type        = string
}

variable "iam_role_arns" {
  description = "IAM role ARNs from core security"
  type        = list(string)
}

resource "null_resource" "s3_buckets" {
  count = 3

  triggers = {
    environment = var.environment
    project     = var.project_name
    bucket_name = "${var.project_name}-${var.environment}-bucket-${count.index + 1}"
  }

  provisioner "local-exec" {
    command = "echo 'Creating S3 bucket ${self.triggers.bucket_name}'"
  }
}

resource "null_resource" "rds_instance" {
  triggers = {
    environment = var.environment
    vpc_id      = var.vpc_id
    db_name     = "${var.project_name}-${var.environment}-db"
  }

  provisioner "local-exec" {
    command = "echo 'Creating RDS instance ${self.triggers.db_name} in VPC ${var.vpc_id}'"
  }
}

output "bucket_names" {
  value = [for bucket in null_resource.s3_buckets : bucket.triggers.bucket_name]
}

output "rds_endpoint" {
  value = null_resource.rds_instance.id
}

output "storage_config" {
  value = {
    bucket_names = [for bucket in null_resource.s3_buckets : bucket.triggers.bucket_name]
    rds_endpoint = null_resource.rds_instance.id
  }
} 
