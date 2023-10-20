resource "aws_sfn_state_machine" "DeploymentStateMachine" {
  name     = "DeploymentStateMachine"
  role_arn = aws_iam_role.step_function_role.arn

  definition = jsonencode({
    Comment = "AWS Step Function",
    StartAt = "InvokeCheckISEStatusLambda",
    States = {
      "InvokeCheckISEStatusLambda" = {
        Type     = "Task",
        Resource = var.check_ise_status_lambda_arn,
        Next     = "CheckIseState"
      },
      "CheckIseState": {
        Type: "Choice",
        Choices: [
          {
            Variable: "$.IseState",
            StringEquals: "running",
            Next: "InvokeSetPrimaryPANLambda"
          },
          {
            Variable: "$.IseState",
            StringEquals: "pending",
            Next: "WaitAndRetryHealthCheck"
          },
          
            {
      Variable: "$.retries",
      StringEquals: "0",
      Next: "TerminateStateMachine"
    }  
        ],
        Default: "WaitAndRetryHealthCheck"
      },
     "TerminateStateMachine": {
        Type: "Fail",
        Error: "UnhealthyState",
        Cause: "The health check resulted in an unhealthy state."
        },
      "InvokeSetPrimaryPANLambda" = {
        Type     = "Task",
        Resource = var.set_primary_pan_lambda_arn,
        Next     = "InvokeRegisterSecondaryNodeLambda"
      },
      "InvokeRegisterSecondaryNodeLambda" = {
        Type     = "Task",
        Resource = var.register_secondary_node_lambda_arn,
        Next     = "InvokeRegisterPSNNodesLambda"
      },
      "InvokeRegisterPSNNodesLambda" = {
        Type     = "Task",
        Resource = var.register_psn_nodes_lambda_arn,
        Next     = "Wait"
      },
      "Wait" = {
        Type    = "Wait",
        Seconds = 1800,
        Next    = "InvokeCheckSyncStatusLambda"
      },
      "InvokeCheckSyncStatusLambda" = {
        Type     = "Task",
        Resource = var.check_sync_status_lambda_arn,
        End      = true,
      },
      "WaitAndRetryHealthCheck" = {
        Type    = "Wait",
        Seconds = 600, // Adjust the wait time as needed
        Next    = "InvokeCheckISEStatusLambda"
      }
    }
  })
}
