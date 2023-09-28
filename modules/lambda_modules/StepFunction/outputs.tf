output "step_function_arn" {
  description = "ARN of the Step function"
  value       = aws_sfn_state_machine.DeploymentStateMachine.arn
}