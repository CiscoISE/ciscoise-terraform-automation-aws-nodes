resource "aws_lambda_function" "pip_layer_lambda" {
  function_name = var.function_name
  handler       = "index.handler"
  memory_size   = 1024
  role          = aws_iam_role.pip_layer_lambda_role.arn
  runtime       = "python3.9"
  timeout       = 300
  filename      = "${path.module}/index.zip"
}

resource "aws_cloudwatch_log_group" "lambda_logs" {
  name = "/aws/lambda/TF-ISE-Lambda"
}