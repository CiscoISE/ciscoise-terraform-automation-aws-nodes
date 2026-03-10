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

resource "aws_lambda_function" "pip_layer_lambda" {
  function_name = var.function_name
  handler       = "index.handler"
  memory_size   = 1024
  role          = aws_iam_role.pip_layer_lambda_role.arn
  runtime       = "python3.9"
  timeout       = 300
  filename      = "${path.module}/PipLayerLambda.zip"
}

resource "aws_cloudwatch_log_group" "lambda_logs" {
  name = "/aws/lambda/TF-ISE-Lambda"
}