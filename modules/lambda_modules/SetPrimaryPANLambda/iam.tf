resource "aws_iam_role" "pip_layer_lambda_role" {
  name = "${var.function_name}-Role"

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
  name        = "${var.function_name}-Policy"
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
          "ssm:GetParameter"
        ],
        Effect   = "Allow",
        Resource = ["*"]
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
  name       = "${var.function_name}-lambda-policy-attachment"
  policy_arn = aws_iam_policy.lambda_policy.arn
  roles      = [aws_iam_role.pip_layer_lambda_role.name]
}

# resource "aws_iam_policy" "lambda_permissions_boundary" {
#   name        = "${var.function_name}-LambdaPermissionsBoundary"
#   description = "Permissions boundary for Lambda function"

#   policy = jsonencode({
#     Version = "2012-10-17",
#     Statement = [
#       {
#         Action   = "ec2:CreateNetworkInterface", # Add this line for EC2 permissions
#         Effect   = "Allow",
#         Resource = ["*"]
#       },
#       # Add other permissions as needed
#     ]
#   })
# }