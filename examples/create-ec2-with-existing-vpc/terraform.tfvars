################################################
### Block to Update VPC Details ################
### Please Update Existing VPC Details Below ###
################################################
vpc_cidr           = "10.0.0.0/16"                # CIDR block for the VPC
vpc_id             = "vpc-0a64028e2d072c29b"      # VPC ID
vpc_name           = "cisco_ise"                  # Name tag for the VPC
aws_region         = "us-east-1"                  # Specify the AWS region
availability_zones = ["us-east-1a", "us-east-1b"] # List of  availability zones

######################################
### Block to Update Subnet Details ###
######################################
public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24"]                           # List of CIDR blocks for public subnets
private_subnet_cidrs = ["10.0.11.0/24", "10.0.12.0/24"]                         # List of CIDR blocks for private subnets
subnet_id_list       = ["subnet-0b5a68382f34e14f2", "subnet-0334025fc3cdafb31"] # List of private subnet IDs to launch resources in

internet_gateway_name = "Cisco_ISE_IGW" # Name tag for the Internet Gateway

###################################
### Block to Update EC2 Details ###
###################################
#Valid instance types are c5.4xlarge, m5.4xlarge, c5.9xlarge, t3.xlarge
primary_instance_type = "t3.xlarge" # Choose the required primary/Secondary node instance type
psn_instance_type     = "t3.xlarge" # Choose the required instance type for PSN nodes

### Based of below input, it will launch N number of PSN Nodes ###
psn_node_count = 5 # Specify the number of PSN nodes

### User needs to create a keypair and pass the key pair name
key_pair_name = "ise-test-nv" # Name of the key pair for SSH access

###Storage Details###
ebs_encrypt          = false # Choose true to enable EBS encryption
primary_storage_size = "600" # Storage in GB for primary/secondary nodes
psn_storage_size     = "600" # Storage in GB for PSN nodes

# Application Details
ise_version   = "3.1"        # The version of Cisco ISE (3.1 or 3.2)
password      = "C!sc0Ind1@" # The password for the Cisco ISE GUI
time_zone     = "UTC"        # Enter a timezone
ers_api       = "yes"        # Enable/disable ERS
open_api      = "yes"        # Enable/disable OpenAPI
px_grid       = "yes"        # Enable/disable pxGrid
px_grid_cloud = "yes"        # Enable/disable pxGrid Cloud

# DNS Domain Name
dns_domain = "drilldevops.in" # Enter a domain name in correct syntax
