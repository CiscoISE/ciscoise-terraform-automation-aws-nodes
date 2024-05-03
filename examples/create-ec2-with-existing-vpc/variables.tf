# Copyright 2024 Cisco Systems, Inc. and its affiliates
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# SPDX-License-Identifier: Apache-2.0

################################################
##############  VPC Details  ###################
################################################
variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
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

variable "subnet_id_list" {
  description = "List of subnet IDs to launch resources in. The list should contain subnet id's in following order - [\"subnetid in A AZ\", \"subnetid in B AZ\", \"subnetid in C AZ\"]"
  type        = list(string)
}

variable "internet_gateway_name" {
  description = "Name tag for the Internet Gateway"
  type        = string
}

###################################
### Block to Update EC2 Details ###
###################################

variable "primary_instance_config" {
  description = <<-EOT
  Specify the configuration for primary pan instance. It should follow below format where key is the hostname and values are instance attributes.
  Hostname only supports alphanumeric characters and hyphen (-). The length of the hostname should not exceed 19 characters.
  {
    <hostname> = {
      instance_type = "<instance_type>"
      storage_size = "<storage_size>"
    }
  }
  Example usage - 
  {
  primary-ise-server = { 
      instance_type = "t3.xlarge"
      storage_size = 500
    }
  }
  EOT
  type = map(object({
    instance_type = string
    storage_size  = number
  }))
}

variable "secondary_instance_config" {
  description = <<-EOT
  Specify the configuration for secondary pan instance. It should follow below format where key is the hostname and values are instance attributes.
  Hostname only supports alphanumeric characters and hyphen (-). The length of the hostname should not exceed 19 characters.
  {
    <hostname> = {
      instance_type = "<instance_type>"
      storage_size = "<storage_size>"
      services =  "<service_1>,<service_2>"
      roles = "<role_1>,<role_2>"
    }
  }
  Example usage -
  {
  secondary-ise-server = { 
      instance_type = "t3.xlarge"
      storage_size = 500
      services = "Session,Profiler,pxGrid"
      roles = "SecondaryAdmin"
    }
  }
  EOT
  type = map(object({
    instance_type = string
    storage_size  = number
    services      = optional(string, " ")
    roles         = optional(string, "SecondaryAdmin")
  }))
}

variable "psn_instance_config" {
  description = <<-EOT
  Specify the configuration for PSN nodes. It should follow below format where key is the hostname and values are instance attributes.
  Hostname only supports alphanumeric characters and hyphen (-). The length of the hostname should not exceed 19 characters.
  {
    <hostname> = {
      instance_type = "<instance_type>"
      storage_size = "<storage_size>"
      services =  "<service_1>,<service_2>"
      roles = "<role_1>,<role_2>"
    }
  }
   Example usage - 
  {
    secmonitoring-server = {
      instance_type = "t3.xlarge"
      storage_size  = 500
      roles = "SecondaryMonitoring"
    }
    psn-ise-server-2 = {
      instance_type = "t3.xlarge"
      storage_size  = 600
      services      = "Session,Profiler,PassiveIdentity"
    }
  }
    EOT
  type = map(object({
    instance_type = string
    storage_size  = number
    services      = optional(string, " ")
    roles         = optional(string, " ")
  }))
}

### Stickiness Block ###
variable "enable_stickiness" {
  description = "Choose true or false to enable/disable stickiness for the load balancer"
  type        = bool
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

###########################################
### Block to Update Application Details ###
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


variable "primarynameserver" {
  description = "Enter the IP address of the primary name server. Only IPv4 addresses are supported. Example: 169.254.169.253"
  type        = string
}

variable "ntpserver" {
  description = "Enter the IPv4 address or FQDN of the NTP server that must be used for synchronization, Example, 169.254.169.123"
  type        = string
}


#######################################
### Block to Update DNS Domain Name ###
#######################################
variable "dns_domain" {
  description = "Enter a domain name in correct syntax (for example, cisco.com). The valid characters for this field are ASCII characters, numerals, hyphen (-), and period (.). If you use the wrong syntax, Cisco ISE services might not come up on launch."
  type        = string
}
