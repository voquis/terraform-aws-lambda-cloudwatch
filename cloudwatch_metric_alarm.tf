resource "aws_cloudwatch_metric_alarm" "this" {
  count = var.create_alarm ? 1 : 0

  alarm_name          = "lambda-failed-invocations__${var.function_name}"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "Errors"
  namespace           = "AWS/Lambda"
  period              = var.alarm_period
  statistic           = var.alarm_statistic
  threshold           = var.alarm_threshold
  alarm_description   = "${var.alarm_description} (${var.function_name})"
  actions_enabled     = var.alarm_actions_enabled
  treat_missing_data  = var.alarm_treat_missing_data
  datapoints_to_alarm = var.alarm_datapoints_to_alarm

  dimensions = {
    "FunctionName" = var.function_name
  }

  alarm_actions = var.alarm_alarm_actions
  ok_actions    = var.alarm_ok_actions
}
