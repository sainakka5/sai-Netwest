provider "aws" {
  region = "us-east-1"
  access_key = "AKIAQ66JB35TRFKFLBUV"
  secret_key = "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"
}

# Variables
variable "instance_type" {
  default = "t2.micro"
}

variable "key_name" {
  default = "key"
}

variable "bucket_name" {
  default = "sai-netwest-bucket"
}

# EC2 Instance
resource "aws_instance" "example" {
  ami           = "ami-002070d43b0a4f171"
  instance_type = var.instance_type
  key_name      = var.key_name

  tags = {
    Name = "ExampleInstance"
  }
}

# IAM Role for Lambda
resource "aws_iam_role" "lambda" {
  name = "lambda_execution_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Effect": "Allow",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      }
    }
  ]
}
EOF
}
# IAM Policy for Lambda
resource "aws_iam_policy" "lambda" {
  name        = "lambda_execution_policy"
  description = "Policy for Lambda function"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "s3:GetObject",
        "s3:PutObject",
        "s3:PutBucketAcl"
      ],
      "Resource": "${aws_s3_bucket.example.arn}/*"
    }
  ]
}
EOF
}


# S3 Bucket
resource "aws_s3_bucket" "example" {
  bucket = var.bucket_name
  acl    = "private"

  website {
    index_document = "index.html"
  }
}



# Attach the Lambda Policy to the Role
resource "aws_iam_role_policy_attachment" "lambda" {
  policy_arn = aws_iam_policy.lambda.arn
  role       = aws_iam_role.lambda.name
}
# Lambda function
resource "aws_lambda_function" "example_lambda" {
  filename      = "/root/terra/lambda_function.zip"
  function_name = "S3-function"
  role          = aws_iam_role.lambda.arn
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.8"

  source_code_hash = filebase64("/root/terra/lambda_function.zip")
}
resource "aws_s3_bucket_notification" "aws-lambda-trigger" {
  bucket = aws_s3_bucket.example.id
  lambda_function {
    lambda_function_arn = aws_lambda_function.example_lambda.arn
    events              = ["s3:ObjectCreated:*", "s3:ObjectRemoved:*"]
  }
}
# Lambda Permission to Trigger on S3 Event
resource "aws_lambda_permission" "example_lambda_permission" {
  depends_on     = [aws_lambda_function.example_lambda]
  statement_id   = "AllowS3Invoke"
  action         = "lambda:InvokeFunction"
  function_name  = aws_lambda_function.example_lambda.function_name
  principal      = "s3.amazonaws.com"
  source_arn     = aws_s3_bucket.example.arn
}
