variable "environment" {
  description = "Environment name"
  type        = string
}

variable "project_name" {
  description = "Project name"
  type        = string
}

resource "null_resource" "security_groups" {
  count = 2

  triggers = {
    environment = var.environment
    project     = var.project_name
    name        = "sg-${count.index + 1}"
  }

  provisioner "local-exec" {
    command = "echo 'Creating security group ${self.triggers.name} for ${var.environment}'"
  }
}

resource "null_resource" "iam_roles" {
  count = 3

  triggers = {
    environment = var.environment
    role_name   = "role-${count.index + 1}"
  }

  provisioner "local-exec" {
    command = "echo 'Creating IAM role ${self.triggers.role_name}'"
  }
}

output "security_group_ids" {
  value = null_resource.security_groups[*].id
}

output "iam_role_arns" {
  value = null_resource.iam_roles[*].id
}

output "security_config" {
  value = {
    security_group_ids = null_resource.security_groups[*].id
    iam_role_arns      = null_resource.iam_roles[*].id
  }
} 
