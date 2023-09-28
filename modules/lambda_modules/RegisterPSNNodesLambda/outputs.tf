output "lambda_function_arn" {
  description = "ARN of the Lambda function"
  value       = aws_lambda_function.pip_layer_lambda.arn
}
