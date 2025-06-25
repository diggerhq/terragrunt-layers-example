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

variable "subnet_ids" {
  description = "Subnet IDs from core network"
  type        = list(string)
}

variable "security_group_ids" {
  description = "Security group IDs from core security"
  type        = list(string)
}

resource "null_resource" "compute_instances" {
  count = 2

  triggers = {
    environment       = var.environment
    vpc_id            = var.vpc_id
    subnet_id         = var.subnet_ids[count.index % length(var.subnet_ids)]
    security_group_id = var.security_group_ids[0]
    instance_name     = "compute-${count.index + 1}"
  }

  provisioner "local-exec" {
    command = "echo 'Creating compute instance ${self.triggers.instance_name} in subnet ${self.triggers.subnet_id}'"
  }
}

resource "null_resource" "load_balancer" {
  triggers = {
    environment = var.environment
    vpc_id      = var.vpc_id
  }

  provisioner "local-exec" {
    command = "echo 'Creating load balancer in VPC ${var.vpc_id}'"
  }

  depends_on = [null_resource.compute_instances]
}

output "instance_ids" {
  value = null_resource.compute_instances[*].id
}

output "load_balancer_id" {
  value = null_resource.load_balancer.id
}

output "compute_config" {
  value = {
    instance_ids     = null_resource.compute_instances[*].id
    load_balancer_id = null_resource.load_balancer.id
  }
} 
