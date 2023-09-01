locals {
  ise_nodes_list      = concat([aws_instance.primary_ise_server.id, aws_instance.secondary_ise_server.id], aws_instance.PSN_node.*.id)
  ise_hostnames_list  = concat([aws_instance.primary_ise_server.tags["Name"], aws_instance.secondary_ise_server.tags["Name"]], [for tag in aws_instance.PSN_node.*.tags : tag["Name"]])
  ise_private_ip_list = concat([aws_instance.primary_ise_server.private_ip, aws_instance.secondary_ise_server.private_ip], aws_instance.PSN_node.*.private_ip)
}