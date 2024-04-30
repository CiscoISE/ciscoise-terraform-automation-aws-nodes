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