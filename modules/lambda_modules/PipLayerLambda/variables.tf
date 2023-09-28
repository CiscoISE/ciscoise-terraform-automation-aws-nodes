variable "function_name" {
  description = "Name of the custom layer"
  type        = string
  default     = "CiscoISELayer"
}

variable "packages" {
  description = "List of Python packages to include in the layer"
  type        = list(string)
  default     = ["boto3", "requests"]
}

variable "aws_region" {
}