# Automated ISE setup with Infrastructure as Code using Terraform on AWS

This project runs terraform module to setup ISE infrastructure on AWS

## Requirements
- Terraform >= 1.0.0
- AWS CLIv2

## Installations
1. To install terraform, follow the instructions as per your operating system - [Install Terraform](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli)

2. To install AWS CLIv2, follow the instructions mentioned here - [Install AWS CLIv2](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)

## Configure AWS
To configure and allow access to AWS account, create IAM user and create Programmatic Access Key (AWS Access key and Secret key). Run aws configure as below and enter the access and secret keys.

```
aws configure
AWS Access Key ID [*******************]: <Enter access key>
AWS Secret Access Key [********************]: <Enter secret key>
Default region name [us-east-2]: 

```

## Run terraform modules

Clone this git repo by using this command - git clone <URL>

Choose on of the following options to setup ISE infra
1. [Deploy using an existing VPC](./examples/create-ec2-with-existing-vpc/)
2. [Deploy using a new VPC](./examples/create-ec2-with-new-vpc/)

To deploy using an existing VPC
  ```
  cd examples/create-ec2-with-existing-vpc
  ```

To deploy using a new VPC
```
cd examples/create-ec2-with-new-vpc
```

Run below commands
 ```
 terraform init --upgrade
 terraform plan
 terraform apply
 ```

Type 'yes' when prompted after running terraform apply

After setting up ISE infra using terraform, it will take 45-60 minutes for the stack to deploy and ISE application to come up


