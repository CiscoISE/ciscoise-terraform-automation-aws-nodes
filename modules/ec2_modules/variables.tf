

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

variable "ise_version" {
  description = "The version of Cisco ISE (3.1 or 3.2)"
  type        = string
}

variable "primary_instance_config" {
  description = <<-EOT
  Specify the configuration for primary pan instance. It should follow below format where key is the hostname and values are instance attributes
  {
    <hostname> = {
      instance_type = "<instance_type>"
      storage_size = "<storage_size>"
    }
  }
  Example usage - 
  {
  primary-ise-server = { 
      instance_type = "t3.xlarge"
      storage_size = 500
    }
  }
  EOT
  type = map(object({
    instance_type = string
    storage_size  = number
  }))

  validation {
    condition     = contains(["t3.xlarge", "m5.2xlarge", "c5.4xlarge", "m5.4xlarge", "c5.9xlarge", "m5.8xlarge", "m5.16xlarge"], join("", [for val in var.primary_instance_config : val.instance_type]))
    error_message = "Supported instance type for Cisco ISE nodes are t3.xlarge, m5.2xlarge, c5.4xlarge, m5.4xlarge, c5.9xlarge, m5.8xlarge, m5.16xlarge]"
  }
}

variable "secondary_instance_config" {
  description = <<-EOT
  Specify the configuration for secondary pan instance. It should follow below format where key is the hostname and values are instance attributes.
  {
    <hostname> = {
      instance_type = "<instance_type>"
      storage_size = "<storage_size>"
      services =  "<service_1>,<service_2>"
      roles = "<role_1>,<role_2>"
    }
  }
  Example usage -
  {
  secondary-ise-server = { 
      instance_type = "t3.xlarge"
      storage_size = 500
      services = "Session,Profiler,pxGrid"
      roles = "SecondaryAdmin"
    }
  }
  EOT
  type = map(object({
    instance_type = string
    storage_size  = number
    services      = optional(string, " ")
    roles         = optional(string, "SecondaryAdmin")
  }))

  validation {
    condition     = contains(["t3.xlarge", "m5.2xlarge", "c5.4xlarge", "m5.4xlarge", "c5.9xlarge", "m5.8xlarge", "m5.16xlarge"], join("", [for sec in var.secondary_instance_config : sec.instance_type]))
    error_message = "Supported instance type for Cisco ISE nodes are t3.xlarge, m5.2xlarge, c5.4xlarge, m5.4xlarge, c5.9xlarge, m5.8xlarge, m5.16xlarge"
  }

  validation {
    condition = length(flatten([for vm in values(var.secondary_instance_config) :
      [for service in split(",", vm.services) :
        service if service != "Session" && service != "Profiler" && service != "TC-NAC" &&
        service != "SXP" && service != "DeviceAdmin" && service != "PassiveIdentity" &&
    service != "pxGrid" && service != "pxGridCloud"]])) == 0
    error_message = "Services for secondary node can only accept values from Session, Profiler, TC-NAC, SXP, DeviceAdmin, PassiveIdentity, pxGrid, pxGridCloud."
  }

  validation {
    condition     = length(flatten([for vm in values(var.secondary_instance_config) : [for role in split(",", vm.roles) : role if role != "SecondaryAdmin" && role != "SecondaryMonitoring" && role != "PrimaryMonitoring"]])) == 0
    error_message = "For secondary pan node, roles can only accept SecondaryAdmin, SecondaryMonitoring and PrimaryMonitoring values"
  }
}

variable "psn_instance_config" {
  description = <<-EOT
  Specify the configuration for PSN nodes. It should follow below format where key is the hostname and values are instance attributes.
  {
    <hostname> = {
      instance_type = "<instance_type>"
      storage_size = "<storage_size>"
      services =  "<service_1>,<service_2>"
      roles = "<role_1>,<role_2>"
    }
  }
   Example usage - 
  {
    secmonitoring-server = {
      instance_type = "t3.xlarge"
      storage_size  = 500
      roles = "SecondaryMonitoring"
    }
    psn-ise-server-2 = {
      instance_type = "t3.xlarge"
      storage_size  = 600
      services      = "Session,Profiler,PassiveIdentity"
    }
  }
    EOT
  type = map(object({
    instance_type = string
    storage_size  = number
    services      = optional(string, " ")
    roles         = optional(string, " ")
  }))

  validation {
    condition     = alltrue(flatten([for psn in var.psn_instance_config : contains(["t3.xlarge", "m5.2xlarge", "c5.4xlarge", "m5.4xlarge", "c5.9xlarge", "m5.8xlarge", "m5.16xlarge"], psn.instance_type)]))
    error_message = "Supported instance type for Cisco ISE nodes are t3.xlarge, m5.2xlarge, c5.4xlarge, m5.4xlarge, c5.9xlarge, m5.8xlarge, m5.16xlarge"
  }

  validation {
    condition     = length([for vm in values(var.psn_instance_config) : vm if vm.roles == " " && vm.services == " "]) == 0
    error_message = "PSN node should contain one of the role or service"
  }

  validation {
    condition = length(flatten([for vm in values(var.psn_instance_config) :
      [for service in split(",", vm.services) :
        service if service != "Session" && service != "Profiler" && service != "TC-NAC" &&
        service != "SXP" && service != "DeviceAdmin" && service != "PassiveIdentity" &&
    service != "pxGrid" && service != "pxGridCloud" && service != " "]])) == 0
    error_message = "Services for PSN nodes can only accept values from Session, Profiler, TC-NAC, SXP, DeviceAdmin, PassiveIdentity, pxGrid, pxGridCloud."
  }

  validation {
    condition     = length([for vm in values(var.psn_instance_config) : vm.roles if vm.roles != null && (vm.roles != "SecondaryMonitoring" && vm.roles != "SecondaryDedicatedMonitoring" && vm.roles != "PrimaryDedicatedMonitoring" && vm.roles != "PrimaryMonitoring" && vm.roles != " ")]) == 0
    error_message = "For PSN nodes, roles can only accept one of these values - SecondaryMonitoring, SecondaryDedicatedMonitoring, PrimaryMonitoring, PrimaryDedicatedMonitoring"
  }
}

variable "ebs_encrypt" {
  description = "Choose true to enable EBS encryption"
}

variable "enable_stickiness" {
  description = "Choose true or false to enable/disable stickiness for the load balancer"
  type        = bool
}

variable "private_subnet1_a" {
  description = "ID of the subnet to be used for the ISE deployment in an Availability Zone A."
  type        = string
}

variable "private_subnet1_b" {
  description = "ID of the subnet to be used for the ISE deployment in an Availability Zone B."
  type        = string
}

variable "vpcid" {
  description = "ID of the VPC (e.g., vpc-0343606e)"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC."
  type        = string
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
  default     = 3
}

variable "lb_private_address_subnet1" {
  description = "Private IP Address of Load Balancer for Private Subnet-1"
  type        = string
  default     = null
}

variable "lb_private_address_subnet2" {
  description = "Private IP Address of Load Balancer for Private Subnet-2"
  type        = string
  default     = null
}

variable "lb_private_address_subnet3" {
  description = "Private IP Address of Load Balancer for Private Subnet-3"
  type        = string
  default     = null
}

variable "subnet_id_list" {
  description = "List of subnet IDs to launch resources in."
  type        = list(string)
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
  default = "aisndmoVLa3@" # Set to the appropriate password
}

variable "time_zone" {
  type    = string
  default = "UTC" # Set to the appropriate timezone
}

variable "ers_api" {
  type    = string
  default = "yes" # Set to the appropriate ERS API value
}

variable "open_api" {
  type    = string
  default = "yes" # Set to the appropriate Open API value
}

variable "px_grid" {
  type    = string
  default = "yes" # Set to the appropriate PX Grid value
}

variable "px_grid_cloud" {
  type    = string
  default = "yes" # Set to the appropriate PX Grid Cloud value
}

variable "primarynameserver" {
  type = string
}

variable "ntpserver" {
  type = string
}