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
  value = length(aws_iam_policy.vpc) > 0 ? aws_iam_policy.vpc[0] : null
}

output "cloudwatch_metric_alarm" {
  value = length(aws_cloudwatch_metric_alarm.this) > 0 ? aws_cloudwatch_metric_alarm.this[0] : null
}
