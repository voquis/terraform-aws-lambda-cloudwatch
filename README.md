Lambda Function with CloudWatch logging
===
Terraform module to provision a lambda function from an S3 bucket or ECR with minimum permissions to create log streams in a CloudWatch log group.
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

## Examples
Lambda Function from Zip folder stored in S3 bucket example:
```terraform

provider "aws" {
  version = "2.65.0"
}

module "lambda" {
  source        = "voquis/lambda-cloudwatch/aws"
  version       = "0.0.8"
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

Lambda Functions from Container Image stored on AWS ECR example:
```terraform

provider "aws" {
  version = "2.65.0"
}

module "lambda" {
  source        = "voquis/lambda-cloudwatch/aws"
  version       = "0.0.8"
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
}
```

