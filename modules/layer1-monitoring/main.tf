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

resource "null_resource" "cloudwatch_dashboards" {
  count = 2

  triggers = {
    environment    = var.environment
    dashboard_name = "${var.project_name}-${var.environment}-dashboard-${count.index + 1}"
    iam_role       = var.iam_role_arns[count.index % length(var.iam_role_arns)]
  }

  provisioner "local-exec" {
    command = "echo 'Creating CloudWatch dashboard ${self.triggers.dashboard_name} with role ${self.triggers.iam_role}'"
  }
}

resource "null_resource" "log_groups" {
  count = 3

  triggers = {
    environment = var.environment
    log_group   = "/aws/${var.project_name}/${var.environment}/logs-${count.index + 1}"
  }

  provisioner "local-exec" {
    command = "echo 'Creating log group ${self.triggers.log_group}'"
  }
}

output "dashboard_names" {
  value = [for dashboard in null_resource.cloudwatch_dashboards : dashboard.triggers.dashboard_name]
}

output "log_group_names" {
  value = [for log_group in null_resource.log_groups : log_group.triggers.log_group]
}

output "monitoring_config" {
  value = {
    dashboard_names = [for dashboard in null_resource.cloudwatch_dashboards : dashboard.triggers.dashboard_name]
    log_group_names = [for log_group in null_resource.log_groups : log_group.triggers.log_group]
  }
} 
