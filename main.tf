# main.tf

provider "aws" {
  region = "us-east-1"
}



data "terraform_remote_state" "vpc" {
  backend = "s3"
  config = {
    bucket         = "ise-terraform-test"
    key            = "terraform/vpc/vpc.tfstate" # Path to Project A's state file
    region         = "us-east-2" # Use the same region as Project A
    encrypt        = true
    /* dynamodb_table = "terraform-state-lock" # Optional if Project A uses DynamoDB for locking */
  }
}


module "ise_module" {
  source      =  "./modules/ec2_modules"  # Path to your module directory
  aws_region  = "us-east-2"
  vpc_zone_identifier = ["subnet-0fa1f598657758fe9", "subnet-06fdb76986a3844f0"]  # Example values, provide the correct subnet IDs
  private_subnet1_a   = data.terraform_remote_state.vpc.outputs.private_subnet_ids[0]  # Provide the correct subnet ID
  private_subnet1_b   = data.terraform_remote_state.vpc.outputs.private_subnet_ids[1]  # Provide the correct subnet ID
  vpcid               = data.terraform_remote_state.vpc.outputs.vpc_id      # Provide the correct VPC ID
  desired_size        = 3                   # Provide the desired size



  # Assign other variable values specific to your deployment...
}


# Define other resources or configurations here...
