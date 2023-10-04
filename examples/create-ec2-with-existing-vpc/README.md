<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.19.0 |
| <a name="provider_time"></a> [time](#provider\_time) | 0.9.1 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_CheckISEStatusLambda"></a> [CheckISEStatusLambda](#module\_CheckISEStatusLambda) | ../../modules/lambda_modules/CheckISEStatusLambda | n/a |
| <a name="module_PipLayerLambda"></a> [PipLayerLambda](#module\_PipLayerLambda) | ../../modules/lambda_modules/PipLayerLambda | n/a |
| <a name="module_RegisterPSNNodesLambda"></a> [RegisterPSNNodesLambda](#module\_RegisterPSNNodesLambda) | ../../modules/lambda_modules/RegisterPSNNodesLambda | n/a |
| <a name="module_RegisterSecondaryNodeLambda"></a> [RegisterSecondaryNodeLambda](#module\_RegisterSecondaryNodeLambda) | ../../modules/lambda_modules/RegisterSecondaryNodeLambda | n/a |
| <a name="module_SetPrimaryPANLambda"></a> [SetPrimaryPANLambda](#module\_SetPrimaryPANLambda) | ../../modules/lambda_modules/SetPrimaryPANLambda | n/a |
| <a name="module_StepFuntionExecution"></a> [StepFuntionExecution](#module\_StepFuntionExecution) | ../../modules/lambda_modules/StepFunction | n/a |
| <a name="module_TriggerLambdaSchedule"></a> [TriggerLambdaSchedule](#module\_TriggerLambdaSchedule) | ../../modules/lambda_modules/IseScheduler | n/a |
| <a name="module_TriggerSchedule"></a> [TriggerSchedule](#module\_TriggerSchedule) | ../../modules/lambda_modules/IseScheduler | n/a |
| <a name="module_cisco_ise_ec2"></a> [cisco\_ise\_ec2](#module\_cisco\_ise\_ec2) | ../../modules/ec2_modules | n/a |

## Resources

| Name | Type |
|------|------|
| [time_sleep.wait_8_minutes](https://registry.terraform.io/providers/hashicorp/time/latest/docs/resources/sleep) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_availability_zones"></a> [availability\_zones](#input\_availability\_zones) | List of availability zones | `list(string)` | <pre>[<br>  "us-east-1a",<br>  "us-east-1b",<br>  "us-east-1c"<br>]</pre> | no |
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | AWS region | `string` | `"us-east-1"` | no |
| <a name="input_dhcp_domain_name"></a> [dhcp\_domain\_name](#input\_dhcp\_domain\_name) | Domain name for DHCP options | `string` | `"ec2.internal"` | no |
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
| <a name="input_subnet_id_list"></a> [subnet\_id\_list](#input\_subnet\_id\_list) | List of subnet IDs to launch resources in. The list should contain subnet id's in following order - ["subnetid in A AZ", "subnetid in B AZ", "subnetid in C AZ"] | `list(string)` | <pre>[<br>  "subnet-045716712cef0ea64",<br>  "subnet-00951b7d1a25cd789",<br>  "subnet-00c1fd9e924862a07"<br>]</pre> | no |
| <a name="input_time_zone"></a> [time\_zone](#input\_time\_zone) | n/a | `string` | `"UTC"` | no |
| <a name="input_vpc_cidr"></a> [vpc\_cidr](#input\_vpc\_cidr) | CIDR block for the VPC | `string` | `"10.0.0.0/16"` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | VPC ID | `string` | `"vpc-057efe0e8a68a3b55"` | no |
| <a name="input_vpc_name"></a> [vpc\_name](#input\_vpc\_name) | Name tag for the VPC | `string` | `"cisco_ise"` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->