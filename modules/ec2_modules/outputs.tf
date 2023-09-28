output "launch_template_id" {
  description = "ID of the created launch template."
  value       = aws_launch_template.ise_launch_template.id
}

output "nlb_dns_name" {
  description = "DNS name of the Network Load Balancer."
  value       = aws_lb.psn_nlb.dns_name
}

output "security_group_ids" {
  description = "security group id"
  value       = aws_security_group.ise-sg[*].id
}
# Define other outputs...
