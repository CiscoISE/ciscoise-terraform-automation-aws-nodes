# Copyright 2024 Cisco Systems, Inc. and its affiliates
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# SPDX-License-Identifier: Apache-2.0

resource "aws_sfn_state_machine" "DeploymentStateMachine" {
  name     = "DeploymentStateMachine"
  role_arn = aws_iam_role.step_function_role.arn

  definition = jsonencode({
    Comment = "AWS Step Function",
    StartAt = "Explicit Wait for ISE boot start",
    States = {
      "Explicit Wait for ISE boot start" = {
        Type    = "Wait",
        Seconds = 1500,
        Next    = "InvokeCheckISEStatusLambda"
      },
      "InvokeCheckISEStatusLambda" = {
        Type     = "Task",
        Resource = var.check_ise_status_lambda_arn,
        Next     = "CheckIseState",
        Catch : [
          {
            "ErrorEquals" : ["Lambda.Unknown"],
            "Next" : "WaitAndRetryHealthCheck"
          }
        ]
      },
      "CheckIseState" : {
        Type : "Choice",
        Choices : [
          {
            Variable : "$.IseState",
            StringEquals : "running",
            Next : "InvokeSetPrimaryPANLambda"
          },
          {
            Variable : "$.retries",
            StringEquals : "10",
            Next : "TerminateStateMachine"
          },
          {
            Variable : "$.IseState",
            StringEquals : "pending",
            Next : "WaitAndRetryHealthCheck"
          },

        ],
        Default : "WaitAndRetryHealthCheck"
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
        Next     = "CheckPSNState",
        Catch : [
          {
            "ErrorEquals" : ["Lambda.Unknown"],
            "Next" : "WaitAndRetryPSN"
          }
        ]
      },
      "CheckPSNState" : {
        Type : "Choice",
        Choices : [
          {
            Variable : "$.PSNState",
            StringEquals : "running",
            Next : "InvokeCheckSyncStatusLambda"
          },
          {
            Variable : "$.retries",
            StringEquals : "10",
            Next : "TerminateStateMachine"
          },
          # {
          #   Variable : "$.PSNState",
          #   StringEquals : "pending",
          #   Next : "WaitAndRetryHealthCheck"
          # },

        ],
        Default : "WaitAndRetryPSN"
      },
      "InvokeCheckSyncStatusLambda" = {
        Type     = "Task",
        Resource = var.check_sync_status_lambda_arn,
        Next     = "CheckSyncStatus",
        Catch : [
          {
            ErrorEquals : ["Lambda.Unknown"],
            Next : "WaitAndRetrySyncStatusCheck"
          }
        ],
      },
      "CheckSyncStatus" : {
        Type : "Choice",
        Choices : [
          {
            Variable : "$.SyncStatus",
            StringEquals : "SYNC_COMPLETED",
            Next : "SyncCOMPLETED"
          },
          {
            Variable : "$.SyncStatus",
            StringEquals : "SYNC_FAILED",
            Next : "SyncFailed"
          },
          {
            Variable : "$.SyncStatus",
            StringEquals : "SYNC_INPROGRESS",
            Next : "WaitAndRetrySyncStatusCheck"
          },
          {
            Variable : "$.SyncStatus",
            StringEquals : "TIMED_OUT",          // Handle the response indicating a timeout
            Next : "WaitAndRetrySyncStatusCheck" // Transition to the retry state
          },
        ],
        Default : "TerminateStateMachine",
      },
      "SyncFailed" : {
        Type : "Fail",
        Error : "SyncFailed",
        Cause : "The health check resulted in a failed state.",
      },
      "SyncCOMPLETED" : {
        Type : "Succeed",
      },
      "WaitAndRetrySyncStatusCheck" : {
        Type    = "Wait",
        Seconds = 600, // Adjust the wait time as needed
        Next    = "InvokeCheckSyncStatusLambda",
      },
      "WaitAndRetryHealthCheck" = {
        Type    = "Wait",
        Seconds = 600, // Adjust the wait time as needed
        Next    = "InvokeCheckISEStatusLambda"
      },
      "WaitAndRetryPSN" = {
        Type    = "Wait",
        Seconds = 30, // Adjust the wait time as needed
        Next    = "InvokeRegisterPSNNodesLambda"
      },
      "TerminateStateMachine" : {
        Type : "Fail",
        Error : "UnhealthyState",
        Cause : "The health check resulted in an unhealthy state."
      },
    },
  })
} 