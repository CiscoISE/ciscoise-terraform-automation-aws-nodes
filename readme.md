terraform plan
var.key_pair_name
  To access the Cisco ISE instance via SSH, choose the key pair that you created/imported in AWS.
  Create/import a key pair in AWS now if you have not configured one already.
  Usage example:  ssh -i mykeypair.pem admin@myhostname.compute-1.amazonaws.com.
  NOTE: The username for ISE 3.1 is "admin" and for ISE 3.2+ is "iseadmin".

  Enter a value: ise3.1pem

var.lb_private_address_subnet1
  Private IP Address of Load Balancer for Private Subnet-1

  Enter a value: 169.254.169.253

var.lb_private_address_subnet2
  Private IP Address of Load Balancer for Private Subnet-2

  Enter a value: 169.254.169.253

var.private_subnet1_a
  ID of the subnet to be used for the ISE deployment  in an Availability Zone A.

  Enter a value: 169.254.169.253

var.private_subnet1_b
  ID of the subnet to be used for the ISE deployment  in an Availability Zone B.

  Enter a value: 169.254.169.253

var.vpcid
  ID of the VPC (e.g., vpc-0343606e)

  Enter a value: vpc-0343606e


Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # aws_autoscaling_group.ise_autoscaling_group will be created
  + resource "aws_autoscaling_group" "ise_autoscaling_group" {
      + arn                              = (known after apply)
      + availability_zones               = (known after apply)
      + default_cooldown                 = (known after apply)
      + desired_capacity                 = 2
      + force_delete                     = false
      + force_delete_warm_pool           = false
      + health_check_grace_period        = 300
      + health_check_type                = (known after apply)
      + id                               = (known after apply)
      + ignore_failed_scaling_activities = false
      + load_balancers                   = (known after apply)
      + max_size                         = 5
      + metrics_granularity              = "1Minute"
      + min_size                         = 2
      + name                             = "ise-autoscaling-group"
      + name_prefix                      = (known after apply)
      + predicted_capacity               = (known after apply)
      + protect_from_scale_in            = false
      + service_linked_role_arn          = (known after apply)
      + target_group_arns                = (known after apply)
      + vpc_zone_identifier              = (known after apply)
      + wait_for_capacity_timeout        = "10m"
      + warm_pool_size                   = (known after apply)

      + launch_template {
          + id   = (known after apply)
          + name = (known after apply)
        }
    }

  # aws_launch_template.ise_launch_template will be created
  + resource "aws_launch_template" "ise_launch_template" {
      + arn             = (known after apply)
      + default_version = (known after apply)
      + id              = (known after apply)
      + image_id        = "ami-0bb0a9d243824a077"
      + instance_type   = "c5.4xlarge"
      + key_name        = "ise3.1pem"
      + latest_version  = (known after apply)
      + name            = (known after apply)
      + name_prefix     = "ise-launch-template"
      + tags_all        = (known after apply)

      + block_device_mappings {
          + device_name = "/dev/sda1"

          + ebs {
              + iops        = (known after apply)
              + snapshot_id = "ami-0bb0a9d243824a077"
              + throughput  = (known after apply)
              + volume_size = 600
              + volume_type = "gp3"
            }
        }
    }

  # aws_lb.psn_nlb will be created
  + resource "aws_lb" "psn_nlb" {
      + arn                              = (known after apply)
      + arn_suffix                       = (known after apply)
      + dns_name                         = (known after apply)
      + enable_cross_zone_load_balancing = true
      + enable_deletion_protection       = false
      + id                               = (known after apply)
      + internal                         = true
      + ip_address_type                  = "ipv4"
      + load_balancer_type               = "network"
      + name                             = "PSNNLB"
      + security_groups                  = (known after apply)
      + subnets                          = (known after apply)
      + tags                             = {
          + "Name" = "vpc-0343606e-Nlb"
        }
      + tags_all                         = {
          + "Name" = "vpc-0343606e-Nlb"
        }
      + vpc_id                           = (known after apply)
      + zone_id                          = (known after apply)

      + subnet_mapping {
          + outpost_id           = (known after apply)
          + private_ipv4_address = "192.164.22.1"
          + subnet_id            = "169.254.169.253"
        }
      + subnet_mapping {
          + outpost_id           = (known after apply)
          + private_ipv4_address = "192.164.22.2"
          + subnet_id            = "169.254.169.253"
        }
    }

  # aws_lb_listener.psn_listener_1 will be created
  + resource "aws_lb_listener" "psn_listener_1" {
      + arn               = (known after apply)
      + id                = (known after apply)
      + load_balancer_arn = (known after apply)
      + port              = 1812
      + protocol          = "UDP"
      + ssl_policy        = (known after apply)
      + tags_all          = (known after apply)

      + default_action {
          + order            = (known after apply)
          + target_group_arn = (known after apply)
          + type             = "forward"
        }
    }

  # aws_lb_listener.psn_listener_2 will be created
  + resource "aws_lb_listener" "psn_listener_2" {
      + arn               = (known after apply)
      + id                = (known after apply)
      + load_balancer_arn = (known after apply)
      + port              = 1813
      + protocol          = "UDP"
      + ssl_policy        = (known after apply)
      + tags_all          = (known after apply)

      + default_action {
          + order            = (known after apply)
          + target_group_arn = (known after apply)
          + type             = "forward"
        }
    }

  # aws_lb_listener.psn_listener_3 will be created
  + resource "aws_lb_listener" "psn_listener_3" {
      + arn               = (known after apply)
      + id                = (known after apply)
      + load_balancer_arn = (known after apply)
      + port              = 49
      + protocol          = "TCP"
      + ssl_policy        = (known after apply)
      + tags_all          = (known after apply)

      + default_action {
          + order            = (known after apply)
          + target_group_arn = (known after apply)
          + type             = "forward"
        }
    }

  # aws_lb_listener.psn_listener_4 will be created
  + resource "aws_lb_listener" "psn_listener_4" {
      + arn               = (known after apply)
      + id                = (known after apply)
      + load_balancer_arn = (known after apply)
      + port              = 1645
      + protocol          = "UDP"
      + ssl_policy        = (known after apply)
      + tags_all          = (known after apply)

      + default_action {
          + order            = (known after apply)
          + target_group_arn = (known after apply)
          + type             = "forward"
        }
    }

  # aws_lb_listener.psn_listener_5 will be created
  + resource "aws_lb_listener" "psn_listener_5" {
      + arn               = (known after apply)
      + id                = (known after apply)
      + load_balancer_arn = (known after apply)
      + port              = 1646
      + protocol          = "UDP"
      + ssl_policy        = (known after apply)
      + tags_all          = (known after apply)

      + default_action {
          + order            = (known after apply)
          + target_group_arn = (known after apply)
          + type             = "forward"
        }
    }

  # aws_lb_target_group.psn_target_groupfor_radius1645 will be created
  + resource "aws_lb_target_group" "psn_target_groupfor_radius1645" {
      + arn                                = (known after apply)
      + arn_suffix                         = (known after apply)
      + connection_termination             = false
      + deregistration_delay               = "300"
      + id                                 = (known after apply)
      + ip_address_type                    = (known after apply)
      + lambda_multi_value_headers_enabled = false
      + load_balancing_algorithm_type      = (known after apply)
      + load_balancing_cross_zone_enabled  = (known after apply)
      + name                               = "PSNTargetGroupforRADIUS1645"
      + port                               = 1645
      + preserve_client_ip                 = (known after apply)
      + protocol                           = "UDP"
      + protocol_version                   = (known after apply)
      + proxy_protocol_v2                  = false
      + slow_start                         = 0
      + tags                               = {
          + "Name" = "Radius1645"
        }
      + tags_all                           = {
          + "Name" = "Radius1645"
        }
      + target_type                        = "instance"
      + vpc_id                             = "vpc-0343606e"

      + health_check {
          + enabled             = true
          + healthy_threshold   = 3
          + interval            = 30
          + matcher             = (known after apply)
          + path                = (known after apply)
          + port                = "443"
          + protocol            = "TCP"
          + timeout             = (known after apply)
          + unhealthy_threshold = 3
        }
    }

  # aws_lb_target_group.psn_target_groupfor_radius1646 will be created
  + resource "aws_lb_target_group" "psn_target_groupfor_radius1646" {
      + arn                                = (known after apply)
      + arn_suffix                         = (known after apply)
      + connection_termination             = false
      + deregistration_delay               = "300"
      + id                                 = (known after apply)
      + ip_address_type                    = (known after apply)
      + lambda_multi_value_headers_enabled = false
      + load_balancing_algorithm_type      = (known after apply)
      + load_balancing_cross_zone_enabled  = (known after apply)
      + name                               = "PSNTargetGroupforRADIUS1646"
      + port                               = 1646
      + preserve_client_ip                 = (known after apply)
      + protocol                           = "UDP"
      + protocol_version                   = (known after apply)
      + proxy_protocol_v2                  = false
      + slow_start                         = 0
      + tags                               = {
          + "Name" = "Radius1646"
        }
      + tags_all                           = {
          + "Name" = "Radius1646"
        }
      + target_type                        = "instance"
      + vpc_id                             = "vpc-0343606e"

      + health_check {
          + enabled             = true
          + healthy_threshold   = 3
          + interval            = 30
          + matcher             = (known after apply)
          + path                = (known after apply)
          + port                = "443"
          + protocol            = "TCP"
          + timeout             = (known after apply)
          + unhealthy_threshold = 3
        }
    }

  # aws_lb_target_group.psn_target_groupfor_radius1812 will be created
  + resource "aws_lb_target_group" "psn_target_groupfor_radius1812" {
      + arn                                = (known after apply)
      + arn_suffix                         = (known after apply)
      + connection_termination             = false
      + deregistration_delay               = "300"
      + id                                 = (known after apply)
      + ip_address_type                    = (known after apply)
      + lambda_multi_value_headers_enabled = false
      + load_balancing_algorithm_type      = (known after apply)
      + load_balancing_cross_zone_enabled  = (known after apply)
      + name                               = "PSNTargetGroupforRADIUS1812"
      + port                               = 1812
      + preserve_client_ip                 = (known after apply)
      + protocol                           = "UDP"
      + protocol_version                   = (known after apply)
      + proxy_protocol_v2                  = false
      + slow_start                         = 0
      + tags                               = {
          + "Name" = "Radius1812"
        }
      + tags_all                           = {
          + "Name" = "Radius1812"
        }
      + target_type                        = "instance"
      + vpc_id                             = "vpc-0343606e"

      + health_check {
          + enabled             = true
          + healthy_threshold   = 3
          + interval            = 30
          + matcher             = (known after apply)
          + path                = (known after apply)
          + port                = "443"
          + protocol            = "TCP"
          + timeout             = (known after apply)
          + unhealthy_threshold = 3
        }
    }

  # aws_lb_target_group.psn_target_groupfor_radius1813 will be created
  + resource "aws_lb_target_group" "psn_target_groupfor_radius1813" {
      + arn                                = (known after apply)
      + arn_suffix                         = (known after apply)
      + connection_termination             = false
      + deregistration_delay               = "300"
      + id                                 = (known after apply)
      + ip_address_type                    = (known after apply)
      + lambda_multi_value_headers_enabled = false
      + load_balancing_algorithm_type      = (known after apply)
      + load_balancing_cross_zone_enabled  = (known after apply)
      + name                               = "PSNTargetGroupforRADIUS1813"
      + port                               = 1813
      + preserve_client_ip                 = (known after apply)
      + protocol                           = "UDP"
      + protocol_version                   = (known after apply)
      + proxy_protocol_v2                  = false
      + slow_start                         = 0
      + tags                               = {
          + "Name" = "Radius1813"
        }
      + tags_all                           = {
          + "Name" = "Radius1813"
        }
      + target_type                        = "instance"
      + vpc_id                             = "vpc-0343606e"

      + health_check {
          + enabled             = true
          + healthy_threshold   = 3
          + interval            = 30
          + matcher             = (known after apply)
          + path                = (known after apply)
          + port                = "443"
          + protocol            = "TCP"
          + timeout             = (known after apply)
          + unhealthy_threshold = 3
        }
    }

  # aws_lb_target_group.psn_target_groupfor_tacacs49 will be created
  + resource "aws_lb_target_group" "psn_target_groupfor_tacacs49" {
      + arn                                = (known after apply)
      + arn_suffix                         = (known after apply)
      + connection_termination             = false
      + deregistration_delay               = "300"
      + id                                 = (known after apply)
      + ip_address_type                    = (known after apply)
      + lambda_multi_value_headers_enabled = false
      + load_balancing_algorithm_type      = (known after apply)
      + load_balancing_cross_zone_enabled  = (known after apply)
      + name                               = "PSNTargetGroupforTACACS49"
      + port                               = 49
      + preserve_client_ip                 = (known after apply)
      + protocol                           = "TCP"
      + protocol_version                   = (known after apply)
      + proxy_protocol_v2                  = false
      + slow_start                         = 0
      + tags                               = {
          + "Name" = "Tacacs49"
        }
      + tags_all                           = {
          + "Name" = "Tacacs49"
        }
      + target_type                        = "instance"
      + vpc_id                             = "vpc-0343606e"

      + health_check {
          + enabled             = true
          + healthy_threshold   = 3
          + interval            = 30
          + matcher             = (known after apply)
          + path                = (known after apply)
          + port                = "443"
          + protocol            = "TCP"
          + timeout             = (known after apply)
          + unhealthy_threshold = 3
        }
    }

Plan: 13 to add, 0 to change, 0 to destroy.
╷
│ Warning: Value for undeclared variable
│ 
│ The root module does not declare a variable named "KeyPairName" but a value was found in file "terraform.tfvars". If you meant to use this value, add a "variable" block to the
│ configuration.
│ 
│ To silence these warnings, use TF_VAR_... environment variables to provide certain "global" settings to all configurations in your organization. To reduce the verbosity of these
│ warnings, use the -compact-warnings option.