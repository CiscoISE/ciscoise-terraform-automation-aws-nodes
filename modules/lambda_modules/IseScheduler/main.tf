resource "aws_scheduler_schedule" "ise-scheduler" {
  name = var.scheduler_name

  flexible_time_window {
    mode = "OFF"
  }

  schedule_expression = var.schedule_time
  state               = var.scheduler_state

  target {
    arn      = var.step_function_arn
    role_arn = aws_iam_role.scheduler_role.arn
    retry_policy {
      maximum_event_age_in_seconds = var.retry_time
      maximum_retry_attempts       = var.retry_attempts
    }
  }
}