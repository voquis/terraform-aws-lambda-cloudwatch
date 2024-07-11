# ---------------------------------------------------------------------------------------------------------------------
# REQUIRED PARAMETERS
# ---------------------------------------------------------------------------------------------------------------------

variable "function_name" {
  description = "Lambda function name, must be unique in region"
  type        = string
}

variable "package_type" {
  description = "Lambda function type, e.g. Zip or Image"
  type        = string
  default     = "Zip"
}

# ---------------------------------------------------------------------------------------------------------------------
# OPTIONAL PARAMETERS
# ---------------------------------------------------------------------------------------------------------------------

variable "handler" {
  description = "Lambda function handler name, e.g. main.handler for a handler method in main.py in project root"
  type        = string
  default     = null
}

variable "runtime" {
  description = "Lambda function name, e.g. python3.8"
  type        = string
  default     = null
}

variable "s3_bucket" {
  description = "S3 bucket containing lambda function zip archive"
  type        = string
  default     = null
}

variable "s3_key" {
  description = "S3 bucket object lambda function zip archive key"
  type        = string
  default     = null
}

variable "image_uri" {
  description = "URI address for a container image stored in the ECR"
  type        = string
  default     = null
}

variable "log_policy_name" {
  description = "IAM policy name for Lambda function to write to CloudWatch log groups and streams"
  type        = string
  default     = null
}

variable "log_retention_in_days" {
  description = "Number of days to keep CloudWatch logs"
  type        = number
  default     = 30
}

variable "memory_size" {
  description = "Memory used during invocation"
  type        = number
  default     = 256
}

variable "role_name" {
  description = "Lambda function IAM Role assumed name, automatically generated if ommitted"
  type        = string
  default     = null
}

variable "timeout" {
  description = "Seconds allowed for invocation"
  type        = number
  default     = 30
}

variable "s3_object_version" {
  description = "S3 bucket object lambda function zip archive version"
  type        = string
  default     = null
}

variable "vpc_config" {
  description = "VPC subnets and security groups to allow lambda access"
  type = object({
    subnet_ids         = list(string)
    security_group_ids = list(string)
  })
  default = null
}

variable "vpc_policy_name" {
  description = "IAM policy name for Lambda function to create, attach and delete network interface for VPC attachment"
  type        = string
  default     = null
}

variable "variables" {
  description = "Environment variables passed to lambda function"
  type        = map(string)
  default     = null
}

variable "source_code_hash" {
  description = "base64-encoded SHA256 hash of the package file specified with filebase64sha256"
  type        = string
  default     = null
}

variable "snap_start" {
  description = "Lambda SnapStart for Java managed runtime zip-deployed functions"
  type = object({
    apply_on = string
  })
  default = null
}

# CloudWatch Alarm variables
variable "create_alarm" {
  description = "Whether to not create a CloudWatch Metric Alarm"
  type        = bool
  default     = true
}

variable "alarm_period" {
  description = "Alarm monitoring period in seconds"
  type        = number
  default     = 120
}

variable "alarm_evaluation_period" {
  description = "Alarm monitoring period in seconds"
  type        = number
  default     = 120
}

variable "alarm_treat_missing_data" {
  description = "How missing data should be handled"
  type        = string
  default     = "ignore"
}

variable "alarm_description" {
  description = "CloudWatch Alarm description"
  type        = string
  default     = "Lambda invocation failure"
}

variable "alarm_alarm_actions" {
  description = "CloudWatch Alarm actions for ALARM"
  type        = list(string)
  default     = []
}

variable "alarm_ok_actions" {
  description = "CloudWatch Alarm actions for OK"
  type        = list(string)
  default     = []
}

variable "alarm_threshold" {
  description = "CloudWatch Alarm threshold"
  type        = number
  default     = 0
}

variable "alarm_datapoints_to_alarm" {
  description = "CloudWatch Alarm number of datapoints to raise an alarm"
  type        = number
  default     = 1
}

variable "alarm_statistic" {
  description = "CloudWatch Alarm statistic to raise alarm"
  type        = string
  default     = "Sum"
}

variable "alarm_actions_enabled" {
  description = "CloudWatch Alarm actions enabled"
  type        = bool
  default     = true
}
