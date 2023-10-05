terraform {
  backend "s3" {
    key     = "terraform/ec2_with_new_vpc/ec2.tfstate"
    region  = "us-east-2"
    encrypt = "true"
    # Optionally, you can specify DynamoDB table for state locking
    # dynamodb_table = "your-dynamodb-table"
  }
}
