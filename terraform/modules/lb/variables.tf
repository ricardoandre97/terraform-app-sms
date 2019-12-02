variable "subnets" {
  type = list
  description = "Subnets for the LB"
}

variable "secgroups" {
  type = list
  description = "List of secgroups for the lb"
}

variable "internal" {
  type = bool
  description = "Should this be internal?"
}

variable "project" {}

variable "vpc_id" {
    description = "VPC ID to use when creating resources"
}

variable "health_check_path" {
    description = "HTTP path to check for healthy status"
}

variable "app_port" {
  description = "Port where the app will be listening"
}