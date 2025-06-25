variable "environment" {
  description = "Environment name"
  type        = string
}

variable "project_name" {
  description = "Project name"
  type        = string
}

variable "instance_ids" {
  description = "Instance IDs from layer 1 compute"
  type        = list(string)
}

variable "load_balancer_id" {
  description = "Load balancer ID from layer 1 compute"
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

resource "null_resource" "api_gateway" {
  triggers = {
    environment      = var.environment
    load_balancer_id = var.load_balancer_id
    api_name         = "${var.project_name}-${var.environment}-api"
  }

  provisioner "local-exec" {
    command = "echo 'Creating API Gateway ${self.triggers.api_name} connected to LB ${var.load_balancer_id}'"
  }
}

resource "null_resource" "api_endpoints" {
  count = 3

  triggers = {
    environment    = var.environment
    api_gateway_id = null_resource.api_gateway.id
    endpoint_name  = "endpoint-${count.index + 1}"
    instance_id    = var.instance_ids[count.index % length(var.instance_ids)]
  }

  provisioner "local-exec" {
    command = "echo 'Creating API endpoint ${self.triggers.endpoint_name} for instance ${self.triggers.instance_id}'"
  }

  depends_on = [null_resource.api_gateway]
}

resource "null_resource" "api_database_connection" {
  triggers = {
    api_gateway_id = null_resource.api_gateway.id
    rds_endpoint   = var.rds_endpoint
  }

  provisioner "local-exec" {
    command = "echo 'Connecting API Gateway to RDS endpoint ${var.rds_endpoint}'"
  }

  depends_on = [null_resource.api_gateway]
}

output "api_gateway_id" {
  value = null_resource.api_gateway.id
}

output "api_endpoint_ids" {
  value = null_resource.api_endpoints[*].id
}

output "api_config" {
  value = {
    api_gateway_id   = null_resource.api_gateway.id
    api_endpoint_ids = null_resource.api_endpoints[*].id
  }
} 
