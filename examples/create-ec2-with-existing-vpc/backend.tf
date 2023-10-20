terraform {
  backend "s3" {
    key     = "terraform/ec2_with_existing_vpc_1/ec2.tfstate"
    encrypt = "true"
    # Optionally, you can specify DynamoDB table for state locking
    # dynamodb_table = "your-dynamodb-table"
  }
}
