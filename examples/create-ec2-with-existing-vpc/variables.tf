###################################
### Block to Update VPC Details ###
###################################
variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
  default     = "vpc-057efe0e8a68a3b55"
}

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "vpc_name" {
  description = "Name tag for the VPC"
  type        = string
  default     = "cisco_ise"
}

variable "availability_zones" {
  description = "List of availability zones"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b", "us-east-1c"]
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

variable "subnet_id_list" {
  description = "List of subnet IDs to launch resources in. The list should contain subnet id's in following order - [\"subnetid in A AZ\", \"subnetid in B AZ\", \"subnetid in C AZ\"]"
  type        = list(string)
  default     = [ "subnet-045716712cef0ea64", "subnet-00951b7d1a25cd789", "subnet-00c1fd9e924862a07"]
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

###################################
### Block to Update EC2 Details ###
###################################
variable "ise_instance_type" {
  description = "Choose the required Cisco ISE instance type. Valid values are c5.4xlarge , m5.4xlarge, c5.9xlarge, t3.xlarge"
  type        = string
  default     = "t3.xlarge"
}

### Based of below input, it will launch N number of PSN Nodes ###
variable "psn_node_count" {
  description = "Specify the number of PSN nodes"
  default     = 2
}

### User needs to create a keypair and pass the key pair name
variable "key_pair_name" {
  description = <<-EOT
    To access the Cisco ISE instance via SSH, choose the key pair that you created/imported in AWS.
    Create/import a key pair in AWS now if you have not configured one already.
    Usage example:  ssh -i mykeypair.pem admin@myhostname.compute-1.amazonaws.com.
    NOTE: The username for ISE 3.1 is "admin" and for ISE 3.2+ is "iseadmin".
  EOT  
  type        = string
  default     = "ise-test-nv"
}

###Storage Details###

variable "ebs_encrypt" {
  description = "Choose true to enable EBS encryption"
  default     = false
}

variable "storage_size" {
  description = "Specify the storage in GB (Minimum 300GB and Maximum 2400GB). 600GB is recommended for production use, storage lesser than 600GB can be used for evaluation purpose only. On terminating the instance, volume will be deleted as well."
  type        = string
  default     = "600"
}

###########################################
### Block to Update Application Details ###
###########################################
### NOTE: The username for ISE 3.1 is "admin" and for ISE 3.2+ is "iseadmin" ###
variable "ise_version" {
  description = "The version of Cisco ISE (3.1 or 3.2)"
  type        = string
  default     = "3.1"
}

variable "password" {
  type    = string
  default = "C!sc0Ind1@" # Set to the appropriate password
}

variable "time_zone" {
  type    = string
  default = "UTC" # Set to the appropriate timezone
}

variable "ers_api" {
  type    = string
  default = "yes" # Set to the appropriate ERS API value
}

variable "open_api" {
  type    = string
  default = "yes" # Set to the appropriate Open API value
}

variable "px_grid" {
  type    = string
  default = "yes" # Set to the appropriate PX Grid value
}

variable "px_grid_cloud" {
  type    = string
  default = "yes" # Set to the appropriate PX Grid Cloud value
}

#######################################
### Block to Update DNS Domain Name ###
#######################################
variable "dns_domain" {
  type    = string
  default = "drilldevops.in" # Set to the appropriate DNS domain
}