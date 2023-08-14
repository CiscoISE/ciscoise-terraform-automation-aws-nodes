variable "ISEVersion" {
  description = "The version of Cisco ISE (3.1 or 3.2)"
  type        = string
}

variable "ami_ids" {
  description = "Map of AMI IDs for each region and ISE version"
  type        = map(map(string))
  default = {
    "us-east-1" = {
      "3.1" = "ami-0bb0a9d243824a077"
      "3.2" = "ami-08c545c5ef3cacced"
    }
    "us-east-2" = {
      "3.1" = "ami-0262130ee7b27f122"
      "3.2" = "ami-068b6e34ad1266819"
    }
    us-west-1 = {
        3.1 = "ami-0965fef2e601ad4d0"
        3.2 = "ami-0768dd8e82836d887"
      }
      us-west-2 = {
        3.1 = "ami-0ffd69a117dbcbb9e"
        3.2 = "ami-0531d829a9e4d6b83"
      }
      ca-central-1 = {
        3.1 = "ami-0715d661908b3c937"
        3.2 = "ami-0d440428a5401cd3e"
      }
      eu-central-1 = {
        3.1 = "ami-0526fe132f57b4dd5"
        3.2 = "ami-0959760bb044c3247"
      }
      eu-west-1 = {
        3.1 = "ami-0c0078c6bc939b794"
        3.2 = "ami-0c3b9a181c1c91a3a"
      }
      eu-west-2 = {
        3.1 = "ami-0a0e17dd5fa1643e9"
        3.2 = "ami-00e0b109d715904ad"
      }
      eu-west-3 = {
        3.1 = "ami-0f766d122c0b5c7b1"
        3.2 = "ami-04dee19d63c2edb18"
      }
      eu-north-1 = {
        3.1 = "ami-06d5092c5d2de909d"
        3.2 = "ami-00e9fa9b6e9bcec20"
      }
      eu-south-1 = {
        3.1 = "ami-0941a499217ec268e"
        3.2 = "ami-060ed864daf36bcac"
      }
      eu-south-2 = {
        3.1 = "ami-006a07d274fcaffac"
        3.2 = "ami-0b433a7587fea7e41"
      }
      ap-southeast-1 = {
        3.1 = "ami-0214a475ff692424f"
        3.2 = "ami-02bb8125b423c29dc"
      }
      ap-southeast-2 = {
        3.1 = "ami-0f1846c9d911d1727"
        3.2 = "ami-0f238188265b7f80b"
      }
      ap-southeast-3 = {
        3.1 = "ami-0a824feea34fe65fb"
        3.2 = "ami-0da7b907b79029925"
      }
      ap-southeast-4 = {
        3.1 = "ami-06a6a3b37cf23c6e7"
        3.2 = "ami-0ea8a008eea59002f"
      }
      ap-south-1 = {
        3.1 = "ami-0add11be4e3a2b72e"
        3.2 = "ami-05ef3254c75ce4053"
      }
      ap-south-2 = {
        3.1 = "ami-09896c9d9eeed3138"
        3.2 = "ami-0448864ec746d003a"
      }
      ap-northeast-1 = {
        3.1 = "ami-0da69493a00c3ebb1"
        3.2 = "ami-07a8db1bcd9d807a7"
      }
      ap-northeast-2 = {
        3.1 = "ami-0a56667a39f884c9e"
        3.2 = "ami-032bcdac0d576df35"
      }
      ap-east-1 = {
        3.1 = "ami-0118aa54aed56f415"
        3.2 = "ami-0e401f651fbb61c1d"
      }
      me-south-1 = {
        3.1 = "ami-0a2f4b9a138b52221"
        3.2 = "ami-0c8012fd684bdfbb5"
      }
      ap-northeast-3 = {
        3.1 = "ami-05d2412cb877a373f"
        3.2 = "ami-0d6ab22fd8ac904a3"
      }
      sa-east-1 = {
        3.1 = "ami-0feeceb6d1a0dd691"
        3.2 = "ami-0c1b6e1fb53940d10"
      }
      us-gov-west-1 = {
        3.1 = "ami-0692c2574536577a7"
        3.2 = "ami-0245b2414c12ac588"
      }
      us-gov-east-1 = {
        3.1 = "ami-0cf29ff16a189964b"
        3.2 = "ami-03594105967b59456"
      }
      af-south-1 = {
        3.1 = "ami-003d33a44238d468e"
        3.2 = "ami-08164edf9ea98e66e"
      }
      me-central-1 = {
        3.1 = "ami-023f6853b95edc0d7"
        3.2 = "ami-0889e9152037cb637"
      }
  }
}






variable key_pair_name {
  description = "To access the Cisco ISE instance via SSH, choose the key pair that you created/imported in AWS. Create/import a key pair in AWS now if you have not configured one already. Usage example:  ssh -i mykeypair.pem admin@myhostname.compute-1.amazonaws.com. NOTE: The username for ISE 3.1 is "admin" and for ISE 3.2+ is "iseadmin"."
  type = string
}

variable ise_instance_type {
  description = "Choose the required Cisco ISE instance type."
  type = string
  default = "c5.4xlarge"
}

variable ise_version {
  description = "The ISE software version to be used for the ISE instances."
  type = string
  default = "3.1"
}

variable private_subnet1_a {
  description = "ID of the subnet to be used for the ISE deployment  in an Availability Zone A."
  type = string
}

variable private_subnet1_b {
  description = "ID of the subnet to be used for the ISE deployment  in an Availability Zone B."
  type = string
}

variable storage_size {
  description = "Specify the storage in GB (Minimum 300GB and Maximum 2400GB). 600GB is recommended for production use, storage lesser than 600GB can be used for evaluation purpose only. On terminating the instance, volume will be deleted as well."
  type = string
  default = "600"
}

variable vpcid {
  description = "ID of the VPC (e.g., vpc-0343606e)"
  type = string
}

variable vpccidr {
  description = "CIDR block for the VPC."
  type = string
  default = "10.0.0.0/16"
}

variable lb_private_address_subnet1 {
  description = "Private IP Address of Load Balancer for Private Subnet-1"
  type = string
}

variable lb_private_address_subnet2 {
  description = "Private IP Address of Load Balancer for Private Subnet-2"
  type = string
}




variable "is_ise_32_condition" {
  type    = bool
  default = true  # Set to true or false based on your condition
}

variable "node1_hostname" {
  type    = string
  default = "ise-node1.example.com"  # Set to the appropriate hostname for Node 1
}

variable "node2_hostname" {
  type    = string
  default = "ise-node2.example.com"  # Set to the appropriate hostname for Node 2
}

variable "dns_domain" {
  type    = string
  default = "example.com"  # Set to the appropriate DNS domain
}

variable "password" {
  type    = string
  default = "your_password"  # Set to the appropriate password
}

variable "time_zone" {
  type    = string
  default = "UTC"  # Set to the appropriate timezone
}

variable "ers_api" {
  type    = string
  default = "ers_api_value"  # Set to the appropriate ERS API value
}

variable "open_api" {
  type    = string
  default = "open_api_value"  # Set to the appropriate Open API value
}

variable "px_grid" {
  type    = string
  default = "px_grid_value"  # Set to the appropriate PX Grid value
}

variable "px_grid_cloud" {
  type    = string
  default = "px_grid_cloud_value"  # Set to the appropriate PX Grid Cloud value
}


variable "KeyPairName" {}
variable "ISEInstanceType" {}
variable "ISEVersion" {}
variable "StorageSize" {}
variable "PrivateSubnet1A" {}
variable "PrivateSubnet1B" {}
variable "VPCID" {}

