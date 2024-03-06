# Define IAM role for Lambda function
resource "aws_iam_role" "lambda_role" {
  name = "MyLambdaRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Effect = "Allow",
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

# Attach policies to the IAM role if needed
resource "aws_iam_policy_attachment" "lambda_policy_attachment" {
  name       = "checkisestatuslambda-policy-attachment"
  policy_arn = aws_iam_policy.lambda_policy.arn
  roles      = [aws_iam_role.lambda_role.name]
}

resource "aws_iam_policy" "lambda_policy" {
  name        = "MyLambdaPolicy"
  description = "IAM policy for the Lambda function"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "ec2:CreateNetworkInterface",
          "ec2:DescribeNetworkInterfaces",
          "ec2:DeleteNetworkInterface",
          "ssm:GetParameter",
          "ssm:PutParameter",
          "ssm:DescribeParameters",
          "tag:GetResources"

        ],
        Effect   = "Allow",
        Resource = ["*"]
      },

    ]
  })
}

resource "aws_iam_policy" "lambda_permissions_boundary" {
  name        = "LambdaPermissionsBoundary"
  description = "Permissions boundary for Lambda function"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action   = "ec2:CreateNetworkInterface",
        Effect   = "Allow",
        Resource = ["*"]
      },

    ]
  })
}





