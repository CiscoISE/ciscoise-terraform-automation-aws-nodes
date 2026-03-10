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

output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.cisco_ise.vpc_id
}

output "internet_gateway_id" {
  description = "The ID of the Internet Gateway"
  value       = module.cisco_ise.internet_gateway_id
}

output "public_subnet_ids" {
  description = "The IDs of the public subnets"
  value       = module.cisco_ise.public_subnet_ids
}

output "private_subnet_ids" {
  description = "The IDs of the private subnets"
  value       = module.cisco_ise.private_subnet_ids
}

output "nat_gateway_ids" {
  description = "The IDs of the NAT Gateways"
  value       = module.cisco_ise.nat_gateway_ids
}

output "nat_eip_ids" {
  description = "The IDs of the NAT Elastic IPs"
  value       = module.cisco_ise.nat_eip_ids
}

output "dhcp_options_id" {
  description = "The ID of the DHCP Options"
  value       = module.cisco_ise.dhcp_options_id
}


output "public_route_table_id" {
  description = "The ID of the public subnet route table"
  value       = module.cisco_ise.public_route_table_id
}

output "private_route_table_ids" {
  description = "The IDs of the private subnet route tables"
  value       = module.cisco_ise.private_route_table_ids
}