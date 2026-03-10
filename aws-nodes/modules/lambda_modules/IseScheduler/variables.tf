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


variable "aws_region" {
  description = "The AWS region where resources will be created."
  type        = string
  default     = "us-east-1"
}

variable "scheduler_name" {
  description = "scheduler name"
  type        = string
  default     = "ise-scheduler"
}

variable "step_function_arn" {
  description = "Specify the Step function ARN"
  type        = string
}

variable "schedule_time" {
  description = "Specify the one time schedule to invoke the step function. Syntax is at(yyyy-mm-ddThh:mm:ss)"
  type        = string
  default     = "at(2023-09-25T00:00:00)"
}

variable "retry_time" {
  description = "Maximum amount of time, in seconds, to continue to make retry attempts. Ranges from 60 to 86400 seconds"
  default     = 300
}

variable "retry_attempts" {
  description = "Maximum number of retry attempts to make before the request fails. Ranges from 0 to 185"
  default     = 5
}

variable "scheduler_state" {
  description = "Specifies whether the schedule is enabled or disabled"
  default     = "ENABLED"
}



