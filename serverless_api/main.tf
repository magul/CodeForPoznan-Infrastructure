variable "name" {
  type = string
}
variable "runtime" {
  type = string
}
variable "handler" {
  type = string
}
variable "subnets" {
  type    = list(any)
  default = []
}
variable "security_groups" {
  type    = list(any)
  default = []
}
variable "envvars" {
  type    = map(any)
  default = {}
}

variable "s3_bucket" {}
variable "iam_user" {}
variable "additional_policies" {
  type    = list(any)
  default = []
}

module "lambda" {
  source = "../lambda"

  name                = "${var.name}_serverless_api"
  runtime             = var.runtime
  handler             = var.handler
  additional_policies = var.additional_policies
  s3_bucket           = var.s3_bucket
  iam_user            = var.iam_user
  subnets             = var.subnets
  security_groups     = var.security_groups
  envvars             = var.envvars
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
  uri                     = module.lambda.function.invoke_arn
  integration_http_method = "POST"

  depends_on = [
    aws_api_gateway_method.root_method,
    module.lambda.function,
  ]
}

resource "aws_api_gateway_resource" "proxy_resource" {
  rest_api_id = aws_api_gateway_rest_api.rest_api.id
  parent_id   = aws_api_gateway_rest_api.rest_api.root_resource_id
  path_part   = "{proxy+}"
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
  uri                     = module.lambda.function.invoke_arn
  type                    = "AWS_PROXY"
  integration_http_method = "POST"

  depends_on = [
    aws_api_gateway_method.proxy_method,
    module.lambda.function,
  ]
}

resource "aws_api_gateway_deployment" "deployment" {
  rest_api_id = aws_api_gateway_rest_api.rest_api.id
  stage_name  = "devel"

  depends_on = [
    aws_api_gateway_integration.root_integration,
    aws_api_gateway_integration.proxy_integration,
  ]
}

resource "aws_lambda_permission" "permission" {
  function_name = module.lambda.function.function_name
  statement_id  = "${replace(title(replace(var.name, "/[\\._]/", " ")), " ", "")}Invoke"
  action        = "lambda:InvokeFunction"
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${replace(aws_api_gateway_deployment.deployment.execution_arn, "devel", "")}*/*"
}

output "deployment" {
  value = aws_api_gateway_deployment.deployment
}
