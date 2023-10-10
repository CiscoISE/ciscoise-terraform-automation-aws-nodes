<!-- BEGIN_TF_DOCS -->
## Terraform variables documentation

This module uses below terraform variables as input. Update the terraform variables as per requirement


## Inputs

| Name | Description | Type | Default |
|------|-------------|------|---------|
| <a name="input_availability_zones"></a> [availability\_zones](#input\_availability\_zones) | List of availability zones | `list(string)` | <pre>[<br>  "us-east-1a",<br>  "us-east-1b",<br>  "us-east-1c"<br>]</pre>
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | AWS region | `string` | `"us-east-1"` | no |
| <a name="input_dns_domain"></a> [dns\_domain](#input\_dns\_domain) | ###################################### ## Block to Update DNS Domain Name ### ###################################### | `string` | `"drilldevops.in"` | no |
| <a name="input_ebs_encrypt"></a> [ebs\_encrypt](#input\_ebs\_encrypt) | Choose true to enable EBS encryption | `bool` | `false` | no |
| <a name="input_ers_api"></a> [ers\_api](#input\_ers\_api) | n/a | `string` | `"yes"` | no |
| <a name="input_internet_gateway_name"></a> [internet\_gateway\_name](#input\_internet\_gateway\_name) | Name tag for the Internet Gateway | `string` | `"Cisco_ISE_IGW"` | no |
| <a name="input_ise_instance_type"></a> [ise\_instance\_type](#input\_ise\_instance\_type) | Choose the required Cisco ISE instance type. Valid values are c5.4xlarge , m5.4xlarge, c5.9xlarge, t3.xlarge | `string` | `"t3.xlarge"` | no |
| <a name="input_ise_version"></a> [ise\_version](#input\_ise\_version) | The version of Cisco ISE (3.1 or 3.2) | `string` | `"3.1"` | no |
| <a name="input_key_pair_name"></a> [key\_pair\_name](#input\_key\_pair\_name) | To access the Cisco ISE instance via SSH, choose the key pair that you created/imported in AWS.<br>Create/import a key pair in AWS now if you have not configured one already.<br>Usage example:  ssh -i mykeypair.pem admin@myhostname.compute-1.amazonaws.com.<br>NOTE: The username for ISE 3.1 is "admin" and for ISE 3.2+ is "iseadmin". | `string` | `"ise-test-nv"` | no |
| <a name="input_open_api"></a> [open\_api](#input\_open\_api) | n/a | `string` | `"yes"` | no |
| <a name="input_password"></a> [password](#input\_password) | n/a | `string` | `"C!sc0Ind1@"` | no |
| <a name="input_private_subnet_cidrs"></a> [private\_subnet\_cidrs](#input\_private\_subnet\_cidrs) | List of CIDR blocks for private subnets | `list(string)` | <pre>[<br>  "10.0.11.0/24",<br>  "10.0.12.0/24",<br>  "10.0.13.0/24"<br>]</pre> | no |
| <a name="input_psn_node_count"></a> [psn\_node\_count](#input\_psn\_node\_count) | Specify the number of PSN nodes | `number` | `2` | no |
| <a name="input_public_subnet_cidrs"></a> [public\_subnet\_cidrs](#input\_public\_subnet\_cidrs) | List of CIDR blocks for public subnets | `list(string)` | <pre>[<br>  "10.0.1.0/24",<br>  "10.0.2.0/24",<br>  "10.0.3.0/24"<br>]</pre> | no |
| <a name="input_px_grid"></a> [px\_grid](#input\_px\_grid) | n/a | `string` | `"yes"` | no |
| <a name="input_px_grid_cloud"></a> [px\_grid\_cloud](#input\_px\_grid\_cloud) | n/a | `string` | `"yes"` | no |
| <a name="input_storage_size"></a> [storage\_size](#input\_storage\_size) | Specify the storage in GB (Minimum 300GB and Maximum 2400GB). 600GB is recommended for production use, storage lesser than 600GB can be used for evaluation purpose only. On terminating the instance, volume will be deleted as well. | `string` | `"600"` | no |
| <a name="input_time_zone"></a> [time\_zone](#input\_time\_zone) | n/a | `string` | `"UTC"` | no |
| <a name="input_vpc_cidr"></a> [vpc\_cidr](#input\_vpc\_cidr) | CIDR block for the VPC | `string` | `"10.0.0.0/16"` | no |
| <a name="input_vpc_name"></a> [vpc\_name](#input\_vpc\_name) | Name tag for the VPC | `string` | `"cisco_ise"` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->