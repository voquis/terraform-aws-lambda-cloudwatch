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
  source_code_hash  = var.source_code_hash
  image_uri         = var.image_uri
  package_type      = var.package_type
  timeout           = var.timeout

  dynamic "vpc_config" {
    for_each = var.vpc_config == null ? [] : [var.vpc_config]
    content {
      subnet_ids         = vpc_config.value["subnet_ids"]
      security_group_ids = vpc_config.value["security_group_ids"]
    }
  }

  dynamic "snap_start" {
    for_each = var.snap_start == null ? [] : [var.snap_start]
    content {
      apply_on = snap_start.value["apply_on"]
    }
  }

  dynamic "environment" {
    for_each = var.variables == null ? [] : [var.variables]
    content {
      variables = var.variables
    }
  }
}
