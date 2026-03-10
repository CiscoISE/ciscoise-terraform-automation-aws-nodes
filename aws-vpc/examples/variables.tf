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

######################################################################################
#######################     Block to add AWS VPC variables   #########################
######################################################################################
variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = ""
}

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = ""
}

variable "vpc_name" {
  description = "Name tag for the VPC"
  type        = string
  default     = ""
}

variable "enable_dns_support" {
  description = "Whether to enable DNS support for the VPC"
  type        = bool
  default     = null
}

variable "enable_dns_hostnames" {
  description = "Whether to enable DNS hostnames for the VPC"
  type        = bool
  default     = null
}


variable "availability_zones" {
  description = "List of availability zones"
  type        = list(string)
  default     = []
}

variable "public_subnet_cidrs" {
  description = "List of CIDR blocks for public subnets"
  type        = list(string)
  default     = []
}

variable "private_subnet_cidrs" {
  description = "List of CIDR blocks for private subnets"
  type        = list(string)
  default     = []
}

variable "internet_gateway_name" {
  description = "Name tag for the Internet Gateway"
  type        = string
  default     = "Cisco_ISE_IGW"
}
variable "dhcp_domain_name" {
  description = "Domain name for DHCP options"
  type        = string
  default     = ""
}

variable "create_nat_gateways" {
  description = "Create NAT Gateways for public subnets"
  type        = bool
  default     = null
}

variable "create_eips" {
  description = "Create Elastic IPs for NAT Gateways"
  type        = bool
  default     = null
}

variable "domain_name_servers" {
  description = "List of DNS servers to use"
  type        = list(string)
  default     = []
}

variable "ntp_servers" {
  description = "List of NTP servers to use"
  type        = list(string)
  default     = []
}

variable "dhcp_options_domain_name" {
  description = "Domain name for DHCP options"
  type        = string
  default     = "" # Default domain name
}