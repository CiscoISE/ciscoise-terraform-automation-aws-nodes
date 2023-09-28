variable "function_name" {
  description = "Name of the custom layer"
  type        = string
  default     = "RegisterSecondaryNodeLambda"
}

variable "aws_region" {
}

variable "subnet_ids" {
}

variable "security_group_ids" {
}

variable "layer_arn" {
}