variable "vpc_id" {
}

variable "subnet_ids" {
}

variable "security_group_ids" {
}

variable "layer_arn" {
}

variable "aws_region" {
}

variable "function_name" {
  description = "Name for the Lambda function"
  type        = string
  default     = "CheckSyncStatusLambda"
}