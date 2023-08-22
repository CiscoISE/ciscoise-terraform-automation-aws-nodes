variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-2"
}

variable "vpcid" {
  description = "ID of the VPC (e.g., vpc-0343606e)"
  type        = string
  default     = "vpc-0343606e"
}

variable "vpccidr" {
  description = "CIDR block for the VPC."
  type        = string
  default     = "10.0.0.0/16"
}

variable "desired_size" {
  description = "Desired Size for ISE Auto scaling group"
  default     = 3
}

variable "private_subnet1_a" {
  description = "ID of the subnet to be used for the ISE deployment in an Availability Zone A."
  type        = string
  default     = "subnet-0df14f124d0600552"
}

variable "private_subnet1_b" {
  description = "ID of the subnet to be used for the ISE deployment in an Availability Zone B."
  type        = string
  default     = "subnet-0f8ea32f78cd89ee9"
}

variable "ise_version" {
  description = "The version of Cisco ISE (3.1 or 3.2)"
  type        = string
  default     = "3.2"
}

variable "max_size" {
  description = "Max Size for ISE Auto scaling group"
  default     = 5
}

variable "min_size" {
  description = "Min Size for ISE Auto scaling group"
  default     = 2
}

variable "dns_domain" {
  type    = string
  default = "drilldevops.in" # Set to the appropriate DNS domain
}

variable "ise_instance_type" {
  description = "Choose the required Cisco ISE instance type. Valid values are c5.4xlarge , m5.4xlarge, c5.9xlarge, t3.xlarge"
  type        = string
  default     = "t3.xlarge"
}