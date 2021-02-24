terraform {
  required_version = ">= 0.12"
}

# ---------------------------------------------------------------------------------------------------------------------
# Create Lambda function
# Provider Docs: https://www.terraform.io/docs/providers/aws/r/lambda_function.html
# Dynamic block inspired by: https://github.com/hashicorp/terraform/issues/19853#issuecomment-589988711
# and: https://codeinthehole.com/tips/conditional-nested-blocks-in-terraform/
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

  dynamic "vpc_config" {
    for_each = var.vpc_config == null ? [] : [var.vpc_config]
    content {
      subnet_ids         = vpc_config.value["subnet_ids"]
      security_group_ids = vpc_config.value["security_group_ids"]
    }
  }

  dynamic "environment" {
    for_each = var.variables  == null ? [] : [var.variables]
    content {
      variables = var.variables
    }
  }
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

resource "aws_iam_role_policy_attachment" "log" {
  role       = aws_iam_role.this.name
  policy_arn = aws_iam_policy.log.arn
}

# ---------------------------------------------------------------------------------------------------------------------
# Create and attach IAM policy for Lambda function to optionally attach to VPC. Lambda execution role requires
# permissions to create and delete network interfaces
# Provider Docs: https://www.terraform.io/docs/providers/aws/r/iam_policy.html
# Data Docs: https://www.terraform.io/docs/providers/aws/d/iam_policy_document.html
# Other docs: https://ao.gl/the-provided-execution-role-does-not-have-permissions-to-call-createnetworkinterface-on-ec2/
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_iam_policy" "vpc" {
  count  = var.vpc_config == null ? 0 : 1
  name   = var.vpc_policy_name
  policy = data.aws_iam_policy_document.vpc.json
}

data "aws_iam_policy_document" "vpc" {
  statement {
    actions = [
      "ec2:DescribeNetworkInterfaces",
      "ec2:CreateNetworkInterface",
      "ec2:AttachNetworkInterface",
      "ec2:DeleteNetworkInterface",
    ]
    resources = [
      "*"
    ]
  }
}

resource "aws_iam_role_policy_attachment" "vpc" {
  count      = var.vpc_config == null ? 0 : 1
  role       = aws_iam_role.this.name
  policy_arn = aws_iam_policy.vpc[0].arn
}
