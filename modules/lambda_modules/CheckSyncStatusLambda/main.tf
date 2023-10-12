resource "aws_lambda_function" "check_sync_status_lambda" {
  function_name = var.function_name
  description   = "Checks for Successful  Deployment until Sync Completes between ISENodes"
  handler       = "index.handler"
  runtime       = "python3.9"
  memory_size   = 1024
  timeout       = 600

  filename = "${path.module}/CheckSyncStatusLambda.zip"
  role     = aws_iam_role.check_sync_status_execution_role.arn

  vpc_config {
    subnet_ids         = var.subnet_ids
    security_group_ids = var.security_group_ids
  }
  layers = [var.layer_arn]

}

resource "aws_cloudwatch_log_group" "lambda_logs" {
  name = "/aws/lambda/test-tf-ISE-${var.function_name}"
}