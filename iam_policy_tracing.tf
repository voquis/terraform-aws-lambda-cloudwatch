# ---------------------------------------------------------------------------------------------------------------------
# Create and attach IAM policy for Lambda function to optionally write traces to X-ray.
# Provider Docs: https://www.terraform.io/docs/providers/aws/r/iam_policy.html
# Data Docs: https://www.terraform.io/docs/providers/aws/d/iam_policy_document.html
# Other docs: https://docs.aws.amazon.com/lambda/latest/dg/services-xray.html#services-xray-permissions
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_iam_policy" "tracing" {
  count  = var.tracing_config == null ? 0 : 1
  name   = var.tracing_policy_name
  policy = data.aws_iam_policy_document.tracing.json
}

data "aws_iam_policy_document" "tracing" {
  statement {
    actions = [
      "xray:PutTraceSegments",
      "xray:PutTelemetryRecords",
    ]
    resources = [
      "*"
    ]
  }
}

resource "aws_iam_role_policy_attachment" "tracing" {
  count      = var.tracing_config == null ? 0 : 1
  role       = aws_iam_role.this.name
  policy_arn = aws_iam_policy.tracing[0].arn
}
