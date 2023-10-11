
provider "aws" {
  region = var.aws_region
}

data "aws_caller_identity" "current" {}

locals {
  trigger_time        = replace(timeadd(timestamp(), "50m"), "Z", "")
  trigger_lambda_time = replace(timeadd(timestamp(), "2m"), "Z", "")
  layer_arn           = "arn:aws:lambda:${var.aws_region}:${data.aws_caller_identity.current.account_id}:layer:CiscoISEPackageLayer:1"
}

module "cisco_ise_vpc" {
  source                = "git::ssh://git@github3.cisco.com/techops-operation/ise_launch_template-terraform-aws-vpc.git//modules/vpc_modules"
  vpc_cidr              = var.vpc_cidr
  vpc_name              = var.vpc_name
  availability_zones    = var.availability_zones
  public_subnet_cidrs   = var.public_subnet_cidrs
  private_subnet_cidrs  = var.private_subnet_cidrs
  internet_gateway_name = var.internet_gateway_name
  aws_region            = var.aws_region
}

module "cisco_ise_ec2" {
  source            = "../../modules/ec2_modules"
  aws_region        = var.aws_region
  vpcid             = module.cisco_ise_vpc.vpc_id
  vpc_cidr          = var.vpc_cidr
  private_subnet1_a = module.cisco_ise_vpc.private_subnet_ids[0]
  private_subnet1_b = module.cisco_ise_vpc.private_subnet_ids[1]
  private_subnet1_c = module.cisco_ise_vpc.private_subnet_ids[2]
  subnet_id_list    = module.cisco_ise_vpc.private_subnet_ids
  ise_instance_type = var.ise_instance_type
  dns_domain        = var.dns_domain
  psn_node_count    = var.psn_node_count
  ise_version       = var.ise_version
  password          = var.password
  key_pair_name     = var.key_pair_name
  ebs_encrypt       = var.ebs_encrypt
  storage_size      = var.storage_size
  time_zone         = var.time_zone
  ers_api           = var.ers_api
  open_api          = var.open_api
  px_grid           = var.px_grid
  px_grid_cloud     = var.px_grid_cloud

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

# resource "time_sleep" "wait_5_minutes" {
#   depends_on = [module.TriggerLambdaSchedule]

#   create_duration = "500s"
# }
# resource "time_sleep" "wait_7_minutes" {
#   depends_on = [module.TriggerLambdaSchedule]

#   create_duration = "500s"
# }
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
  # security_group_ids = ["sg-073a9133478431344"]
}

module "SetPrimaryPANLambda" {
  source             = "../../modules/lambda_modules/SetPrimaryPANLambda"
  function_name      = "SetPrimaryPANLambda"
  subnet_ids         = [module.cisco_ise_vpc.private_subnet_ids[0]]
  security_group_ids = [module.cisco_ise_ec2.security_group_ids[0]]
  aws_region         = var.aws_region
  layer_arn          = local.layer_arn
  depends_on         = [time_sleep.wait_8_minutes]
  # security_group_ids = ["sg-073a9133478431344"]
}

module "RegisterSecondaryNodeLambda" {
  source             = "../../modules/lambda_modules/RegisterSecondaryNodeLambda"
  function_name      = "RegisterSecondaryNodeLambda"
  subnet_ids         = [module.cisco_ise_vpc.private_subnet_ids[0]]
  security_group_ids = [module.cisco_ise_ec2.security_group_ids[0]]
  aws_region         = var.aws_region
  layer_arn          = local.layer_arn
  depends_on         = [time_sleep.wait_8_minutes]
  # security_group_ids = ["sg-073a9133478431344"]
}

module "RegisterPSNNodesLambda" {
  source             = "../../modules/lambda_modules/RegisterPSNNodesLambda"
  function_name      = "RegisterPSNNodesLambda-ISE-Lambda"
  subnet_ids         = [module.cisco_ise_vpc.private_subnet_ids[0]]
  security_group_ids = [module.cisco_ise_ec2.security_group_ids[0]]
  aws_region         = var.aws_region
  layer_arn          = local.layer_arn
  depends_on         = [time_sleep.wait_8_minutes]
  # security_group_ids = ["sg-073a9133478431344"]
}

module "StepFuntionExecution" {
  source                             = "../../modules/lambda_modules/StepFunction"
  aws_region                         = var.aws_region
  check_ise_status_lambda_arn        = module.CheckISEStatusLambda.lambda_function_arn
  set_primary_pan_lambda_arn         = module.SetPrimaryPANLambda.SetPrimaryPANlambda_function_arn
  register_secondary_node_lambda_arn = module.RegisterSecondaryNodeLambda.RegisterSecondaryNodelambda_function_arn
  register_psn_nodes_lambda_arn      = module.RegisterPSNNodesLambda.lambda_function_arn
}

module "TriggerSchedule" {
  source            = "../../modules/lambda_modules/IseScheduler"
  aws_region        = var.aws_region
  scheduler_name    = "ise-scheduler"
  step_function_arn = module.StepFuntionExecution.step_function_arn
  schedule_time     = "at(${local.trigger_time})"
}