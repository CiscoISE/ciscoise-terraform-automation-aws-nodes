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
  description = "The ID of the created VPC"
  value       = aws_vpc.cisco_ise.id
}

output "public_subnet_ids" {
  description = "The IDs of the created public subnets"
  value       = aws_subnet.public_subnets[*].id
}

output "private_subnet_ids" {
  description = "The IDs of the created private subnets"
  value       = aws_subnet.private_subnets[*].id
}
output "internet_gateway_id" {
  description = "The ID of the created Internet Gateway"
  value       = aws_internet_gateway.cisco_ise_internet_gateway.id
}
output "dhcp_options_id" {
  description = "The ID of the created DHCP options"
  value       = aws_vpc_dhcp_options.cisco_ise_dhcp_options.id
}

output "nat_gateway_ids" {
  description = "The IDs of the created NAT Gateways"
  value       = aws_nat_gateway.cisco_ise_nat_gateways[*].id
}

output "nat_eip_ids" {
  description = "The Elastic IPs associated with the NAT Gateways"
  value       = aws_eip.cisco_ise_nat_ips[*].id
}
output "public_route_table_id" {
  description = "The ID of the public route table"
  value       = aws_route_table.public_subnet_route_table.id
}

output "private_route_table_ids" {
  description = "The IDs of the private route tables"
  value       = aws_route_table.private_subnet_route_tables[*].id
}

#output "s3_vpc_endpoint_id" {
#  description = "The ID of the created S3 VPC Endpoint"
#  value       = aws_vpc_endpoint.s3_endpoint.id
#}
