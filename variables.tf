

variable "ami_ids" {
  description = "Map of AMI IDs for each region and ISE version"
  type        = map(map(map(string)))
  default = {
    us-east-1 = {
      3.1 = {
        ami_id = "ami-0bb0a9d243824a077"
      }
      3.2 = {
        ami_id = "ami-08c545c5ef3cacced"
      }
    }
    us-east-2 = {
      3.1 = {
        ami_id = "ami-0262130ee7b27f122"
      }
      3.2 = {
        ami_id = "ami-068b6e34ad1266819"
      }
    }
    # Add other regions and versions...
  }
}

# Add other regions and versions here...
variable "aws_region" {
  description = "The AWS region where resources will be created."
  type        = string
  default     = "us-east-1" # Change this to your desired default region
}


variable "key_pair_name" {
  description = <<-EOT
    To access the Cisco ISE instance via SSH, choose the key pair that you created/imported in AWS.
    Create/import a key pair in AWS now if you have not configured one already.
    Usage example:  ssh -i mykeypair.pem admin@myhostname.compute-1.amazonaws.com.
    NOTE: The username for ISE 3.1 is "admin" and for ISE 3.2+ is "iseadmin".
  EOT  
  type        = string
}

variable "ise_instance_type" {
  description = "Choose the required Cisco ISE instance type."
  type        = string
  default     = "c5.4xlarge"
}

variable "ise_version" {
  description = "The version of Cisco ISE (3.1 or 3.2)"
  type        = string
  default     = "3.1"
}

variable "private_subnet1_a" {
  description = "ID of the subnet to be used for the ISE deployment  in an Availability Zone A."
  type        = string
}

variable "private_subnet1_b" {
  description = "ID of the subnet to be used for the ISE deployment  in an Availability Zone B."
  type        = string
}

variable "storage_size" {
  description = "Specify the storage in GB (Minimum 300GB and Maximum 2400GB). 600GB is recommended for production use, storage lesser than 600GB can be used for evaluation purpose only. On terminating the instance, volume will be deleted as well."
  type        = string
  default     = "600"
}

variable "vpcid" {
  description = "ID of the VPC (e.g., vpc-0343606e)"
  type        = string
}

variable "vpccidr" {
  description = "CIDR block for the VPC."
  type        = string
  default     = "10.0.0.0/16"
}

variable "max_size" {
  description = "Max Size for ISE Auto scaling group"
}

variable "min_size" {
  description = "Min Size for ISE Auto scaling group"
  default     = 2
}

variable "desired_size" {
  description = "Desired Size for ISE Auto scaling group"
  default     = 2
}
# variable lb_private_address_subnet1 {
#   description = "Private IP Address of Load Balancer for Private Subnet-1"
#   type = string
# }

# variable lb_private_address_subnet2 {
#   description = "Private IP Address of Load Balancer for Private Subnet-2"
#   type = string
# }




variable "is_ise_32_condition" {
  type    = bool
  default = true # Set to true or false based on your condition
}

variable "node1_hostname" {
  type    = string
  default = "ise-node1.example.com" # Set to the appropriate hostname for Node 1
}

variable "node2_hostname" {
  type    = string
  default = "ise-node2.example.com" # Set to the appropriate hostname for Node 2
}

variable "dns_domain" {
  type    = string
  default = "example.com" # Set to the appropriate DNS domain
}

variable "password" {
  type    = string
  default = "your_password" # Set to the appropriate password
}

variable "time_zone" {
  type    = string
  default = "UTC" # Set to the appropriate timezone
}

variable "ers_api" {
  type    = string
  default = "ers_api_value" # Set to the appropriate ERS API value
}

variable "open_api" {
  type    = string
  default = "open_api_value" # Set to the appropriate Open API value
}

variable "px_grid" {
  type    = string
  default = "px_grid_value" # Set to the appropriate PX Grid value
}

variable "px_grid_cloud" {
  type    = string
  default = "px_grid_cloud_value" # Set to the appropriate PX Grid Cloud value
}



