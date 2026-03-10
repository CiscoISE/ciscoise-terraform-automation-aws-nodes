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


module "cisco_ise" {
  source = "../../aws-vpc/modules/vpc_modules"

  vpc_cidr              = var.vpc_cidr
  vpc_name              = var.vpc_name
  availability_zones    = var.availability_zones
  public_subnet_cidrs   = var.public_subnet_cidrs
  private_subnet_cidrs  = var.private_subnet_cidrs
  internet_gateway_name = var.internet_gateway_name
  dhcp_domain_name      = var.dhcp_domain_name
  aws_region            = var.aws_region
  enable_dns_hostnames  = var.enable_dns_hostnames
}

