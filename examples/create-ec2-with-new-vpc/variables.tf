###################################
###  VPC Details ###
###################################
variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string

}

variable "vpc_name" {
  description = "Name tag for the VPC"
  type        = string

}

variable "aws_region" {
  description = "Specify the AWS region"
  type        = string

}

variable "availability_zones" {
  description = "List of availability zones"
  type        = list(string)

}

variable "public_subnet_cidrs" {
  description = "List of CIDR blocks for public subnets"
  type        = list(string)

}

variable "private_subnet_cidrs" {
  description = "List of CIDR blocks for private subnets"
  type        = list(string)

}

variable "internet_gateway_name" {
  description = "Name tag for the Internet Gateway"
  type        = string

}

###################################
###  EC2 Details ###
###################################

variable "primary_instance_type" {
  description = "Choose the required primary/Secondary node instance type. Valid values are c5.4xlarge , m5.4xlarge, c5.9xlarge, t3.xlarge"
  type        = string

}

variable "psn_instance_type" {
  description = "Choose the required instance type for PSN nodes. Valid values are c5.4xlarge , m5.4xlarge, c5.9xlarge, t3.xlarge"
  type        = string

}

### Based of below input, it will launch N number of PSN Nodes ###
variable "psn_node_count" {
  description = "Specify the number of PSN nodes"

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

}

###Storage Details###

variable "ebs_encrypt" {
  description = "Choose true to enable EBS encryption"
}

variable "primary_storage_size" {
  description = "Specify the storage in GB for primary/secondary nodes (Minimum 300GB and Maximum 2400GB). 600GB is recommended for production use, storage lesser than 600GB can be used for evaluation purpose only. On terminating the instance, volume will be deleted as well."
  type        = string
}

variable "psn_storage_size" {
  description = "Specify the storage in GB for PSN nodes (Minimum 300GB and Maximum 2400GB). 600GB is recommended for production use, storage lesser than 600GB can be used for evaluation purpose only. On terminating the instance, volume will be deleted as well."
  type        = string
}

###########################################
### Application Details ###
###########################################
### NOTE: The username for ISE 3.1 is "admin" and for ISE 3.2+ is "iseadmin" ###
variable "ise_version" {
  description = "The version of Cisco ISE (3.1 or 3.2)"
  type        = string
}

variable "password" {
  description = "The password for username (admin) to log in to the Cisco ISE GUI. The password must contain a minimum of 6 and maximum of 25 characters, and must include at least one numeral, one uppercase letter, and one lowercase letter. Password should not be the same as username or its reverse(admin or nimdaesi) or (cisco or ocsic). Allowed Special Characters @~*!,+=_-"
  type        = string
}

variable "time_zone" {
  description = "Enter a timezone, for example, Etc/UTC"
  type        = string
}

variable "ers_api" {
  description = "Enter yes/no to enable/disable ERS"
  type        = string
}

variable "open_api" {
  description = "Enter yes/no to enable/disable OpenAPI"
  type        = string
}

variable "px_grid" {
  description = "Enter yes/no to enable/disable pxGrid"
  type        = string
}

variable "px_grid_cloud" {
  description = "Enter yes/no to enable/disable pxGrid Cloud. To enable pxGrid Cloud, you must enable pxGrid. If you disallow pxGrid, but enable pxGrid Cloud, pxGrid Cloud services are not enabled on launch"
  type        = string
}

#######################################
###  DNS Domain Name ###
#######################################
variable "dns_domain" {
  description = "Enter a domain name in correct syntax (for example, cisco.com). The valid characters for this field are ASCII characters, numerals, hyphen (-), and period (.). If you use the wrong syntax, Cisco ISE services might not come up on launch."
  type        = string
}
