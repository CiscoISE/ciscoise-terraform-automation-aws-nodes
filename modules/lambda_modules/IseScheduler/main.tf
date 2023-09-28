
provider "aws" {
  region = var.aws_region
}

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

resource "aws_iam_role" "scheduler_role" {
  name_prefix = "ise-scheduler-role"
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "Statement1",
        "Effect" : "Allow",
        "Principal" : {
          "Service" : [
            "events.amazonaws.com",
            "scheduler.amazonaws.com"
          ]
        },
        "Action" : "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_policy" "scheduler_policy" {
  name_prefix = "ise-scheduler-policy"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "states:*",
          "lambda:*"
        ],
        Effect   = "Allow",
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "scheduler_policy_attachment" {
  policy_arn = aws_iam_policy.scheduler_policy.arn
  role       = aws_iam_role.scheduler_role.name
}





