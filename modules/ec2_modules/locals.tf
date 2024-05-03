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

locals {
  ise_username_map     = { 3.1 = "admin", 3.2 = "iseadmin",3.3 = "iseadmin"}
  roles                = flatten(concat([for vm in values(var.secondary_instance_config) : split(",", vm.roles)], [for vm in values(var.psn_instance_config) : split(",", vm.roles)]))
  ise_nodes_list       = concat([for key in keys(var.primary_instance_config) : aws_instance.primary_ise_server[key].id], [for key in keys(var.secondary_instance_config) : aws_instance.secondary_ise_server[key].id], [for key in keys(var.psn_instance_config) : aws_instance.PSN_node[key].id])
  ise_hostnames_list   = concat([for key in keys(var.primary_instance_config) : key], [for key in keys(var.secondary_instance_config) : key], [for key in keys(var.psn_instance_config) : key])
  ise_private_ip_list  = concat([for key in keys(var.primary_instance_config) : aws_instance.primary_ise_server[key].private_ip], [for key in keys(var.secondary_instance_config) : aws_instance.secondary_ise_server[key].private_ip], [for key in keys(var.psn_instance_config) : aws_instance.PSN_node[key].private_ip])
  ise_ssm_pan_fqdn_map = merge({ Primary_FQDN = "${local.ise_hostnames_list[0]}.${var.dns_domain}", Secondary_FQDN = "${local.ise_hostnames_list[1]}.${var.dns_domain}" })
  ise_ssm_pan_ip_map   = merge({ Primary_IP = local.ise_private_ip_list[0], Secondary_IP = local.ise_private_ip_list[1] })
  ise_ssm_psn_fqdn_map = { for hostname in slice(local.ise_hostnames_list, 2, length(local.ise_hostnames_list)) : "${hostname}_FQDN" => "${hostname}.${var.dns_domain}" }
  ise_ssm_psn_ip_map   = { for hostname, ip in zipmap(slice(local.ise_hostnames_list, 2, length(local.ise_hostnames_list)), slice(local.ise_private_ip_list, 2, length(local.ise_private_ip_list))) : "${hostname}_IP" => ip }
  ise_ssm_pan_map      = merge({ SyncStatus = "INITIAL", Maintenance = "DISABLED", ADMIN_USERNAME = local.ise_username }, local.ise_ssm_pan_fqdn_map, local.ise_ssm_pan_ip_map)
}