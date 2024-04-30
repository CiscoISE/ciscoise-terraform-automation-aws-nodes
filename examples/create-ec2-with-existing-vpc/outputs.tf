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

output "primary_instance_id" {
  description = "Instance id of the primary ISE node"
  value       = module.cisco_ise_ec2.primary_instance_id
}

output "secondary_instance_id" {
  description = "Instance id of the secondary ISE node"
  value       = module.cisco_ise_ec2.secondary_instance_id
}

output "psn_instance_id" {
  description = "Instance id of the PSN ISE nodes"
  value       = module.cisco_ise_ec2.psn_instance_id
}

output "primary_private_ip" {
  description = "Private IP address of primary ISE node"
  value       = module.cisco_ise_ec2.primary_private_ip
}

output "secondary_private_ip" {
  description = "Private IP address of Secondary ISE node"
  value       = module.cisco_ise_ec2.secondary_private_ip
}

output "psn_private_ip" {
  description = "Private IP address of PSN ISE nodes"
  value       = module.cisco_ise_ec2.psn_private_ip
}

output "primary_dns_name" {
  description = "Private DNSName of the primary ISE node"
  value       = module.cisco_ise_ec2.primary_dns_name
}

output "secondary_dns_name" {
  description = "Private DNSName of the primary ISE node"
  value       = module.cisco_ise_ec2.secondary_dns_name
}

output "psn_dns_name" {
  description = "Private DNSName of the PSN ISE nodes"
  value       = module.cisco_ise_ec2.psn_dns_name
}