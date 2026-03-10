# Automated ISE VPC setup using Terraform on AWS

This project runs terraform module to setup ISE VPC infrastructure on AWS

## Requirements
- Terraform >= 1.0.0
- AWS CLIv2

## Installations
1. To install terraform, follow the instructions as per your operating system - [Install Terraform](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli)

2. To install AWS CLIv2, follow the instructions mentioned here - [Install AWS CLIv2](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)

## Configure AWS
1. To configure and allow access to AWS account, create IAM user with least privilege access policy- [create terraform-iam-policy](./docs/terraform-policy.json)

      For more comprehensive information on configuring Identity and  Access Management You can find detailed guidance  [here](./docs/iampolicyreadme.md)

 2. create a Programmatic Access Key (AWS Access key and Secret key). Follow this document to manage access keys - [How to manage aws access keys](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_credentials_access-keys.html#Using_CreateAccessKey)

Run aws configure as below and enter the access and secret keys.

```
aws configure
AWS Access Key ID [*******************]: <Enter access key>
AWS Secret Access Key [********************]: <Enter secret key>
Default region name [us-east-2]: 

```

## Prerequisites
Before running terraform modules, follow below steps

1. Setup SSH for git, follow this documentation - [How to setup SSH for git](https://www.warp.dev/terminus/git-clone-ssh) 

2. It is mandatory to create a s3 bucket beforehand to store terraform backend state files which needs to be referenced in below [terraform init command](#terraform_init_command). Storing terraform state files in s3 provides enhanced collaboration, security and durability over keeping state files locally
  - Existing s3 bucket can be used to store the backend files. If you want to create a new bucket, Refer this documentation - [How to create a s3 bucket](https://docs.aws.amazon.com/AmazonS3/latest/userguide/create-bucket-overview.html)
  - After creating s3 bucket, make sure to update the bucket name in the [least privilege access policy](./docs/terraform-policy.json#L128)

## Run terraform modules

Please refer Below "Inputs" section and update the terraform.tfvars as per requirement. 
Once updated, run below commands to deploy the VPC stack
<a name="terraform_init_command"></a>
 ```
 terraform init --upgrade \
   -backend-config="bucket=<bucket_name>" \            # Specify the s3 bucket name created in prerequisites - step 2
   -backend-config="region=<bucket_region>" \          # Specify the s3 bucket region e.g., us-east-1 for N. Virginia
   -reconfigure
 terraform plan
 terraform apply
 ```

Type 'yes' when prompted after running terraform apply

This deployment takes approx 10 minutes to deploy.



<!-- BEGIN_TF_DOCS -->
## Inputs

:warning: **Please do not make any changes to the variables.tf file. It is recommended to only update the terraform input variables in terraform.tfvars file**

| Name | Description | Type | Default |
|------|-------------|------|---------|
| <a name="input_availability_zones"></a> [availability\_zones](#input\_availability\_zones) | List of availability zones | `list(string)` | <pre>[<br>  "us-east-2a",<br>  "us-east-2b",<br>  "us-east-2c"<br>]</pre> |
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | AWS region | `string` | `"us-east-2"` |
| <a name="input_create_eips"></a> [create\_eips](#input\_create\_eips) | Create Elastic IPs for NAT Gateways | `bool` | `true` |
| <a name="input_create_nat_gateways"></a> [create\_nat\_gateways](#input\_create\_nat\_gateways) | Create NAT Gateways for public subnets | `bool` | `true` |
| <a name="input_dhcp_domain_name"></a> [dhcp\_domain\_name](#input\_dhcp\_domain\_name) | Domain name for DHCP options | `string` | `"ec2.internal"` |
| <a name="input_dhcp_options_domain_name"></a> [dhcp\_options\_domain\_name](#input\_dhcp\_options\_domain\_name) | Domain name for DHCP options | `string` | `"example.com"` |
| <a name="input_domain_name_servers"></a> [domain\_name\_servers](#input\_domain\_name\_servers) | List of DNS servers to use | `list(string)` | <pre>[<br>  "169.254.169.253"<br>]</pre> |
| <a name="input_enable_dns_hostnames"></a> [enable\_dns\_hostnames](#input\_enable\_dns\_hostnames) | Whether to enable DNS hostnames for the VPC | `bool` | `true` |
| <a name="input_enable_dns_support"></a> [enable\_dns\_support](#input\_enable\_dns\_support) | Whether to enable DNS support for the VPC | `bool` | `true` |
| <a name="input_internet_gateway_name"></a> [internet\_gateway\_name](#input\_internet\_gateway\_name) | Name tag for the Internet Gateway | `string` | `"Cisco_ISE_IGW"` |
| <a name="input_ntp_servers"></a> [ntp\_servers](#input\_ntp\_servers) | List of NTP servers to use | `list(string)` | <pre>[<br>  "169.254.169.123"<br>]</pre> |
| <a name="input_private_subnet_cidrs"></a> [private\_subnet\_cidrs](#input\_private\_subnet\_cidrs) | List of CIDR blocks for private subnets | `list(string)` | <pre>[<br>  "10.0.11.0/24",<br>  "10.0.12.0/24",<br>  "10.0.13.0/24"<br>]</pre> |
| <a name="input_public_subnet_cidrs"></a> [public\_subnet\_cidrs](#input\_public\_subnet\_cidrs) | List of CIDR blocks for public subnets | `list(string)` | <pre>[<br>  "10.0.1.0/24",<br>  "10.0.2.0/24",<br>  "10.0.3.0/24"<br>]</pre> |
| <a name="input_region"></a> [region](#input\_region) | AWS region for the resources | `string` | `"us-east-2"` |
| <a name="input_vpc_cidr"></a> [vpc\_cidr](#input\_vpc\_cidr) | CIDR block for the VPC | `string` | `"10.0.0.0/16"` |
| <a name="input_vpc_name"></a> [vpc\_name](#input\_vpc\_name) | Name tag for the VPC | `string` | `"cisco_ise"` |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_dhcp_options_id"></a> [dhcp\_options\_id](#output\_dhcp\_options\_id) | The ID of the DHCP Options |
| <a name="output_internet_gateway_id"></a> [internet\_gateway\_id](#output\_internet\_gateway\_id) | The ID of the Internet Gateway |
| <a name="output_nat_eip_ids"></a> [nat\_eip\_ids](#output\_nat\_eip\_ids) | The IDs of the NAT Elastic IPs |
| <a name="output_nat_gateway_ids"></a> [nat\_gateway\_ids](#output\_nat\_gateway\_ids) | The IDs of the NAT Gateways |
| <a name="output_private_route_table_ids"></a> [private\_route\_table\_ids](#output\_private\_route\_table\_ids) | The IDs of the private subnet route tables |
| <a name="output_private_subnet_ids"></a> [private\_subnet\_ids](#output\_private\_subnet\_ids) | The IDs of the private subnets |
| <a name="output_public_route_table_id"></a> [public\_route\_table\_id](#output\_public\_route\_table\_id) | The ID of the public subnet route table |
| <a name="output_public_subnet_ids"></a> [public\_subnet\_ids](#output\_public\_subnet\_ids) | The IDs of the public subnets |
| <a name="output_random_string_value"></a> [random\_string\_value](#output\_random\_string\_value) | Randomly generated string |
| <a name="output_s3_vpc_endpoint_id"></a> [s3\_vpc\_endpoint\_id](#output\_s3\_vpc\_endpoint\_id) | The ID of the S3 VPC Endpoint |
| <a name="output_vpc_id"></a> [vpc\_id](#output\_vpc\_id) | The ID of the VPC |
<!-- END_TF_DOCS -->

## Destroy Infrastructure

To destroy the ISE infrastructure resources created by this module, run below commands.

`NOTE:`
Manual changes/resource creation outside this terrform module will not be tracked in the terraform state and cause issues if user needs to upgrade/destory the deployed stack. Please avoid manual changes. 
If still manual changes are needed then please keep a note of changes, revert them before making any upgrade or destroy.

```
terraform destroy -plan
terraform destroy
``` 
To know more about the destroy command, please refer this [terraform destroy](https://developer.hashicorp.com/terraform/cli/commands/destroy) page

If you encounter issues with the `terraform destroy` command, attempt to run the command again. Additionally, you can track the resources managed by Terraform using the following command

```
terraform state list
```