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


resource "aws_security_group" "my_lambda_sg" {
  name        = "my-lambda-sg"
  description = "Security group for Lambda function"
  vpc_id      = var.vpc_id


  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }


}
resource "aws_lambda_function" "CheckISEStatusLambda" {
  function_name = var.function_name
  handler       = "index.handler"
  runtime       = "python3.9"
  memory_size   = 1024
  timeout       = 900

  filename = "${path.module}/CheckISEStatusLambda.zip"
  role     = aws_iam_role.lambda_role.arn

  vpc_config {
    subnet_ids         = var.subnet_ids
    security_group_ids = var.security_group_ids
  }
  layers = [var.layer_arn]

}

resource "aws_cloudwatch_log_group" "lambda_logs" {
  name = "/aws/lambda/TF-ISE-${var.function_name}"
}