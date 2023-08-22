
provider "aws" {
  region = var.aws_region
}


module "cisco_ise_vpc" {
  source = "git::ssh://git@github3.cisco.com/techops-operation/ise_launch_template-terraform-aws-vpc.git//modules/vpc_modules"
  vpc_cidr              = var.vpc_cidr
  vpc_name              = var.vpc_name
  availability_zones    = var.availability_zones
  public_subnet_cidrs   = var.public_subnet_cidrs
  private_subnet_cidrs  = var.private_subnet_cidrs
  internet_gateway_name = var.internet_gateway_name
  dhcp_domain_name      = var.dhcp_domain_name
  aws_region            = var.aws_region
}

module "cisco_ise_ec2" {
  source              = "../../modules/ec2_modules"
  aws_region          = var.aws_region
  desired_size        = 3
  vpcid               = module.cisco_ise_vpc.vpc_id
  private_subnet1_a   = module.cisco_ise_vpc.private_subnet_ids[0]
  private_subnet1_b   = module.cisco_ise_vpc.private_subnet_ids[1]
  vpc_zone_identifier = slice(module.cisco_ise_vpc.private_subnet_ids, 0, 2)
  ise_instance_type   = var.ise_instance_type
  dns_domain          = var.dns_domain
}