# Copyright 2024 Cisco Systems, Inc. and its affiliates
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# SPDX-License-Identifier: Apache-2.0


# NLB creation

resource "aws_lb" "psn_nlb" {
  name               = "PSNNLB"
  internal           = true
  load_balancer_type = "network"
  ip_address_type    = "ipv4"

  subnet_mapping {
    subnet_id            = var.private_subnet1_a
    private_ipv4_address = var.lb_private_address_subnet1 // this is giving specific ip for alb in each AZ. Manual input needed. Take this as a user inputd
  }

  subnet_mapping {
    subnet_id            = var.private_subnet1_b
    private_ipv4_address = var.lb_private_address_subnet2
  }

  enable_cross_zone_load_balancing = false
  tags = {
    Name = format("%s-Nlb", var.vpcid)
  }
}

# Required Target groups

resource "aws_lb_target_group" "psn_target_groupfor_radius1812" {
  name     = "PSNTargetGroupforRADIUS1812"
  port     = 1812
  protocol = "UDP"
  vpc_id   = var.vpcid

  health_check {
    port     = "443"
    protocol = "TCP"
  }
  stickiness {
    type    = "source_ip"
    enabled = var.enable_stickiness
  }
  tags = {
    Name = "Radius1812"
  }
}

resource "aws_lb_target_group" "psn_target_groupfor_radius1813" {
  name     = "PSNTargetGroupforRADIUS1813"
  port     = 1813
  protocol = "UDP"
  vpc_id   = var.vpcid

  health_check {
    port     = "443"
    protocol = "TCP"
  }
  stickiness {
    type    = "source_ip"
    enabled = var.enable_stickiness
  }
  tags = {
    Name = "Radius1813"
  }
}

resource "aws_lb_target_group" "psn_target_groupfor_radius1645" {
  name     = "PSNTargetGroupforRADIUS1645"
  port     = 1645
  protocol = "UDP"
  vpc_id   = var.vpcid

  health_check {
    port     = "443"
    protocol = "TCP"
  }
  tags = {
    Name = "Radius1645"
  }
  stickiness {
    type    = "source_ip"
    enabled = var.enable_stickiness
  }
}

resource "aws_lb_target_group" "psn_target_groupfor_radius1646" {
  name     = "PSNTargetGroupforRADIUS1646"
  port     = 1646
  protocol = "UDP"
  vpc_id   = var.vpcid

  health_check {
    port     = "443"
    protocol = "TCP"
  }
  tags = {
    Name = "Radius1646"
  }
  stickiness {
    type    = "source_ip"
    enabled = var.enable_stickiness
  }
}

resource "aws_lb_target_group" "psn_target_groupfor_tacacs49" {
  name     = "PSNTargetGroupforTACACS49"
  port     = 49
  protocol = "TCP"
  vpc_id   = var.vpcid // Reference to VPCID

  health_check {
    port     = "443"
    protocol = "TCP"
  }
  stickiness {
    type    = "source_ip"
    enabled = var.enable_stickiness
  }
  tags = {
    Name = "Tacacs49"
  }
}

# target group attachment
resource "aws_lb_target_group_attachment" "psn_attachment_for_radius1812" {
  count            = length(local.ise_nodes_list)
  target_group_arn = aws_lb_target_group.psn_target_groupfor_radius1812.arn
  target_id        = local.ise_nodes_list[count.index]
  port             = 1812
}

resource "aws_lb_target_group_attachment" "psn_attachment_for_radius1813" {
  count            = length(local.ise_nodes_list)
  target_group_arn = aws_lb_target_group.psn_target_groupfor_radius1813.arn
  target_id        = local.ise_nodes_list[count.index]
  port             = 1813
}

resource "aws_lb_target_group_attachment" "psn_attachment_for_radius1645" {
  count            = length(local.ise_nodes_list)
  target_group_arn = aws_lb_target_group.psn_target_groupfor_radius1645.arn
  target_id        = local.ise_nodes_list[count.index]
  port             = 1645
}

resource "aws_lb_target_group_attachment" "psn_attachment_for_radius1646" {
  count            = length(local.ise_nodes_list)
  target_group_arn = aws_lb_target_group.psn_target_groupfor_radius1646.arn
  target_id        = local.ise_nodes_list[count.index]
  port             = 1646
}

resource "aws_lb_target_group_attachment" "psn_attachment_for_tacacs49" {
  count            = length(local.ise_nodes_list)
  target_group_arn = aws_lb_target_group.psn_target_groupfor_tacacs49.arn
  target_id        = local.ise_nodes_list[count.index]
  port             = 49
}



# listeners

resource "aws_lb_listener" "psn_listener_1" {
  load_balancer_arn = aws_lb.psn_nlb.arn // Reference to your NLB resource
  port              = 1812
  protocol          = "UDP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.psn_target_groupfor_radius1812.arn // Reference to your Target Group resource
  }
}

resource "aws_lb_listener" "psn_listener_2" {
  load_balancer_arn = aws_lb.psn_nlb.arn // Reference to your NLB resource
  port              = 1813
  protocol          = "UDP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.psn_target_groupfor_radius1813.arn // Reference to your Target Group resource
  }
}

resource "aws_lb_listener" "psn_listener_3" {
  load_balancer_arn = aws_lb.psn_nlb.arn // Reference to your NLB resource
  port              = 49
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.psn_target_groupfor_tacacs49.arn // Reference to your Target Group resource
  }
}

resource "aws_lb_listener" "psn_listener_4" {
  load_balancer_arn = aws_lb.psn_nlb.arn // Reference to your NLB resource
  port              = 1645
  protocol          = "UDP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.psn_target_groupfor_radius1645.arn // Reference to your Target Group resource
  }
}

resource "aws_lb_listener" "psn_listener_5" {
  load_balancer_arn = aws_lb.psn_nlb.arn // Reference to your NLB resource
  port              = 1646
  protocol          = "UDP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.psn_target_groupfor_radius1646.arn // Reference to your Target Group resource
  }
}



