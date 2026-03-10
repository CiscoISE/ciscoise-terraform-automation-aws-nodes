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

# AWS Setup related variables:

# List of availability zones to use for creating resources
availability_zones = [
  "us-east-1a",
  "us-east-1b"
]
aws_region               = "us-east-1"    # AWS region in which resources will be provisioned.
create_eips              = true           # Whether to create Elastic IPs (EIPs) for resources like NAT gateways. Allowed values are 'true' and 'false'
create_nat_gateways      = true           # Whether to create NAT gateways for private subnets to access the internet. Allowed values are 'true' and 'false'
dhcp_domain_name         = "ec2.internal" # The domain name to use for the DHCP option set (Amazon-provided DNS name).
dhcp_options_domain_name = "example.com"  # The domain name to use for the DHCP option set (custom DNS name).

# List of DNS servers for instances in the VPC.
domain_name_servers = [
  "169.254.169.253"
]

enable_dns_hostnames  = true            # Whether to enable DNS hostnames for instances in the VPC. Allowed values are 'true' and 'false'
enable_dns_support    = true            # Whether to enable DNS resolution for instances in the VPC. Allowed values are 'true' and 'false'
internet_gateway_name = "Cisco_ISE_IGW" # The name of the internet gateway to be created.

# List of NTP (Network Time Protocol) servers for instances in the VPC.
ntp_servers = [
  "169.254.169.123"
]

# Enter the Subnet CIDR for Private Subnets 
private_subnet_cidrs = [
  "10.0.11.0/24",
  "10.0.12.0/24"
]

# Enter the Subnet CIDR for Public Subnets 
public_subnet_cidrs = [
  "10.0.1.0/24",
  "10.0.2.0/24"
]

# Enter Network related variables
vpc_cidr = "10.0.0.0/16" # The CIDR block for the VPC (Virtual Private Cloud).
vpc_name = "cisco_ise"   # The name of the VPC.
