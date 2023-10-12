output "lambda_function_arn" {
  description = "The ARN of the CheckSyncStatusLambda function"
  value       = aws_lambda_function.check_sync_status_lambda.arn
}
