variable name {
  type = string
}
variable runtime {
  type = string
}
variable handler {
  type = string
}

variable s3_bucket { }
variable iam_user { }
variable additional_policies {
  type = list
}

resource "aws_iam_role" "role" {
  name               = var.name
  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": [
            "lambda.amazonaws.com"
        ]
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
  POLICY
}

resource "aws_iam_role_policy_attachment" "role_policy_attachment" {
  role       = aws_iam_role.role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "additional_role_policy_attachment" {
  role       = aws_iam_role.role.name
  policy_arn = var.additional_policies[count.index].arn

  count      = length(var.additional_policies)
}

resource "aws_s3_bucket_object" "bucket_object" {
  bucket         = var.s3_bucket.id
  key            = "${var.name}.zip"
  // small zip with emtpy index.js
  content_base64 = "UEsDBAoAAAAAACykUFAAAAAAAAAAAAAAAAAIABwAaW5kZXguanNVVAkAAwSZSV4EmUledXgLAAEE6AMAAAToAwAAUEsBAh4DCgAAAAAALKRQUAAAAAAAAAAAAAAAAAgAGAAAAAAAAAAAAKSBAAAAAGluZGV4LmpzVVQFAAMEmUledXgLAAEE6AMAAAToAwAAUEsFBgAAAAABAAEATgAAAEIAAAAAAA=="

  depends_on = [
    var.s3_bucket,
  ]
}

resource "aws_lambda_function" "function" {
  function_name = replace(var.name, ".", "_")

  s3_bucket = var.s3_bucket.id
  s3_key = aws_s3_bucket_object.bucket_object.key

  role = aws_iam_role.role.arn
  handler = var.handler
  runtime = var.runtime

  depends_on = [
    aws_iam_role.role,
    aws_s3_bucket_object.bucket_object,
  ]
}

resource "aws_iam_policy" "policy" {
  name   = var.name

  policy = <<POLICY
{
  "Version":"2012-10-17",
  "Statement":[{
    "Sid":"${replace(title(replace(var.name, "/[\\._]/", " ")), " ", "")}S3",
    "Effect":"Allow",
    "Action":["s3:GetObject", "s3:PutObject"],
    "Resource":["${var.s3_bucket.arn}/${aws_s3_bucket_object.bucket_object.key}"]
  }, {
    "Sid":"${replace(title(replace(var.name, "/[\\._]/", " ")), " ", "")}Lambda",
    "Effect":"Allow",
    "Action":["lambda:UpdateFunctionCode"],
    "Resource":["${aws_lambda_function.function.arn}"]
  }]
}
  POLICY

  depends_on = [
    aws_s3_bucket_object.bucket_object,
  ]
}

resource "aws_iam_user_policy_attachment" "user_policy_attachment" {
  user       = var.iam_user.name
  policy_arn = aws_iam_policy.policy.arn

  depends_on = [
    aws_iam_policy.policy,
    var.iam_user,
  ]
}

output "function" {
  value = aws_lambda_function.function
}
