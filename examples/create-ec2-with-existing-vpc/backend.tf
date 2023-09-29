terraform {
  backend "s3" {
    bucket  = "ise-terraform-test"
    key     = "terraform/ec2_with_existing_vpc/ec2.tfstate"
    region  = "us-east-2"
    encrypt = "true"
    # Optionally, you can specify DynamoDB table for state locking
    # dynamodb_table = "your-dynamodb-table"
  }
}
