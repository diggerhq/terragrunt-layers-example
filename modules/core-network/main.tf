variable "environment" {
  description = "Environment name"
  type        = string
}

variable "project_name" {
  description = "Project name"
  type        = string
}

resource "null_resource" "vpc" {
  triggers = {
    environment = var.environment
    project     = var.project_name
  }

  provisioner "local-exec" {
    command = "echo 'Creating VPC for ${var.environment}'"
  }
}

resource "null_resource" "subnets" {
  count = 3

  triggers = {
    vpc_id = null_resource.vpc.id
    az     = "us-west-2${substr("abc", count.index, 1)}"
  }

  provisioner "local-exec" {
    command = "echo 'Creating subnet ${count.index + 1} in ${self.triggers.az}'"
  }

  depends_on = [null_resource.vpc]
}

output "vpc_id" {
  value = null_resource.vpc.id
}

output "subnet_ids" {
  value = null_resource.subnets[*].id
}

output "network_config" {
  value = {
    vpc_id     = null_resource.vpc.id
    subnet_ids = null_resource.subnets[*].id
  }
} 
