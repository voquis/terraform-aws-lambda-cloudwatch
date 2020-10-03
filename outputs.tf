output "cloudwatch_log_group" {
  value = aws_cloudwatch_log_group.this
}

output "lambda_function" {
  value = aws_lambda_function.this
}

output "iam_role" {
  value = aws_iam_role.this
}

output "iam_policy_log" {
  value = aws_iam_policy.log
}

output "iam_policy_vpc" {
  value = aws_iam_policy.vpc
}
