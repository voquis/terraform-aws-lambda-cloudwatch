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
