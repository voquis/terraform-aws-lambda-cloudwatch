Lambda Function with CloudWatch logging
===
Terraform module to provision a lambda function from an S3 bucket with minimum permissions to create log streams in a CloudWatch log group.
This module may deploy a lambda function via one of the following methods:
- A path to an S3 object of the lambda function in a zip file
- Docker image in an elastic container registry (ECR)

To specify VPC configuration, supply the optional `vpc_subnet_ids` and `vpc_security_group_ids` together

Example:
```terraform

provider "aws" {
  version = "2.65.0"
}

module "lambda" {
  source        = "voquis/lambda-cloudwatch/aws"
  version       = "0.0.5"
  handler       = "main.handler"
  function_name = "myFunction"
  runtime       = "python3.8"

  # Deployment via ECR image
  image_uri     = "123.dkr.ecr.eu-west-2.amazonaws.com/my-image"

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

