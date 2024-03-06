provider "aws" {
  region = var.aws_region
}

locals {
  ise_username = local.ise_username_map[var.ise_version]
}

data "assert_test" "redundant_monitoring_values" {
  test  = length(flatten([for role in local.roles : role if role == "SecondaryMonitoring" || role == "SecondaryDedicatedMonitoring" || role == "PrimaryMonitoring" || role == "PrimaryDedicatedMonitoring"])) <= 1
  throw = "Only one of the monitoring roles in [SecondaryMonitoring, SecondaryDedicatedMonitoring, PrimaryMonitoring, PrimaryDedicatedMonitoring] can be allotted to a single node at a time, and not to several nodes at once."
}

resource "aws_launch_template" "ise_launch_template" {
  name_prefix            = "ise-launch-template"
  key_name               = var.key_pair_name
  image_id               = var.ami_ids[var.aws_region][var.ise_version]["ami_id"]
  vpc_security_group_ids = [aws_security_group.ise-sg.id]
}

resource "aws_instance" "primary_ise_server" {
  for_each      = var.primary_instance_config
  subnet_id     = var.private_subnet1_a
  instance_type = each.value.instance_type
  launch_template {
    id      = aws_launch_template.ise_launch_template.id
    version = aws_launch_template.ise_launch_template.latest_version
  }
  ebs_block_device {
    device_name           = "/dev/sda1"
    delete_on_termination = true
    volume_type           = "gp3"
    volume_size           = each.value.storage_size
    encrypted             = var.ebs_encrypt
  }
  tags = {
    Name = each.key
  }
  user_data = base64encode(templatefile("${path.module}/userdata.tftpl", { hostname = each.key, dns_domain = var.dns_domain, username = local.ise_username, password = var.password, time_zone = var.time_zone, ers_api = var.ers_api, open_api = var.open_api, px_grid = var.px_grid, px_grid_cloud = var.px_grid_cloud, primarynameserver = var.primarynameserver, ntpserver = var.ntpserver }))
}

resource "aws_instance" "secondary_ise_server" {
  for_each      = var.secondary_instance_config
  subnet_id     = var.private_subnet1_b
  instance_type = each.value.instance_type
  launch_template {
    id      = aws_launch_template.ise_launch_template.id
    version = aws_launch_template.ise_launch_template.latest_version
  }
  ebs_block_device {
    device_name           = "/dev/sda1"
    delete_on_termination = true
    volume_type           = "gp3"
    volume_size           = each.value.storage_size
    encrypted             = var.ebs_encrypt
  }
  tags = {
    Name = each.key
  }
  user_data = base64encode(templatefile("${path.module}/userdata.tftpl", { hostname = each.key, dns_domain = var.dns_domain, username = local.ise_username, password = var.password, time_zone = var.time_zone, ers_api = var.ers_api, open_api = var.open_api, px_grid = var.px_grid, px_grid_cloud = var.px_grid_cloud, primarynameserver = var.primarynameserver, ntpserver = var.ntpserver }))
}

resource "aws_instance" "PSN_node" {
  for_each      = var.psn_instance_config
  subnet_id     = var.subnet_id_list[index(keys(var.psn_instance_config), each.key) % length(var.subnet_id_list)]
  instance_type = each.value.instance_type
  launch_template {
    id      = aws_launch_template.ise_launch_template.id
    version = aws_launch_template.ise_launch_template.latest_version
  }
  ebs_block_device {
    device_name           = "/dev/sda1"
    delete_on_termination = true
    volume_type           = "gp3"
    volume_size           = each.value.storage_size
    encrypted             = var.ebs_encrypt
  }
  tags = {
    Name = each.key
  }
  user_data = base64encode(templatefile("${path.module}/userdata.tftpl", { hostname = each.key, dns_domain = var.dns_domain, username = local.ise_username, password = var.password, time_zone = var.time_zone, ers_api = var.ers_api, open_api = var.open_api, px_grid = var.px_grid, px_grid_cloud = var.px_grid_cloud, primarynameserver = var.primarynameserver, ntpserver = var.ntpserver }))
}


resource "aws_security_group" "ise-sg" {
  name   = "ISE-Security-group"
  vpc_id = var.vpcid

  ingress {
    description = "Within VPC"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.vpc_cidr]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}




