## Terraform directory structure

Below is the cloned repository directory structure
```
.
├── examples
│   ├── create-ec2-with-existing-vpc
│   │   ├── main.tf
│   │   ├── variables.tf
│   |   ├── backend.tf
│   │   └── README.md
│   └── create-ec2-with-new-vpc
│       ├── main.tf
│       ├── variables.tf
│       ├── backend.tf
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
│       └── PipLayerLambda
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
│       │   ├── CheckISEStatusLambda.zip
│       │   └── CheckISEStatusLambda_test.zip
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
│       │   └── index.zip
│       ├── RegisterPSNNodesLambda
│       │   ├── main.tf
│       │   ├── iam.tf
│       │   ├── variables.tf
│       │   ├── versions.tf
│       │   ├── outputs.tf
│       │   ├── index.py
│       │   └── index.zip
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