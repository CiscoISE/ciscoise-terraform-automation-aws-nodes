
provider "aws" {
  region = var.aws_region
}

module "cisco_ise_ec2" {
  source            = "../../modules/ec2_modules"
  aws_region        = var.aws_region
  desired_size      = var.desired_size
  vpcid             = var.vpcid
  private_subnet1_a = var.private_subnet1_a
  private_subnet1_b = var.private_subnet1_b
  ise_version       = var.ise_version
  max_size          = var.max_size
  min_size          = var.min_size
  dns_domain        = var.dns_domain
  ise_instance_type = var.ise_instance_type
}