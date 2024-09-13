Lambda Function with CloudWatch logging and alarm
===
Terraform module to provision a lambda function from an S3 bucket or ECR with minimum permissions to create log streams in a CloudWatch log group.
Optionally, a cloudwatch alarm for invocation failures is also created.
This module may deploy a lambda function via one of the following methods:
- A path to an S3 object of the lambda function in a zip file
- Docker image in an elastic container registry (ECR)

To specify VPC configuration, supply the optional `vpc_subnet_ids` and `vpc_security_group_ids` together

If using a Java runtime deployed from a Zip file, SnapStart may be used to accelerate startup by setting the optional `snap_start` block, e.g:
```terraform
  snap_start = {
    apply_on = "PublishedVersions"
  }
```

To skip the creation of CloudWatch Metric Alarms, set `create_alarm` to `false`.

## Examples

Lambda Functions from a single local python file with no alerting (create and update path to `app.py`):
```terraform

provider "aws" {
  version = "2.65.0"
}

# zip archive of local python file
# Ensure tmp/*.zip is added to .gitignore
data "archive_file" "lambda" {
  type             = "zip"
  source_file      = "${path.module}/../../../../../apps/python/api/app.py"
  output_path      = "${path.module}/tmp/api.zip"
  output_file_mode = "0666"
}

module "lambda" {
  source           = "voquis/lambda-cloudwatch/aws"
  version          = "1.0.1"
  filename         = data.archive_file.lambda.output_path
  source_code_hash = data.archive_file.lambda.output_base64sha256
  function_name    = "python-lambda"
  handler          = "app.lambda_handler"
  runtime          = "python3.12"
  role_name        = "python-lambda"
  timeout          = 300


  # Optional VPC configuration (for example from a vpc_module)
  vpc_subnet_ids = module.my_vpc.subnets[*].id
  vpc_security_group_ids = [
      aws_security_group.my_sg_1.id,
      aws_security_group.my_sg_2.id
  ]

  # Optional environment variables
  variables = {
    key = "value"
  }
}
```


Lambda Function from Zip folder stored in S3 bucket example, with no alarm:
```terraform

provider "aws" {
  version = "2.65.0"
}

module "lambda" {
  source        = "voquis/lambda-cloudwatch/aws"
  version       = "1.0.0"
  function_name = "myFunction"

  # Required for deployment via zip
  handler       = "main.handler"
  runtime       = "python3.8"

  # Deployment via zip file in S3 bucket
  s3_bucket     = "my-lambda-functions-bucket"
  s3_key        = "myFunction_1.2.3.zip"

  # Optional source code hash for zip
  source_code_hash = filebase64sha256("lambda.zip")

  # Optional VPC configuration (for example from a vpc_module)
  vpc_subnet_ids = module.my_vpc.subnets[*].id
  vpc_security_group_ids = [
      aws_security_group.my_sg_1.id,
      aws_security_group.my_sg_2.id
  ]

  # Optional environment variables
  variables = {
    key = "value"
  }
}
```

Lambda Functions from Container Image stored on AWS ECR example, with invocation failure alarm notifications sent to an SNS topic:
```terraform

provider "aws" {
  version = "2.65.0"
}

# Create an SNS topic that may be used e.g. for PagerDuty CloudWatch Alarms integration
resource "aws_sns_topic" "lambda_failures" {
  name = "lambda-invocation-failures"
}

module "lambda" {
  source        = "voquis/lambda-cloudwatch/aws"
  version       = "1.0.0"
  function_name = "myFunction"

  # Required for deployment via Image
  package_type  = "Image"

  # Deployment via Image in ECR
  image_uri     = "123456789123.dkr.ecr.eu-west-1.amazonaws.com/myImage:latest"

  # Optional VPC configuration (for example from a vpc_module)
  vpc_subnet_ids = module.my_vpc.subnets[*].id
  vpc_security_group_ids = [
      aws_security_group.my_sg_1.id,
      aws_security_group.my_sg_2.id
  ]

  # Optional environment variables
  variables = {
    key = "value"
  }

  # CloudWatch Metric Alarm configuration
  alarm_alarm_actions = [
    aws_sns_topic.lambda_failures.arn
  ]

  alarm_ok_actions = [
    aws_sns_topic.lambda_failures.arn
  ]
}
```
