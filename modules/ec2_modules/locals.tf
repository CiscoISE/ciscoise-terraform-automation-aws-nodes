locals {
  ise_username_map    = { 3.1 = "admin", 3.2 = "iseadmin" }
  ise_nodes_list      = concat([aws_instance.primary_ise_server.id, aws_instance.secondary_ise_server.id], aws_instance.PSN_node.*.id)
  ise_hostnames_list  = concat([aws_instance.primary_ise_server.tags["Name"], aws_instance.secondary_ise_server.tags["Name"]], [for tag in aws_instance.PSN_node.*.tags : tag["Name"]])
  ise_private_ip_list = concat([aws_instance.primary_ise_server.private_ip, aws_instance.secondary_ise_server.private_ip], aws_instance.PSN_node.*.private_ip)
  ise_ssm_host_map    = merge({ Primary_FQDN = "${local.ise_hostnames_list[0]}.${var.dns_domain}", Secondary_FQDN = "${local.ise_hostnames_list[1]}.${var.dns_domain}" }, { for i, v in slice(local.ise_hostnames_list, 2, length(local.ise_hostnames_list)) : "PSN_ISE_SERVER_${i+1}_FQDN" => "${v}.${var.dns_domain}" })
  ise_ssm_ip_map      = merge({ Primary_IP = local.ise_private_ip_list[0], Secondary_IP = local.ise_private_ip_list[1] }, { for i, v in slice(local.ise_private_ip_list, 2, length(local.ise_private_ip_list)) : "PSN_ISE_SERVER_${i+1}_IP" => v })
  ise_ssm_full_map    = merge({ SyncStatus = "INITIAL", Maintenance = "DISABLED", ADMIN_USERNAME = local.ise_username }, local.ise_ssm_host_map, local.ise_ssm_ip_map)
}