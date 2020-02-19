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
  name               = "${var.name}_serverless_api"
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
  s3_key = "${var.name}.zip"

  role = aws_iam_role.role.arn
  handler = var.handler
  runtime = var.runtime

  depends_on = [
    aws_iam_role.role,
    aws_s3_bucket_object.bucket_object,
  ]
}

resource "aws_api_gateway_rest_api" "rest_api" {
  name = var.name
}

resource "aws_api_gateway_method" "root_method" {
  rest_api_id      = aws_api_gateway_rest_api.rest_api.id
  resource_id      = aws_api_gateway_rest_api.rest_api.root_resource_id
  http_method      = "ANY"
  authorization    = "NONE"
  api_key_required = "false"

  depends_on = [
    aws_api_gateway_rest_api.rest_api,
  ]
}

resource "aws_api_gateway_integration" "root_integration" {
  rest_api_id             = aws_api_gateway_rest_api.rest_api.id
  resource_id             = aws_api_gateway_rest_api.rest_api.root_resource_id
  http_method             = aws_api_gateway_method.root_method.http_method
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.function.invoke_arn
  integration_http_method = "ANY"

  depends_on = [
    aws_api_gateway_method.root_method,
    aws_lambda_function.function,
  ]
}

resource "aws_api_gateway_resource" "proxy_resource" {
    rest_api_id = aws_api_gateway_rest_api.rest_api.id
    parent_id = aws_api_gateway_rest_api.rest_api.root_resource_id
    path_part = "{path+}"
}

resource "aws_api_gateway_method" "proxy_method" {
  rest_api_id      = aws_api_gateway_rest_api.rest_api.id
  resource_id      = aws_api_gateway_resource.proxy_resource.id
  http_method      = "ANY"
  authorization    = "NONE"
  api_key_required = "false"

  depends_on = [
    aws_api_gateway_rest_api.rest_api,
  ]
}

resource "aws_api_gateway_integration" "proxy_integration" {
  rest_api_id             = aws_api_gateway_rest_api.rest_api.id
  resource_id             = aws_api_gateway_resource.proxy_resource.id
  http_method             = aws_api_gateway_method.proxy_method.http_method
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.function.invoke_arn
  integration_http_method = "ANY"

  depends_on = [
    aws_api_gateway_method.proxy_method,
    aws_lambda_function.function,
  ]
}

resource "aws_api_gateway_deployment" "deployment" {
  rest_api_id = aws_api_gateway_rest_api.rest_api.id
  stage_name = "devel"

  depends_on = [
    aws_api_gateway_integration.root_integration,
    aws_api_gateway_integration.proxy_integration,
  ]
}

resource "aws_lambda_permission" "permission" {
  function_name = aws_lambda_function.function.function_name
  statement_id  = "${replace(title(replace(var.name, "/[\\._]/", " ")), " ", "")}Invoke"
  action        = "lambda:InvokeFunction"
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${replace(aws_api_gateway_deployment.deployment.execution_arn, "devel", "")}*/*"
}

resource "aws_iam_policy" "policy" {
  name   = "${var.name}_serverless_api"

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

output "deployment" {
  value = aws_api_gateway_deployment.deployment
}
