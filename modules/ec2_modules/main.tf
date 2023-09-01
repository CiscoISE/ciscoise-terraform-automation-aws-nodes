provider "aws" {
  region = var.aws_region # Update this to your desired region
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
  user_data = base64encode(templatefile("${path.module}/userdata.tftpl", { hostname = "primary-ise-server", dns_domain = var.dns_domain, password = var.password, time_zone = var.time_zone, ers_api = var.ers_api, open_api = var.open_api, px_grid = var.px_grid, px_grid_cloud = var.px_grid_cloud }))
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
  user_data = base64encode(templatefile("${path.module}/userdata.tftpl", { hostname = "secondary-ise-server", dns_domain = var.dns_domain, password = var.password, time_zone = var.time_zone, ers_api = var.ers_api, open_api = var.open_api, px_grid = var.px_grid, px_grid_cloud = var.px_grid_cloud }))
}

resource "aws_instance" "PSN_node" {
  count     = var.psn_node_count
  subnet_id = var.private_subnet1_b
  launch_template {
    id      = aws_launch_template.ise_launch_template.id
    version = aws_launch_template.ise_launch_template.latest_version
  }
  tags = {
    Name = "PSN-ise-server-${count.index}"
  }
  user_data = base64encode(templatefile("${path.module}/userdata.tftpl", { hostname = "PSN-ise-server-${count.index}", dns_domain = var.dns_domain, password = var.password, time_zone = var.time_zone, ers_api = var.ers_api, open_api = var.open_api, px_grid = var.px_grid, px_grid_cloud = var.px_grid_cloud }))
}

# resource "aws_autoscaling_group" "ise_autoscaling_group" {
#   name_prefix         = "ise-autoscaling-group"
#   desired_capacity    = var.desired_size
#   max_size            = var.max_size
#   min_size            = var.min_size
#   target_group_arns   = [aws_lb_target_group.psn_target_groupfor_radius1645.arn, aws_lb_target_group.psn_target_groupfor_radius1646.arn, aws_lb_target_group.psn_target_groupfor_radius1812.arn, aws_lb_target_group.psn_target_groupfor_radius1813.arn, aws_lb_target_group.psn_target_groupfor_tacacs49.arn]
#   vpc_zone_identifier = var.vpc_zone_identifier
#   # Launch Template
#   launch_template {
#     id      = aws_launch_template.ise_launch_template.id
#     version = aws_launch_template.ise_launch_template.latest_version
#   }
#   tag {
#     key                 = "Name"
#     value               = "ISE-Node"
#     propagate_at_launch = true
#   }
# }

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




