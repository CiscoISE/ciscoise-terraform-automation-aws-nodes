

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
    us-west-1 = {
      3.1 = {
        ami_id = "ami-0965fef2e601ad4d0"
      }
      3.2 = {
        ami_id = "ami-0768dd8e82836d887"
      }
    }
    us-west-2 = {
      3.1 = {
        ami_id = "ami-0ffd69a117dbcbb9e"
      }
      3.2 = {
        ami_id = "ami-0531d829a9e4d6b83"
      }
    }
    ca-central-1 = {
      3.1 = {
        ami_id = "ami-0715d661908b3c937"
      }
      3.2 = {
        ami_id = "ami-0d440428a5401cd3e"
      }
    }
    eu-central-1 = {
      3.1 = {
        ami_id = "ami-0526fe132f57b4dd5"
      }
      3.2 = {
        ami_id = "ami-0959760bb044c3247"
      }
    }
    eu-west-1 = {
      3.1 = {
        ami_id = "ami-0c0078c6bc939b794"
      }
      3.2 = {
        ami_id = "ami-0c3b9a181c1c91a3a"
      }
    }
    eu-west-2 = {
      3.1 = {
        ami_id = "ami-0a0e17dd5fa1643e9"
      }
      3.2 = {
        ami_id = "ami-00e0b109d715904ad"
      }
    }
    eu-west-3 = {
      3.1 = {
        ami_id = "ami-0f766d122c0b5c7b1"
      }
      3.2 = {
        ami_id = "ami-04dee19d63c2edb18"
      }
    }
    eu-north-1 = {
      3.1 = {
        ami_id = "ami-06d5092c5d2de909d"
      }
      3.2 = {
        ami_id = "ami-00e9fa9b6e9bcec20"
      }
    }
    eu-south-1 = {
      3.1 = {
        ami_id = "ami-0941a499217ec268e"
      }
      3.2 = {
        ami_id = "ami-060ed864daf36bcac"
      }
    }
    # Add other regions and versions...
  }
}

# Add other regions and versions here...
variable "aws_region" {
  description = "The AWS region where resources will be created."
  type        = string
  default     = "us-east-2" # Change this to your desired default region
}


variable "key_pair_name" {
  description = <<-EOT
    To access the Cisco ISE instance via SSH, choose the key pair that you created/imported in AWS.
    Create/import a key pair in AWS now if you have not configured one already.
    Usage example:  ssh -i mykeypair.pem admin@myhostname.compute-1.amazonaws.com.
    NOTE: The username for ISE 3.1 is "admin" and for ISE 3.2+ is "iseadmin".
  EOT  
  type        = string
  default = null
}

variable "ise_instance_type" {
  description = "Choose the required Cisco ISE instance type."
  type        = string
  default     = "c5.4xlarge"
  validation {
    condition     = contains(["c5.4xlarge", "m5.4xlarge", "c5.9xlarge", "t3.xlarge"], var.ise_instance_type)
    error_message = "The instance type should be one of the values in [c5.4xlarge, m5.4xlarge, c5.9xlarge, t3.xlarge]"
  }
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
  default     = 5
}

variable "min_size" {
  description = "Min Size for ISE Auto scaling group"
  default     = 2
}

variable "desired_size" {
  description = "Desired Size for ISE Auto scaling group"
}
# variable lb_private_address_subnet1 {
#   description = "Private IP Address of Load Balancer for Private Subnet-1"
#   type = string
# }

# variable lb_private_address_subnet2 {
#   description = "Private IP Address of Load Balancer for Private Subnet-2"
#   type = string
# }

variable "vpc_zone_identifier" {
  description = "List of subnet IDs to launch resources in. Subnets automatically determine which availability zones the group will reside"
  type = list(string)
}



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



