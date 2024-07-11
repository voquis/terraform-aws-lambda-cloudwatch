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
