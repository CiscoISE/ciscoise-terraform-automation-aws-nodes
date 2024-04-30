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


provider "aws" {
  region = var.aws_region
}

data "aws_caller_identity" "current" {}

locals {
  trigger_lambda_time = replace(timeadd(timestamp(), "2m"), "Z", "")
  layer_arn           = "arn:aws:lambda:${var.aws_region}:${data.aws_caller_identity.current.account_id}:layer:CiscoISEPackageLayer:1"
}

module "cisco_ise_vpc" {
  source                = "git::ssh://git@github.com/CiscoISE/ciscoise-terraform-automation-aws-vpc.git//modules/vpc_modules"
  vpc_cidr              = var.vpc_cidr
  vpc_name              = var.vpc_name
  availability_zones    = var.availability_zones
  public_subnet_cidrs   = var.public_subnet_cidrs
  private_subnet_cidrs  = var.private_subnet_cidrs
  internet_gateway_name = var.internet_gateway_name
  aws_region            = var.aws_region
  enable_dns_hostnames  = var.enable_dns_hostnames
}

module "cisco_ise_ec2" {
  source                    = "../../modules/ec2_modules"
  aws_region                = var.aws_region
  vpcid                     = module.cisco_ise_vpc.vpc_id
  vpc_cidr                  = var.vpc_cidr
  private_subnet1_a         = module.cisco_ise_vpc.private_subnet_ids[0]
  private_subnet1_b         = module.cisco_ise_vpc.private_subnet_ids[1]
  subnet_id_list            = module.cisco_ise_vpc.private_subnet_ids
  dns_domain                = var.dns_domain
  primary_instance_config   = var.primary_instance_config
  secondary_instance_config = var.secondary_instance_config
  psn_instance_config       = var.psn_instance_config
  enable_stickiness         = var.enable_stickiness
  ise_version               = var.ise_version
  password                  = var.password
  key_pair_name             = var.key_pair_name
  ebs_encrypt               = var.ebs_encrypt
  time_zone                 = var.time_zone
  ers_api                   = var.ers_api
  open_api                  = var.open_api
  px_grid                   = var.px_grid
  px_grid_cloud             = var.px_grid_cloud
  primarynameserver         = var.primarynameserver
  ntpserver                 = var.ntpserver
}

##### step - lambda
module "PipLayerLambda" {
  source        = "../../modules/lambda_modules/PipLayerLambda"
  function_name = "PipLayerLambda"
  aws_region    = var.aws_region
}

module "TriggerLambdaSchedule" {
  source            = "../../modules/lambda_modules/IseScheduler"
  aws_region        = var.aws_region
  scheduler_name    = "LayerLambdaScheduler"
  step_function_arn = module.PipLayerLambda.lambda_function_arn
  schedule_time     = "at(${local.trigger_lambda_time})"
}

resource "time_sleep" "wait_8_minutes" {
  depends_on = [module.TriggerLambdaSchedule]

  create_duration = "500s"
}

module "CheckISEStatusLambda" {
  source             = "../../modules/lambda_modules/CheckISEStatusLambda"
  function_name      = "CheckISEStatusLambda"
  vpc_id             = module.cisco_ise_vpc.vpc_id
  subnet_ids         = [module.cisco_ise_vpc.private_subnet_ids[0]]
  security_group_ids = [module.cisco_ise_ec2.security_group_ids[0]]
  aws_region         = var.aws_region
  layer_arn          = local.layer_arn
  depends_on         = [time_sleep.wait_8_minutes]
}

module "SetPrimaryPANLambda" {
  source             = "../../modules/lambda_modules/SetPrimaryPANLambda"
  function_name      = "SetPrimaryPANLambda"
  subnet_ids         = [module.cisco_ise_vpc.private_subnet_ids[0]]
  security_group_ids = [module.cisco_ise_ec2.security_group_ids[0]]
  aws_region         = var.aws_region
  layer_arn          = local.layer_arn
  depends_on         = [time_sleep.wait_8_minutes]
}

module "RegisterSecondaryNodeLambda" {
  source             = "../../modules/lambda_modules/RegisterSecondaryNodeLambda"
  function_name      = "RegisterSecondaryNodeLambda"
  subnet_ids         = [module.cisco_ise_vpc.private_subnet_ids[0]]
  security_group_ids = [module.cisco_ise_ec2.security_group_ids[0]]
  aws_region         = var.aws_region
  layer_arn          = local.layer_arn
  depends_on         = [time_sleep.wait_8_minutes]
}

module "RegisterPSNNodesLambda" {
  source             = "../../modules/lambda_modules/RegisterPSNNodesLambda"
  function_name      = "RegisterPSNNodesLambda-ISE-Lambda"
  subnet_ids         = [module.cisco_ise_vpc.private_subnet_ids[0]]
  security_group_ids = [module.cisco_ise_ec2.security_group_ids[0]]
  aws_region         = var.aws_region
  layer_arn          = local.layer_arn
  depends_on         = [time_sleep.wait_8_minutes]
}

module "checkSyncStatusLambda" {
  source             = "../../modules/lambda_modules/checkSyncStatusLambda"
  function_name      = "CheckSyncStatusLambda"
  vpc_id             = module.cisco_ise_vpc.vpc_id
  subnet_ids         = [module.cisco_ise_vpc.private_subnet_ids[0]]
  security_group_ids = [module.cisco_ise_ec2.security_group_ids[0]]
  aws_region         = var.aws_region
  layer_arn          = local.layer_arn
  depends_on         = [time_sleep.wait_8_minutes]
}

module "StepFuntionExecution" {
  source                             = "../../modules/lambda_modules/StepFunction"
  aws_region                         = var.aws_region
  check_ise_status_lambda_arn        = module.CheckISEStatusLambda.lambda_function_arn
  set_primary_pan_lambda_arn         = module.SetPrimaryPANLambda.SetPrimaryPANlambda_function_arn
  register_secondary_node_lambda_arn = module.RegisterSecondaryNodeLambda.RegisterSecondaryNodelambda_function_arn
  register_psn_nodes_lambda_arn      = module.RegisterPSNNodesLambda.lambda_function_arn
  check_sync_status_lambda_arn       = module.checkSyncStatusLambda.lambda_function_arn
}

module "TriggerSchedule" {
  source            = "../../modules/lambda_modules/IseScheduler"
  aws_region        = var.aws_region
  scheduler_name    = "ise-scheduler"
  step_function_arn = module.StepFuntionExecution.step_function_arn
}