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

resource "aws_route53_zone" "forward_dns" {
  name    = var.dns_domain
  comment = "Private hosted forward zone for ISE"
  vpc {
    vpc_id = var.vpcid
  }

  tags = {
    Name = "Forwardzone-${var.dns_domain}"
  }
}

resource "aws_route53_record" "lb_dns_record" {
  zone_id = aws_route53_zone.forward_dns.zone_id
  name    = "lb.${var.dns_domain}"
  type    = "A"

  alias {
    name                   = aws_lb.psn_nlb.dns_name
    zone_id                = aws_lb.psn_nlb.zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "ise_node_dns_record" {
  for_each = zipmap(local.ise_hostnames_list, local.ise_private_ip_list)
  zone_id  = aws_route53_zone.forward_dns.zone_id
  name     = "${each.key}.${var.dns_domain}"
  type     = "A"
  ttl      = 300
  records  = [each.value]
}

