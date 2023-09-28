
resource "aws_lambda_function" "pip_layer_lambda" {
  function_name = var.function_name
  handler       = "index.handler"
  memory_size   = 1024
  role          = aws_iam_role.pip_layer_lambda_role.arn
  runtime       = "python3.9"
  timeout       = 300
  filename      = "${path.module}/index.zip"




}


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

resource "aws_cloudwatch_log_group" "lambda_logs" {
  name = "/aws/lambda/test-tf-ISE-Lambda"
}

# resource "aws_lambda_layer_version" "cisco_ise_layer" {
#   layer_name          = var.layer_name
#   compatible_runtimes = ["python3.9"]
#   description         = "Create layers based on pip"
#   filename            = "${path.module}/piplayer.zip"
# }

/* resource "custom_resource_type" "cisco_ise_custom_resource" {
  service_token = aws_lambda_function.pip_layer_lambda.arn

  # Pass necessary parameters to your custom resource
  region       = var.aws_region
  layer_name   = aws_lambda_layer_version.cisco_ise_layer.layer_name
  packages     = var.packages
} */
