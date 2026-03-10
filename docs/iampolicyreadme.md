# AWS IAM Permissions and S3 Bucket Policy — Unified Reference

This document provides a consolidated explanation of all AWS Identity and Access Management (IAM) permissions configured in our AWS environment, covering both **EC2/Node Deployment** and **VPC Infrastructure Provisioning**.

---

## IAM Permissions

The IAM permissions defined in this policy are used to control access to various AWS services and resources. Here's a breakdown of the permissions by service:

### EC2 & VPC Permissions

- **EC2:** Permissions related to Amazon Elastic Compute Cloud instances.
- **VPC:** Permissions related to Virtual Private Cloud networking (subnets, internet gateways, NAT gateways, route tables, security groups, Elastic IPs, NACLs).

### IAM Permissions

- **IAM:** Permissions related to AWS Identity and Access Management roles, policies, and instance profiles.

### Compute & Orchestration Permissions

- **Lambda:** Permissions related to AWS Lambda functions.
- **States:** Permissions related to AWS Step Functions.
- **Scheduler:** Permissions related to the AWS Systems Manager Scheduler service.
- **Events:** Permissions related to Amazon CloudWatch Events.

### Networking & DNS Permissions

- **Route53:** Permissions related to Amazon Route 53 for DNS management.
- **Elastic Load Balancing:** Permissions related to Elastic Load Balancing for load balancer management.

### Monitoring & Management Permissions

- **Logs:** Permissions related to Amazon CloudWatch Logs.
- **SSM:** Permissions related to AWS Systems Manager for systems management tasks.

### Security & Encryption Permissions

- **KMS:** Permissions related to AWS Key Management Service for encryption key management.

### S3 Bucket Permissions

- **S3:** Permissions related to Amazon S3 bucket and object management.

---

## S3 Bucket Policy

The S3 bucket policy is used to control access to the S3 bucket named `bucket-name`. The policy includes the following actions:

- `s3:PutObject`: Allowing the addition of objects to the bucket.
- `s3:GetObject`: Allowing the retrieval of objects from the bucket.
- `s3:ListBucket`: Allowing listing the objects within the bucket.
- `s3:DeleteObject`: Allowing the deletion of objects within the bucket.

The policy grants these permissions for all objects within the specified bucket.

---

## Scope Summary

| Scope | Services Covered |
|---|---|
| **EC2 Node Deployment** | EC2, IAM, Lambda, Step Functions, Route53, CloudWatch Logs, Scheduler, ELB, Events, SSM, KMS, S3 |
| **VPC Infrastructure** | VPC, Subnets, Internet Gateways, NAT Gateways, Route Tables, Security Groups, Elastic IPs, NACLs |

---

## Note

- Maintain proper access control and only grant permissions to the necessary resources and actions.
- Regularly review and update IAM permissions and S3 bucket policies as needed to ensure security and compliance.
- Use resource-level restrictions (`Resource` ARNs) wherever possible instead of `"*"`.
