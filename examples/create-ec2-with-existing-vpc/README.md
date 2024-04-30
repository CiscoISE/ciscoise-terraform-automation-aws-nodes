<!-- BEGIN_TF_DOCS -->
## Required VPC Components

Please review the table below and ensure to create the specified VPC resources for setting up the VPC infrastructure

| Resource Type | Count | Comments |
| ---- | :---: | ---- |
| aws_vpc | 1 | private network |
| vpc_dhcp_options | 1 | default values<br>Domain name: ${region}.compute.internal<br>Domain name servers: AmazonProvidedDNS<br>NTP servers: |
| internet_gateway | 1 | It will be associated with public route table |
| public_subnet_route_table | 1 | depends on number of subnets provided by user |
| private_subnet_route_tables | 3 | depends on number of subnets provided by user |
| public_subnet_route | 3 | depends on number of subnets provided by user |
| private_subnet_route | 3 | depends on number of subnets provided by user |
| nat_gateways | 3 | It will be associated with private route table |
| nat_ips | 3 | depends on number of subnets provided by user |
| public_subnet | 3 | depends on user input |
| private_subnet | 3 | depends on user input | 



## Terraform variables

The module uses below input variables. Update the values in terraform.tfvars file as per requirement

:warning: **Please only update the terraform input variables in `terraform.tfvars` file**

## Inputs

| Name | Description | Type | Default |
|------|-------------|------|---------|
| <a name="input_vpc_cidr"></a> [vpc\_cidr](#input\_vpc\_cidr) | CIDR block for the VPC | `string` | `"10.0.0.0/16"` |  
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | VPC ID | `string` | `"vpc-057efe0e8a68a3b55"` |  
| <a name="input_vpc_name"></a> [vpc\_name](#input\_vpc\_name) | Name tag for the VPC | `string` | `"cisco_ise"` |  
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | Specify the AWS region | `string` | `"us-east-1"` |  
| <a name="input_availability_zones"></a> [availability\_zones](#input\_availability\_zones) | List of availability zones | `list(string)` | <pre>[<br>  "us-east-1a",<br>  "us-east-1b",<br>  "us-east-1c"<br>]</pre> |  
| <a name="input_public_subnet_cidrs"></a> [public\_subnet\_cidrs](#input\_public\_subnet\_cidrs) | List of CIDR blocks for public subnets | `list(string)` | <pre>[<br>  "10.0.1.0/24",<br>  "10.0.2.0/24",<br>  "10.0.3.0/24"<br>]</pre> |  
| <a name="input_private_subnet_cidrs"></a> [private\_subnet\_cidrs](#input\_private\_subnet\_cidrs) | List of CIDR blocks for private subnets | `list(string)` | <pre>[<br>  "10.0.11.0/24",<br>  "10.0.12.0/24",<br>  "10.0.13.0/24"<br>]</pre> |  
| <a name="input_subnet_id_list"></a> [subnet\_id\_list](#input\_subnet\_id\_list) | List of subnet IDs to launch resources in. The list should contain subnet id's in following order - ["subnetid in A AZ", "subnetid in B AZ", "subnetid in C AZ"] | `list(string)` | <pre>[<br>  "subnet-045716712cef0ea64",<br>  "subnet-00951b7d1a25cd789",<br>  "subnet-00c1fd9e924862a07"<br>]</pre> |  
| <a name="input_internet_gateway_name"></a> [internet\_gateway\_name](#input\_internet\_gateway\_name) | Name tag for the Internet Gateway | `string` | `"Cisco_ISE_IGW"` |  
| <a name="input_primary_instance_config"></a> [primary\_instance\_config](#input\_primary\_instance\_config) | Specify the configuration for primary pan instance where key is the hostname and values are instance attributes<br> Hostname only supports alphanumeric characters and hyphen (-). The length of the hostname should not exceed 19 characters.Example usage - <br>{<br>primary-ise-server = { <br>    instance\_type = "t3.xlarge"<br>    storage\_size = 500<br>  }<br>} | <pre>map(object({<br>    instance_type = string<br>    storage_size  = number<br>  }))</pre> | n/a |
| <a name="input_secondary_instance_config"></a> [secondary\_instance\_config](#input\_secondary\_instance\_config) | Specify the configuration for secondary pan instance where key is the hostname and values are instance attributes.<br>Hostname only supports alphanumeric characters and hyphen (-). The length of the hostname should not exceed 19 characters. <br>Example usage -<br>{<br>secondary-ise-server = { <br>    instance\_type = "t3.xlarge"<br>    storage\_size = 500<br>    services = "Session,Profiler,pxGrid"<br>    roles = "SecondaryAdmin"<br>  }<br>} | <pre>map(object({<br>    instance_type = string<br>    storage_size  = number<br>    services      = optional(string, "Session,Profiler,pxGrid")<br>    roles         = optional(string, "SecondaryAdmin,SecondaryMonitoring")<br>  }))</pre> | n/a |
| <a name="input_psn_instance_config"></a> [psn\_instance\_config](#input\_psn\_instance\_config) | Specify the configuration for PSN nodes where key is the hostname and values are instance attributes.<br> Hostname only supports alphanumeric characters and hyphen (-). The length of the hostname should not exceed 19 characters. Example usage - <br>{<br>  secmonitoring-server = {<br>    instance\_type = "t3.xlarge"<br>    storage\_size  = 500<br>    roles = "SecondaryMonitoring"<br>  }<br>  psn-ise-server-2 = {<br>    instance\_type = "t3.xlarge"<br>    storage\_size  = 600<br>    services      = "Session,Profiler,PassiveIdentity"<br>  }<br>} | <pre>map(object({<br>    instance_type = string<br>    storage_size  = number<br>    services      = optional(string, "Session,Profiler")<br>    roles         = optional(string, " ")<br>  }))</pre> | n/a |
| <a name="input_key_pair_name"></a> [key\_pair\_name](#input\_key\_pair\_name) | To access the Cisco ISE instance via SSH, choose the key pair that you created/imported in AWS.<br>Create/import a key pair in AWS now if you have not configured one already.<br>Usage example:  ssh -i mykeypair.pem admin@myhostname.compute-1.amazonaws.com.<br>NOTE: The username for ISE 3.1 is "admin" and for ISE 3.2+ is "iseadmin". | `string` | `"ise-test-nv"` |  
| <a name="input_ebs_encrypt"></a> [ebs\_encrypt](#input\_ebs\_encrypt) | Choose true to enable EBS encryption | `bool` | `false` |
| <a name="input_enable_stickiness"></a> [enable\_stickiness](#input\_enable\_stickiness) | Choose true or false to enable/disable stickiness for the load balancer | `bool` | `true` |
| <a name="input_ise_version"></a> [ise\_version](#input\_ise\_version) | The version of Cisco ISE (3.1 or 3.2) | `string` | `"3.1"` |  
| <a name="input_password"></a> [password](#input\_password) | The password for username (admin) to log in to the Cisco ISE GUI. The password must contain a minimum of 6 and maximum of 25 characters, and must include at least one numeral, one uppercase letter, and one lowercase letter. Password should not be the same as username or its reverse(admin or nimdaesi) or (cisco or ocsic). Allowed Special Characters @~*!,+=\_- | `string` | `""` |  
| <a name="input_time_zone"></a> [time\_zone](#input\_time\_zone) | Enter a timezone, for example, Etc/UTC | `string` | `"UTC"` |  
| <a name="input_ers_api"></a> [ers\_api](#input\_ers\_api) | Enter yes/no to enable/disable ERS | `string` | `"yes"` |  
| <a name="input_open_api"></a> [open\_api](#input\_open\_api) | Enter yes/no to enable/disable OpenAPI | `string` | `"yes"` |  
| <a name="input_px_grid"></a> [px\_grid](#input\_px\_grid) | Enter yes/no to enable/disable pxGrid | `string` | `"yes"` |  
| <a name="input_px_grid_cloud"></a> [px\_grid\_cloud](#input\_px\_grid\_cloud) | Enter yes/no to enable/disable pxGrid Cloud. To enable pxGrid Cloud, you must enable pxGrid. If you disallow pxGrid, but enable pxGrid Cloud, pxGrid Cloud services are not enabled on launch | `string` | `"yes"` |
| <a name="input_primarynameserver"></a> [primarynameserver](#input\_primarynameserver) | Enter the IP address of the Primary name server. Only IPv4 addresses are supported | `string` | `"169.254.169.253"` |
| <a name="input_ntpserver"></a> [ntpserver](#input\_ntpserver) | Enter the IPv4 address or FQDN of the NTP server that must be used for synchronization. | `string` | `"169.254.169.123"` |  
| <a name="input_dns_domain"></a> [dns\_domain](#input\_dns\_domain) | Enter a domain name in correct syntax (for example, cisco.com). The valid characters for this field are ASCII characters, numerals, hyphen (-), and period (.). If you use the wrong syntax, Cisco ISE services might not come up on launch. | `string` | `"example.com"` |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_primary_instance_id"></a> [primary\_instance\_id](#output\_primary\_instance\_id) | Instance id of the primary ISE node |
| <a name="output_secondary_instance_id"></a> [secondary\_instance\_id](#output\_secondary\_instance\_id) | Instance id of the secondary ISE node |
| <a name="output_psn_instance_id"></a> [psn\_instance\_id](#output\_psn\_instance\_id) | Instance id of the PSN ISE nodes |
| <a name="output_primary_private_ip"></a> [primary\_private\_ip](#output\_primary\_private\_ip) | Private IP address of primary ISE node |
| <a name="output_secondary_private_ip"></a> [secondary\_private\_ip](#output\_secondary\_private\_ip) | Private IP address of Secondary ISE node |
| <a name="output_psn_private_ip"></a> [psn\_private\_ip](#output\_psn\_private\_ip) | Private IP address of PSN ISE nodes |
| <a name="output_primary_dns_name"></a> [primary\_dns\_name](#output\_primary\_dns\_name) | Private DNSName of the primary ISE node |
| <a name="output_secondary_dns_name"></a> [secondary\_dns\_name](#output\_secondary\_dns\_name) | Private DNSName of the primary ISE node |
| <a name="output_psn_dns_name"></a> [psn\_dns\_name](#output\_psn\_dns\_name) | Private DNSName of the PSN ISE nodes |
<!-- END_TF_DOCS -->
