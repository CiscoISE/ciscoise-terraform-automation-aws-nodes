## Terraform directory structure

Below is the cloned repository directory structure
```
.
├── examples
│   ├── create-ec2-with-existing-vpc
│   │   ├── main.tf
│   │   ├── variables.tf
│   |   ├── backend.tf
│   |   ├── terraform.tfvars
│   |   ├── outputs.tf
│   |   ├── providers.tf
│   │   └── README.md
│   └── create-ec2-with-new-vpc
│       ├── main.tf
│       ├── variables.tf
│       ├── backend.tf
│       ├── terraform.tfvars
│       ├── outputs.tf
│       ├── providers.tf
│       └── README.md
├── modules
│   ├── ec2_modules
│   │   ├── main.tf
│   │   ├── nlb.tf
│   │   ├── route53.tf
│   │   ├── ssm_parameter.tf
│   │   ├── userdata.tftpl
│   │   ├── variables.tf
│   │   ├── locals.tf
│   │   ├── versions.tf
│   │   └── outputs.tf
│   └── lambda_modules
│       ├── PipLayerLambda
│       │   ├── main.tf
│       │   ├── variables.tf
│       │   ├── versions.tf
│       │   ├── outputs.tf
│       │   ├── index.py
│       │   └── index.zip
│       ├── CheckISEStatusLambda
│       │   ├── main.tf
│       │   ├── iam.tf
│       │   ├── variables.tf
│       │   ├── versions.tf
│       │   ├── outputs.tf
│       │   ├── index.py
│       │   └── CheckISEStatusLambda.zip
│       ├── SetPrimaryPANLambda
│       │   ├── main.tf
│       │   ├── iam.tf
│       │   ├── variables.tf
│       │   ├── versions.tf
│       │   ├── outputs.tf
│       │   ├── index.py
│       │   └── index.zip
│       ├── RegisterSecondaryNodeLambda
│       │   ├── main.tf
│       │   ├── iam.tf
│       │   ├── variables.tf
│       │   ├── versions.tf
│       │   ├── outputs.tf
│       │   ├── index.py
│       │   └── RegisterSecondaryNodeLambda.zip
│       ├── RegisterPSNNodesLambda
│       │   ├── main.tf
│       │   ├── iam.tf
│       │   ├── variables.tf
│       │   ├── versions.tf
│       │   ├── outputs.tf
│       │   ├── index.py
│       │   └── RegisterPSNNodesLambda.zip
│       ├── CheckSyncStatusLambda
│       │   ├── main.tf
│       │   ├── iam.tf
│       │   ├── variables.tf
│       │   ├── outputs.tf
│       │   ├── index.py
│       │   └── CheckSyncStatusLambda.zip
│       ├── StepFunction
│       │   ├── main.tf
│       │   ├── iam.tf
│       │   ├── variables.tf
│       │   ├── versions.tf
│       │   └── outputs.tf
│       ├── IseScheduler
│       │   ├── main.tf
│       │   ├── variables.tf
│       │   ├── versions.tf
│       │   └── outputs.tf
└── README.md
```
