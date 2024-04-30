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


resource "aws_ssm_parameter" "ise_password" {
  name  = "ADMIN_PASSWORD"
  type  = "SecureString"
  value = var.password
}

resource "aws_ssm_parameter" "ise_pan_ssm" {
  for_each = local.ise_ssm_pan_map
  name     = each.key
  type     = "String"
  value    = each.value
}

resource "aws_ssm_parameter" "ise_psn_fqdn" {
  for_each = local.ise_ssm_psn_fqdn_map
  name     = each.key
  type     = "String"
  value    = each.value

  tags = {
    type = "psn_fqdn"
  }
}

resource "aws_ssm_parameter" "ise_psn_ip" {
  for_each = local.ise_ssm_psn_ip_map
  name     = each.key
  type     = "String"
  value    = each.value

  tags = {
    type = "psn_ip"
  }
}

resource "aws_ssm_parameter" "retry_count" {
  name  = "RETRY_COUNT"
  type  = "String"
  value = "0"
}

resource "aws_ssm_parameter" "psn_retry_count" {
  name  = "PSN_RETRY_COUNT"
  type  = "String"
  value = "0"
}

resource "aws_ssm_parameter" "psn_fqdn_list" {
  name  = "psn_fqdn_list"
  type  = "String"
  value = "{}"
}

resource "aws_ssm_parameter" "psn_roles_list" {
  name  = "psn_roles_list"
  type  = "String"
  value = "{}"
}

resource "aws_ssm_parameter" "psn_services_list" {
  name  = "psn_services_list"
  type  = "String"
  value = "{}"
}

resource "aws_ssm_parameter" "secondary_node_roles" {
  for_each = var.secondary_instance_config
  name     = "secondary_node_roles"
  type     = "StringList"
  value    = each.value.roles
}

resource "aws_ssm_parameter" "secondary_node_services" {
  for_each = var.secondary_instance_config
  name     = "secondary_node_services"
  type     = "StringList"
  value    = each.value.services
}

resource "aws_ssm_parameter" "psn_node_roles" {
  for_each = var.psn_instance_config
  name     = "${each.key}_roles"
  type     = "StringList"
  value    = each.value.roles
  tags = {
    type = "psn_roles"
  }
}

resource "aws_ssm_parameter" "psn_node_services" {
  for_each = var.psn_instance_config
  name     = "${each.key}_services"
  type     = "StringList"
  value    = each.value.services
  tags = {
    type = "psn_services"
  }
}



