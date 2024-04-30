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

output "launch_template_id" {
  description = "ID of the created launch template."
  value       = aws_launch_template.ise_launch_template[*]
}

output "nlb_dns_name" {
  description = "DNS name of the Network Load Balancer."
  value       = aws_lb.psn_nlb.dns_name
}

output "security_group_ids" {
  description = "security group id"
  value       = aws_security_group.ise-sg[*].id
}

output "primary_instance_id" {
  description = "Instance id of the primary ISE node"
  value       = join("", [for key in keys(var.primary_instance_config) : aws_instance.primary_ise_server[key].id])
}

output "secondary_instance_id" {
  description = "Instance id of the secondary ISE node"
  value       = join("", [for key in keys(var.secondary_instance_config) : aws_instance.secondary_ise_server[key].id])
}

output "psn_instance_id" {
  description = "Instance id of the PSN ISE nodes"
  value       = [for key in keys(var.psn_instance_config) : aws_instance.PSN_node[key].id]
}

output "primary_private_ip" {
  description = "Private IP address of primary ISE node"
  value       = join("", [for key in keys(var.primary_instance_config) : aws_instance.primary_ise_server[key].private_ip])
}

output "secondary_private_ip" {
  description = "Private IP address of Secondary ISE node"
  value       = join("", [for key in keys(var.secondary_instance_config) : aws_instance.secondary_ise_server[key].private_ip])
}

output "psn_private_ip" {
  description = "Private IP address of PSN ISE nodes"
  value       = [for key in keys(var.psn_instance_config) : aws_instance.PSN_node[key].private_ip]
}

output "primary_dns_name" {
  description = "Private DNSName of the primary ISE node"
  value       = aws_route53_record.ise_node_dns_record[local.ise_hostnames_list[0]].name
}

output "secondary_dns_name" {
  description = "Private DNSName of the primary ISE node"
  value       = aws_route53_record.ise_node_dns_record[local.ise_hostnames_list[1]].name
}

output "psn_dns_name" {
  description = "Private DNSName of the PSN ISE nodes"
  value       = [for name in slice(local.ise_hostnames_list, 2, length(local.ise_hostnames_list)) : aws_route53_record.ise_node_dns_record[name].name]
}