
resource "aws_security_group" "my_lambda_sg" {
  name        = "my-lambda-sg"
  description = "Security group for Lambda function"
  vpc_id      = var.vpc_id

  # Define your security group rules here
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
  timeout       = 600

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