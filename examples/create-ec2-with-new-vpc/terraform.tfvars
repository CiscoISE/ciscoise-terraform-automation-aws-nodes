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
### Block to Update VPC Details ################
################################################
vpc_cidr             = "10.0.0.0/16"                # CIDR block for the VPC
vpc_name             = "cisco_ise"                  # Name tag for the VPC
aws_region           = "us-east-1"                  # Specify the AWS region
availability_zones   = ["us-east-1a", "us-east-1b"] # List of availability zones
enable_dns_hostnames = true                         # Whether to enable DNS hostnames for instances in the VPC. Allowed values are 'true' and 'false'

######################################
### Block to Update Subnet Details ###
######################################

 # NOTE: Minimum 2 subnets are required by this module to ensure availability 
public_subnet_cidrs   = ["10.0.1.0/24", "10.0.2.0/24"]   # List of CIDR blocks for public subnets
private_subnet_cidrs  = ["10.0.11.0/24", "10.0.12.0/24"] # List of CIDR blocks for private subnets
internet_gateway_name = "Cisco_ISE_IGW"                  # Name tag for the Internet Gateway

###################################
### Block to Update EC2 Details ###
###################################
#  Valid instance types are t3.xlarge, m5.2xlarge, c5.4xlarge, m5.4xlarge, c5.9xlarge, m5.8xlarge, m5.16xlarge
#  Allowed Storage size - (Minimum 300GB and Maximum 2400GB)
#  Allowed roles are : PrimaryAdmin, SecondaryAdmin, PrimaryMonitoring, SecondaryMonitoring, PrimaryDedicatedMonitoring, SecondaryDedicatedMonitoring, Standalone
#  Allowed services are : Session, Profiler, TC-NAC, SXP, DeviceAdmin, PassiveIdentity, pxGrid, pxGridCloud

# NOTE: For configuration, please make sure to follow the syntax as mentioned and follow below points before updating the variables
# 1. Do not pass any services or roles values for Primary PAN node in primary_instance_config variable
# 2. Secondary PAN node supports SecondaryAdmin, SecondaryMonitoring and PrimaryMonitoring roles
# 3. PSN node can act as a Mnt (Monitoring) node by assigning any one of these roles - SecondaryMonitoring, SecondaryDedicatedMonitoring, PrimaryMonitoring or PrimaryDedicatedMonitoring
# 4. Monitoring role can only be passed once across secondary_instance_config and psn_instance_config variable
# 5. Service pxGridCloud cannot be added more than once in workload nodes
# 6. Valid characters for hostnames are `ASCII(7)` letters from `a` to `z` , the digits from `0` to `9` , and the hyphen (`−`).


# Specify instance configuration for Primary PAN node. It should follow below syntax where key is the hostname and values are instance attributes
# NOTE: Hostname only supports alphanumeric characters and hyphen (-). The length of the hostname should not exceed 19 characters, otherwise deployment will fail
/*
  {
    <hostname> = {
      instance_type = "<instance_type>"
      storage_size = "<storage_size>"
    }
  }
  
   Usage example - 
   primary_instance_config = { 
    primary-ise-server = { 
      instance_type = "t3.xlarge"
      storage_size = 600 
      }
    }
   */

# NOTE: Hostname only supports alphanumeric characters and hyphen (-). The length of the hostname should not exceed 19 characters, otherwise deployment will fail
# Example: Below primary-ise-server is a dynamic hostname provided by user.
primary_instance_config = {
  primary-ise-server = {
    instance_type = "m5.4xlarge"
    storage_size  = 500
  }
}


# Specify instance configuration for Secondary PAN node. It should follow below syntax where key is the hostname and values are instance attributes.
# NOTE: Hostname only supports alphanumeric characters and hyphen (-). The length of the hostname should not exceed 19 characters, otherwise deployment will fail
/*
  {
    <hostname> = {
      instance_type = "<instance_type>"
      storage_size = "<storage_size>"
      services =  "<service_1>,<service_2>"
      roles = "<role_1>,<role_2>"
    }
  }
  Example usage -
  secondary_instance_config = {
  secondary-ise-server = {
    instance_type = "t3.xlarge"
    storage_size  = 500
    services      = "Session,Profiler,pxGrid"
    roles         = "SecondaryAdmin"
  }
}
*/

# NOTE: Hostname only supports alphanumeric characters and hyphen (-). The length of the hostname should not exceed 19 characters, otherwise deployment will fail
# Example: Below sec-ise-server is a dynamic hostname provided by user.
secondary_instance_config = {
  sec-ise-server = {
    instance_type = "t3.xlarge"
    storage_size  = 500
    services      = "Session,Profiler,pxGrid"
    roles         = "SecondaryAdmin"
  }
}

# Specify instance configuration for N PSN nodes. It should follow below syntax where key is the hostname and values are instance attributes.
# NOTE: Hostname only supports alphanumeric characters and hyphen (-). The length of the hostname should not exceed 19 characters, otherwise deployment will fail
/*
 {
    <hostname> = {
      instance_type = "<instance_type>"
      storage_size = "<storage_size>"
      services =  "<service_1>,<service_2>"
      roles = "<role_1>,<role_2>"
    }
  }
  
Please use below example for the reference.

  psn_instance_config = {
    secmonitoring-server = {
      instance_type = "m5.2xlarge"
      storage_size  = 500
      roles = "SecondaryDedicatedMonitoring"
    }
    psn-ise-server-2 = {
      instance_type = "t3.xlarge"
      storage_size  = 600
      services      = "Session,Profiler,PassiveIdentity"
    }
    psn-ise-server-3 = {
      instance_type = "c5.4xlarge"
      storage_size  = 700
    }
}
*/

# NOTE: Hostname only supports alphanumeric characters and hyphen (-). The length of the hostname should not exceed 19 characters, otherwise deployment will fail
# Example: Below secmon-server, psn-ise-server-2 and so on are the dynamic hostname provided by user.
psn_instance_config = {
  secmon-server = {
    instance_type = "m5.2xlarge"
    storage_size  = 500
    roles         = "SecondaryMonitoring"
  }
  psn-ise-server-2 = {
    instance_type = "t3.xlarge"
    storage_size  = 600
    services      = "Session,Profiler,PassiveIdentity"

  }
  psn-ise-server-3 = {
    instance_type = "t3.xlarge"
    storage_size  = 700
    services      = "Session,Profiler"
  }
}

### User needs to create a keypair and pass the key pair name
key_pair_name = "ise-test-nv" # Name of the key pair for SSH access

###Storage Details###
ebs_encrypt = false # Choose true to enable EBS encryption

### Stickiness block ###
enable_stickiness = true # Choose true to enable stickiness for the load balancer

# Application Details
ise_version       = "3.1"             # The version of Cisco ISE (3.1 or 3.2 or 3.3)
password          = "C!sc0Ind1@"      # Set a password for GUI-based login to Cisco ISE. The password that you enter must comply with the Cisco ISE password policy. The password must contain 6 to 25 characters and include at least one numeral, one uppercase letter, and one lowercase letter. The password cannot be the same as the username or its reverse (iseadmin or nimdaesi), cisco, or ocsic. The allowed special characters are @~*!,+=_-.
time_zone         = "UTC"             # Enter a timezone
ers_api           = "yes"             # Enable/disable ERS
open_api          = "yes"             # Enable/disable OpenAPI
px_grid           = "yes"             # Enable/disable pxGrid
px_grid_cloud     = "yes"             # Enable/disable pxGrid Cloud
primarynameserver = "169.254.169.253" # Enter the IP address of the primary name server. Only IPv4 addresses are supported.
ntpserver         = "169.254.169.123" # Enter the IPv4 address or FQDN of the NTP server that must be used for synchronization.

# DNS Domain Name
dns_domain = "example.com" # Enter a domain name in correct syntax
