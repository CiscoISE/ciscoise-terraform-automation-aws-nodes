
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
  name = "/aws/lambda/test-tf-ISE-${var.function_name}"
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
