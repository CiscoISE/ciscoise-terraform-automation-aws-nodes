provider "aws" {
  region = var.aws_region # Update this to your desired region
}

locals {
  ise_username = local.ise_username_map[var.ise_version]
}

resource "aws_launch_template" "ise_launch_template" {
  name_prefix            = "ise-launch-template"
  instance_type          = var.ise_instance_type
  key_name               = var.key_pair_name
  image_id               = var.ami_ids[var.aws_region][var.ise_version]["ami_id"] # Access the AMI ID based on region and version
  vpc_security_group_ids = [aws_security_group.ise-sg.id]
  dynamic "block_device_mappings" {
    for_each = var.ami_ids[var.aws_region][var.ise_version]

    content {
      device_name = "/dev/sda1"
      ebs {
        volume_type           = "gp3"
        volume_size           = var.storage_size
        delete_on_termination = true
        encrypted             = var.ebs_encrypt
      }
    }
  }
}

resource "aws_instance" "primary_ise_server" {
  subnet_id = var.private_subnet1_a
  launch_template {
    id      = aws_launch_template.ise_launch_template.id
    version = aws_launch_template.ise_launch_template.latest_version
  }
  tags = {
    Name = "primary-ise-server"
  }
  user_data = base64encode(templatefile("${path.module}/userdata.tftpl", { hostname = "primary-ise-server", dns_domain = var.dns_domain, username = local.ise_username, password = var.password, time_zone = var.time_zone, ers_api = var.ers_api, open_api = var.open_api, px_grid = var.px_grid, px_grid_cloud = var.px_grid_cloud }))
}

resource "aws_instance" "secondary_ise_server" {
  subnet_id = var.private_subnet1_b
  launch_template {
    id      = aws_launch_template.ise_launch_template.id
    version = aws_launch_template.ise_launch_template.latest_version
  }
  tags = {
    Name = "secondary-ise-server"
  }
  user_data = base64encode(templatefile("${path.module}/userdata.tftpl", { hostname = "secondary-ise-server", dns_domain = var.dns_domain, username = local.ise_username, password = var.password, time_zone = var.time_zone, ers_api = var.ers_api, open_api = var.open_api, px_grid = var.px_grid, px_grid_cloud = var.px_grid_cloud }))
}

resource "aws_instance" "PSN_node" {
  count     = var.psn_node_count
  subnet_id = var.private_subnet1_b
  launch_template {
    id      = aws_launch_template.ise_launch_template.id
    version = aws_launch_template.ise_launch_template.latest_version
  }
  tags = {
    Name = "PSN-ise-server-${count.index+1}"
  }
  user_data = base64encode(templatefile("${path.module}/userdata.tftpl", { hostname = "PSN-ise-server-${count.index+1}", dns_domain = var.dns_domain, username = local.ise_username, password = var.password, time_zone = var.time_zone, ers_api = var.ers_api, open_api = var.open_api, px_grid = var.px_grid, px_grid_cloud = var.px_grid_cloud }))
}


resource "aws_security_group" "ise-sg" {
  name   = "ISE-Security-group"
  vpc_id = var.vpcid

  ingress {
    description = "Within VPC"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.vpccidr]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}




