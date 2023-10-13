resource "aws_lambda_function" "pip_layer_lambda" {
  function_name = var.function_name
  handler       = "index.handler"
  memory_size   = 1024
  role          = aws_iam_role.pip_layer_lambda_role.arn
  runtime       = "python3.9"
  timeout       = 300
  filename      = "${path.module}/RegisterPSNNodesLambda.zip"
  vpc_config {
    subnet_ids         = var.subnet_ids
    security_group_ids = var.security_group_ids
  }
  layers = [var.layer_arn]
}

resource "aws_cloudwatch_log_group" "lambda_logs" {
  name = "/aws/lambda/TF-ISE-${var.function_name}"
}