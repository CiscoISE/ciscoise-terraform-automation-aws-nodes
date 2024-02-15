resource "aws_iam_role" "pip_layer_lambda_role" {
  name = "PipLayer-ISE-Lambda-Role"

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

resource "aws_iam_policy" "lambda_policy" {
  name        = "PipLayer-ISE-Lambda-Policy"
  description = "IAM policy for the Lambda function"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Effect = "Allow",
        Resource = [
          aws_cloudwatch_log_group.lambda_logs.arn,
        ]
      },
      {
        Action = [
          "lambda:PublishLayerVersion",
          "lambda:DeleteLayerVersion"
        ],
        Effect   = "Allow",
        Resource = "*"
      }
    ]
  })
}
resource "aws_iam_policy_attachment" "lambda_policy_attachment" {
  name       = "pip-lambda-policy-attachment"
  policy_arn = aws_iam_policy.lambda_policy.arn
  roles      = [aws_iam_role.pip_layer_lambda_role.name]
}