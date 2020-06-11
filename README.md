Lambda Function with CloudWatch logging
===
Terraform module to provision a lambda function from an S3 bucket with minimum permissions to create log streams in a CloudWatch log group.
This module assumes an S3 bucket already exists containing the lambda function in a zip folder.

Example:
```terraform

provider "aws" {
  version = "2.65.0"
}

module "lambda" {
  source        = "voquis/lambda-cloudwatch/aws"
  version       = "0.0.1"
  handler       = "main.handler"
  function_name = "myFunction"
  runtime       = "python3.8"
  s3_bucket     = "my-lambda-functions-bucket"
  s3_key        = "myFunction_1.2.3.zip"
}
```

