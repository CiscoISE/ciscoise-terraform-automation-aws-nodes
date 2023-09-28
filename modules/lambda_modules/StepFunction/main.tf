
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
        Next     = "InvokeSetPrimaryPANLambda",
      },
      "InvokeSetPrimaryPANLambda" = {
        Type     = "Task",
        Resource = var.set_primary_pan_lambda_arn,
        Next     = "InvokeRegisterSecondaryNodeLambda",
      },
      "InvokeRegisterSecondaryNodeLambda" = {
        Type     = "Task",
        Resource = var.register_secondary_node_lambda_arn,
        Next     = "InvokeRegisterPSNNodesLambda",
      },
      "InvokeRegisterPSNNodesLambda" = {
        Type     = "Task",
        Resource = var.register_psn_nodes_lambda_arn,
        End      = true,
      },
      # "InvokeCheckSyncStatusLambda" = {
      #   Type     = "Task",
      #   Resource = module.CheckSyncStatusLambda.check_sync_status_lambda_arn,
      #   End      = true,
      # },
    },
  })
}
