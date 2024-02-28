resource "aws_iam_role" "check_sync_status_execution_role" {
  name = "CheckSyncStatusExecutionRole"

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

resource "aws_iam_policy_attachment" "lambda_policy_attachment" {
  name       = "check_sync_status_lambda-policy-attachment"
  policy_arn = aws_iam_policy.lambda_policy.arn
  roles      = [aws_iam_role.check_sync_status_execution_role.name]
}

resource "aws_iam_policy" "lambda_policy" {
  name        = "CheckSyncStatusLambdaPolicy"
  description = "IAM policy for the CheckSyncStatusLambda function"

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
          "ssm:PutParameter"

        ],
        Effect   = "Allow",
        Resource = ["*"]
      },
     
    ]
  })
}




