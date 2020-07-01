module codeforpoznan_pl_v2_user {
  source = "./user"

  name = "codeforpoznan_pl_v2"
}

module codeforpoznan_pl_v2_ssl_certificate {
  source = "./ssl_certificate"

  domain       = "codeforpoznan.pl"
  route53_zone = aws_route53_zone.codeforpoznan_pl
}

module codeforpoznan_pl_v2_frontend_assets {
  source = "./frontend_assets"

  name      = "codeforpoznan.pl_v2"
  s3_bucket = aws_s3_bucket.codeforpoznan_public
  iam_user  = module.codeforpoznan_pl_v2_user.user
}

module codeforpoznan_pl_mailing_identity {
  source = "./mailing_identity"

  domain       = "codeforpoznan.pl"
  route53_zone = aws_route53_zone.codeforpoznan_pl
}

resource "aws_iam_policy" "codeforpoznan_pl_ses_policy" {
  name = "codeforpoznan_pl_v2_lambda_execution_policy"

  policy = <<POLICY
{
  "Version":"2012-10-17",
  "Statement":[{
    "Sid":"CodeforpoznanPlV2SES",
    "Effect":"Allow",
    "Action":["ses:SendEmail", "ses:SendRawEmail"],
    "Resource":["${module.codeforpoznan_pl_mailing_identity.domain_identity.arn}"]
  }]
}
  POLICY

  depends_on = [
    module.codeforpoznan_pl_mailing_identity.domain_identity,
  ]
}

module codeforpoznan_pl_v2_serverless_api {
  source = "./serverless_api"

  name                = "codeforpoznan.pl_v2"
  runtime             = "nodejs10.x"
  handler             = "contact_me.handler"
  s3_bucket           = aws_s3_bucket.codeforpoznan_lambdas
  iam_user            = module.codeforpoznan_pl_v2_user.user
  additional_policies = [aws_iam_policy.codeforpoznan_pl_ses_policy]
}

module codeforpoznan_pl_v2_cloudfront_distribution {
  source = "./cloudfront_distribution"

  name            = "codeforpoznan.pl_v2"
  domain          = "codeforpoznan.pl"
  s3_bucket       = aws_s3_bucket.codeforpoznan_public
  route53_zone    = aws_route53_zone.codeforpoznan_pl
  iam_user        = module.codeforpoznan_pl_v2_user.user
  acm_certificate = module.codeforpoznan_pl_v2_ssl_certificate.certificate

  origins = {
    static_assets = {
      default     = true
      domain_name = aws_s3_bucket.codeforpoznan_public.bucket_domain_name
      origin_path = "/codeforpoznan.pl_v2"
    }
    api_gateway = {
      domain_name   = regex("https://(?P<hostname>[^/?#]*)(?P<path>[^?#]*)", module.codeforpoznan_pl_v2_serverless_api.deployment.invoke_url).hostname
      origin_path   = regex("https://(?P<hostname>[^/?#]*)(?P<path>[^?#]*)", module.codeforpoznan_pl_v2_serverless_api.deployment.invoke_url).path
      custom_origin = true
    }
  }

  additional_cache_behaviors = [
    {
      path_pattern     = "api/*"
      target_origin_id = "api_gateway"
    }
  ]
}
