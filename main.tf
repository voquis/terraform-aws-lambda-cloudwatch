terraform {
  required_version = ">= 0.12"
}

# ---------------------------------------------------------------------------------------------------------------------
# Create Lambda function
# Provider Docs: https://www.terraform.io/docs/providers/aws/r/lambda_function.html
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_lambda_function" "this" {
  function_name     = var.function_name
  handler           = var.handler
  memory_size       = var.memory_size
  role              = aws_iam_role.this.arn
  runtime           = var.runtime
  s3_bucket         = var.s3_bucket
  s3_key            = var.s3_key
  s3_object_version = var.s3_object_version
  timeout           = var.timeout
}

# ---------------------------------------------------------------------------------------------------------------------
# Create trusted IAM Role for Lambda function to execute by assuming role
# Provider Docs: https://www.terraform.io/docs/providers/aws/r/iam_role.html
# Data Docs: https://www.terraform.io/docs/providers/aws/d/iam_policy_document.html
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_iam_role" "this" {
  name               = var.role_name
  assume_role_policy = data.aws_iam_policy_document.lambda.json
}

data "aws_iam_policy_document" "lambda" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# Create CloudWatch log group for Lambda log destination and attach to IAM role.
# Lambda function will try to create a log group called /aws/lambda/<function name> if it doesn't exist.
# Provider Docs: https://www.terraform.io/docs/providers/aws/r/cloudwatch_log_group.html
# Other Docs: https://docs.aws.amazon.com/lambda/latest/dg/monitoring-cloudwatchlogs.html
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_cloudwatch_log_group" "this" {
  name              = "/aws/lambda/${var.function_name}"
  retention_in_days = var.log_retention_in_days
}

# ---------------------------------------------------------------------------------------------------------------------
# Create and attach IAM policy for Lambda function to write to and create CloudWatch log streams
# Provider Docs: https://www.terraform.io/docs/providers/aws/r/iam_policy.html
# Data Docs: https://www.terraform.io/docs/providers/aws/d/iam_policy_document.html
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_iam_policy" "log" {
  name   = var.log_policy_name
  policy = data.aws_iam_policy_document.log.json
}

data "aws_iam_policy_document" "log" {
  statement {
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = [
      "arn:aws:logs:*:*:*",
    ]
  }
}

resource "aws_iam_role_policy_attachment" "this" {
  role       = aws_iam_role.this.name
  policy_arn = aws_iam_policy.log.arn
}

