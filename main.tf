provider "aws" {
  region = "us-east-1"  # Update this to your desired region
}

resource "aws_launch_template" "ise_launch_template" {
  name_prefix   = "ise-launch-template"
  instance_type = var.ISEInstanceType
  key_name      = var.KeyPairName

  user_data = file("${path.module}/user_data.sh")


  dynamic "block_device_mappings" {
    for_each = var.ISE_AMI_MAPPING[var.AWS_REGION][var.ISEVersion]

    content {
      device_name = "/dev/sda1"
      ebs {
        volume_type = "gp2"
        volume_size = var.StorageSize
      }
      # Optionally, you can use the AMI ID from the mapping
      ami = block_device_mappings.value.AMI
    }
  }

  # Other launch template properties...
}

data "aws_ami" "ise_ami" {
  most_recent = true

  filter {
    name   = "name"
    values = [var.ISEVersion]
  }

  owners = ["self"]  # Assuming you have your own AMIs
}

# Define security groups, subnets, etc...

resource "aws_autoscaling_group" "ise_autoscaling_group" {
  name                 = "ise-autoscaling-group"
  launch_template     = aws_launch_template.ise_launch_template.id
  min_size             = 2
  max_size             = 5
  desired_capacity    = 2  # Adjust as needed

  # Other autoscaling group properties...
}

resource "aws_lb" "ise_lb" {
  name               = "ise-load-balancer"
  internal           = true
  load_balancer_type = "network"
  subnets            = [var.PrivateSubnet1A, var.PrivateSubnet1B]

  # Other load balancer properties...
}

resource "aws_lb_target_group" "ise_target_group" {
  name_prefix = "ise-target-group"
  port        = 443
  protocol    = "TCP"
  vpc_id      = var.VPCID

  # Other target group properties...
}

resource "aws_lb_listener" "ise_listener" {
  load_balancer_arn = aws_lb.ise_lb.arn
  port              = 443
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ise_target_group.arn
  }
}

# Define other target groups, listeners, and related resources...

# Configure autoscaling group to use target groups
resource "aws_autoscaling_attachment" "ise_autoscaling_attachment" {
  autoscaling_group_name = aws_autoscaling_group.ise_autoscaling_group.name
  alb_target_group_arn   = aws_lb_target_group.ise_target_group.arn
}

# Create Route53 records, reverse DNS, etc...
