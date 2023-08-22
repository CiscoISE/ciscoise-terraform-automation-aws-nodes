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

variable "vpc_name" {
  description = "Name tag for the VPC"
  type        = string
  default     = "cisco_ise"
}

variable "availability_zones" {
  description = "List of availability zones"
  type        = list(string)
  default     = ["us-east-2a", "us-east-2b", "us-east-2c"]
}

variable "public_subnet_cidrs" {
  description = "List of CIDR blocks for public subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

variable "private_subnet_cidrs" {
  description = "List of CIDR blocks for private subnets"
  type        = list(string)
  default     = ["10.0.11.0/24", "10.0.12.0/24", "10.0.13.0/24"]
}

variable "internet_gateway_name" {
  description = "Name tag for the Internet Gateway"
  type        = string
  default     = "Cisco_ISE_IGW"
}

variable "dhcp_domain_name" {
  description = "Domain name for DHCP options"
  type        = string
  default     = "ec2.internal"
}

variable "ise_instance_type" {
  description = "Choose the required Cisco ISE instance type. Valid values are c5.4xlarge , m5.4xlarge, c5.9xlarge, t3.xlarge"
  type        = string
  default     = "t3.xlarge"
}
variable "dns_domain" {
  type    = string
  default = "drilldevops.in" # Set to the appropriate DNS domain
}