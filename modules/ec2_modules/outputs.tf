output "launch_template_id" {
  description = "ID of the created launch template."
  value       = aws_launch_template.ise_launch_template[*]
}

output "nlb_dns_name" {
  description = "DNS name of the Network Load Balancer."
  value       = aws_lb.psn_nlb.dns_name
}

output "security_group_ids" {
  description = "security group id"
  value       = aws_security_group.ise-sg[*].id
}

output "primary_instance_id" {
  description = "Instance id of the primary ISE node"
  value       = aws_instance.primary_ise_server.id
}

output "secondary_instance_id" {
  description = "Instance id of the secondary ISE node"
  value       = aws_instance.secondary_ise_server.id
}

output "psn_instance_id" {
  description = "Instance id of the PSN ISE nodes"
  value       = aws_instance.PSN_node.*.id
}

output "primary_private_ip" {
  description = "Private IP address of primary ISE node"
  value       = aws_instance.primary_ise_server.private_ip
}

output "secondary_private_ip" {
  description = "Private IP address of Secondary ISE node"
  value       = aws_instance.secondary_ise_server.private_ip
}

output "psn_private_ip" {
  description = "Private IP address of PSN ISE nodes"
  value       = aws_instance.PSN_node.*.private_ip
}

output "primary_dns_name" {
  description = "Private DNSName of the primary ISE node"
  value       = aws_route53_record.ise_node_dns_record[local.ise_hostnames_list[0]].name
}

output "secondary_dns_name" {
  description = "Private DNSName of the primary ISE node"
  value       = aws_route53_record.ise_node_dns_record[local.ise_hostnames_list[1]].name
}

output "psn_dns_name" {
  description = "Private DNSName of the PSN ISE nodes"
  value       = [for name in slice(local.ise_hostnames_list, 2, length(local.ise_hostnames_list)) : aws_route53_record.ise_node_dns_record[name].name]
}