output "primary_instance_id" {
  description = "Instance id of the primary ISE node"
  value       = module.cisco_ise_ec2.primary_instance_id
}

output "secondary_instance_id" {
  description = "Instance id of the secondary ISE node"
  value       = module.cisco_ise_ec2.secondary_instance_id
}

output "psn_instance_id" {
  description = "Instance id of the PSN ISE nodes"
  value       = module.cisco_ise_ec2.psn_instance_id
}

output "primary_private_ip" {
  description = "Private IP address of primary ISE node"
  value       = module.cisco_ise_ec2.primary_private_ip
}

output "secondary_private_ip" {
  description = "Private IP address of Secondary ISE node"
  value       = module.cisco_ise_ec2.secondary_private_ip
}

output "psn_private_ip" {
  description = "Private IP address of PSN ISE nodes"
  value       = module.cisco_ise_ec2.psn_private_ip
}

output "primary_dns_name" {
  description = "Private DNSName of the primary ISE node"
  value       = module.cisco_ise_ec2.primary_dns_name
}

output "secondary_dns_name" {
  description = "Private DNSName of the primary ISE node"
  value       = module.cisco_ise_ec2.secondary_dns_name
}

output "psn_dns_name" {
  description = "Private DNSName of the PSN ISE nodes"
  value       = module.cisco_ise_ec2.psn_dns_name
}