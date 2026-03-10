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

resource "aws_vpc" "cisco_ise" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = var.enable_dns_support
  enable_dns_hostnames = var.enable_dns_hostnames

  tags = {
    Name = var.vpc_name
  }
}

resource "aws_internet_gateway" "cisco_ise_internet_gateway" {
  vpc_id = aws_vpc.cisco_ise.id

  tags = {
    Name = "Cisco_ISE_IGW"
  }
}


resource "aws_subnet" "public_subnets" {
  count = length(var.public_subnet_cidrs)

  cidr_block = var.public_subnet_cidrs[count.index]
  vpc_id     = aws_vpc.cisco_ise.id
  #availability_zone = element(var.availability_zones, count.index)
  availability_zone = var.availability_zones[count.index]

  tags = {
    Name = "PublicSubnet-${count.index + 1}"
  }
}

resource "aws_subnet" "private_subnets" {
  count = length(var.private_subnet_cidrs)

  cidr_block = var.private_subnet_cidrs[count.index]
  vpc_id     = aws_vpc.cisco_ise.id
  #availability_zone = element(var.availability_zones, count.index)
  availability_zone = var.availability_zones[count.index]

  tags = {
    Name = "PrivateSubnet-${count.index + 1}"
  }
}

resource "aws_nat_gateway" "cisco_ise_nat_gateways" {
  count         = length(var.public_subnet_cidrs)
  allocation_id = element(aws_eip.cisco_ise_nat_ips.*.id, count.index)
  subnet_id     = element(aws_subnet.public_subnets.*.id, count.index)

  tags = {
    Name = "NATGateway-${count.index + 1}"
  }
  depends_on = [aws_internet_gateway.cisco_ise_internet_gateway]
}

resource "aws_eip" "cisco_ise_nat_ips" {
  count = length(var.public_subnet_cidrs)
  tags = {
    Name = "NATEIP-${count.index + 1}"
  }
}

resource "aws_vpc_dhcp_options" "cisco_ise_dhcp_options" {
  domain_name_servers = ["AmazonProvidedDNS"]
  domain_name         = "${var.aws_region}.compute.internal"
  tags = {
    Name = "cisco_ise_DHCPOptions"
  }
}

resource "aws_vpc_dhcp_options_association" "cisco_ise_dhcp_association" {
  vpc_id          = aws_vpc.cisco_ise.id
  dhcp_options_id = aws_vpc_dhcp_options.cisco_ise_dhcp_options.id
}

resource "aws_route_table" "public_subnet_route_table" {
  vpc_id = aws_vpc.cisco_ise.id

  tags = {
    Name = "PublicSubnetsRouteTable"
  }
}

resource "aws_route_table_association" "public_subnet_association" {
  count          = length(var.public_subnet_cidrs)
  subnet_id      = aws_subnet.public_subnets[count.index].id
  route_table_id = aws_route_table.public_subnet_route_table.id
}

resource "aws_route" "public_subnet_route" {
  route_table_id         = aws_route_table.public_subnet_route_table.id
  destination_cidr_block = "0.0.0.0/0" # This means all traffic not matching other routes goes to the IGW
  gateway_id             = aws_internet_gateway.cisco_ise_internet_gateway.id

  depends_on = [aws_internet_gateway.cisco_ise_internet_gateway]
}

resource "aws_route_table" "private_subnet_route_tables" {
  count = length(var.private_subnet_cidrs)

  vpc_id = aws_vpc.cisco_ise.id

  tags = {
    Name = "PrivateSubnetRouteTable-${count.index + 1}"
  }
}

resource "aws_route_table_association" "private_subnet_association" {
  count          = length(var.private_subnet_cidrs)
  subnet_id      = aws_subnet.private_subnets[count.index].id
  route_table_id = aws_route_table.private_subnet_route_tables[count.index].id
}

resource "aws_route" "private_subnet_route" {
  count = length(var.private_subnet_cidrs)

  route_table_id         = aws_route_table.private_subnet_route_tables[count.index].id
  destination_cidr_block = "0.0.0.0/0" # This means all traffic not matching other routes goes to the IGW
  gateway_id             = aws_nat_gateway.cisco_ise_nat_gateways[count.index].id

  depends_on = [aws_nat_gateway.cisco_ise_nat_gateways]
}


#resource "aws_vpc_endpoint" "s3_endpoint" {
#  vpc_id       = aws_vpc.cisco_ise.id
#  service_name = "com.amazonaws.${var.aws_region}.s3"
#  tags = {
#    Name = "cisco-ise-s3-vpce"
#  }
#}

#need to check the association of s3vpc subnet association

#resource "aws_route_table_association" "s3_endpoint_association" {
#  count          = length(var.private_subnet_cidrs)
#  subnet_id      = aws_subnet.private_subnets[count.index].id
#  route_table_id = aws_route_table.private_subnet_route_tables[count.index].id
#}

# resource "aws_route" "s3_endpoint_route" {
#   count             = length(var.private_subnet_cidrs)
#   route_table_id    = aws_route_table.private_subnet_route_tables[count.index].id
#   destination_cidr_block = "0.0.0.0/0"
#   vpc_endpoint_id  = aws_vpc_endpoint.s3_endpoint.id
# }

