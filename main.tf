provider "aws" {
  region = var.aws_region # Update this to your desired region
}

resource "aws_launch_template" "ise_launch_template" {
  name_prefix            = "ise-launch-template"
  instance_type          = var.ise_instance_type
  key_name               = var.key_pair_name
  image_id               = var.ami_ids[var.aws_region][var.ise_version]["ami_id"] # Access the AMI ID based on region and version
  vpc_security_group_ids = [aws_security_group.ise-sg.id]
  user_data              = file("${path.module}/user_data.sh")

  dynamic "block_device_mappings" {
    for_each = var.ami_ids[var.aws_region][var.ise_version]

    content {
      device_name = "/dev/sda1"
      ebs {
        volume_type = "gp3"
        volume_size = var.storage_size
        snapshot_id = block_device_mappings.value
      }
    }
  }

  # Other launch template properties...
}


/* data "aws_ami" "ise_ami" {
  most_recent = true

  filter {
    name   = "name"
    values = [var.ISEVersion]
  }

  owners = ["self"]  
} */


resource "aws_autoscaling_group" "ise_autoscaling_group" {
  name_prefix         = "ise-autoscaling-group"
  desired_capacity    = var.desired_size
  max_size            = var.max_size
  min_size            = var.min_size
  target_group_arns   = [aws_lb_target_group.psn_target_groupfor_radius1645.arn, aws_lb_target_group.psn_target_groupfor_radius1646.arn, aws_lb_target_group.psn_target_groupfor_radius1812.arn, aws_lb_target_group.psn_target_groupfor_radius1813.arn, aws_lb_target_group.psn_target_groupfor_tacacs49.arn]
  vpc_zone_identifier = var.vpc_zone_identifier
  # Launch Template
  launch_template {
    id      = aws_launch_template.ise_launch_template.id
    version = aws_launch_template.ise_launch_template.latest_version
  }
  tag {
    key                 = "Name"
    value               = "ISE-Node"
    propagate_at_launch = true
  }
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




