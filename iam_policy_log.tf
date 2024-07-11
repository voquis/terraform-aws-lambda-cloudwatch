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
      "${aws_cloudwatch_log_group.this.arn}:log-stream:*"
    ]
  }
}

resource "aws_iam_role_policy_attachment" "log" {
  role       = aws_iam_role.this.name
  policy_arn = aws_iam_policy.log.arn
}
