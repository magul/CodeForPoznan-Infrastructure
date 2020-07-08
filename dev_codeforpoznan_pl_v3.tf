module dev_codeforpoznan_pl_v3_user {
  source = "./user"

  name = "dev_codeforpoznan_pl_v3"
}

module dev_codeforpoznan_pl_v3_db {
  source = "./database"

  name        = "dev_codeforpoznan_pl_v3"
  db_instance = aws_db_instance.db
}

resource "random_password" "dev_codeforpoznan_pl_v3_secret_key" {
  length  = 50
  special = false
}

module dev_codeforpoznan_pl_v3_migration {
  source = "./lambda"

  name            = "dev_codeforpoznan_pl_v3_migration"
  runtime         = "python3.8"
  handler         = "handlers.migration"
  s3_bucket       = aws_s3_bucket.codeforpoznan_lambdas
  iam_user        = module.dev_codeforpoznan_pl_v3_user.user
  user_can_invoke = true

  subnets = [
    aws_subnet.private_a,
    aws_subnet.private_b,
    aws_subnet.private_c,
  ]

  security_groups = [
    aws_default_security_group.main
  ]

  envvars = {
    DB_USER     = module.dev_codeforpoznan_pl_v3_db.user.name
    DB_NAME     = module.dev_codeforpoznan_pl_v3_db.database.name
    DB_PASSWORD = module.dev_codeforpoznan_pl_v3_db.password.result
    DB_HOST     = aws_db_instance.db.address
    BASE_URL    = "dev.codeforpoznan.pl"
    SECRET_KEY  = random_password.dev_codeforpoznan_pl_v3_secret_key.result
  }
}

module dev_codeforpoznan_pl_v3_ssl_certificate {
  source = "./ssl_certificate"

  domain       = "dev.codeforpoznan.pl"
  route53_zone = aws_route53_zone.codeforpoznan_pl

  providers = {
    aws.north_virginia = aws.north_virginia
  }
}

module dev_codeforpoznan_pl_v3_frontend_assets {
  source = "./frontend_assets"

  name      = "dev_codeforpoznan_pl_v3"
  s3_bucket = aws_s3_bucket.codeforpoznan_public
  iam_user  = module.dev_codeforpoznan_pl_v3_user.user
}

module dev_codeforpoznan_pl_v3_mailing_identity {
  source = "./mailing_identity"

  domain       = "dev.codeforpoznan.pl"
  route53_zone = aws_route53_zone.codeforpoznan_pl
}

data "aws_iam_policy_document" "dev_codeforpoznan_pl_v3_ses_policy" {
  version = "2012-10-17"

  statement {
    sid       = "DevCodeforpoznanPlV3SES"
    effect    = "Allow"
    actions   = ["ses:SendEmail", "ses:SendRawEmail"]
    resources = [module.dev_codeforpoznan_pl_v3_mailing_identity.domain_identity.arn]
  }
}

resource "aws_iam_policy" "dev_codeforpoznan_pl_v3_ses_policy" {
  name       = "dev_codeforpoznan_pl_v3_ses_policy"
  policy     = data.aws_iam_policy_document.dev_codeforpoznan_pl_v3_ses_policy.json
  depends_on = [module.dev_codeforpoznan_pl_v3_mailing_identity.domain_identity]
}

module dev_codeforpoznan_pl_v3_serverless_api {
  source = "./serverless_api"

  name                = "dev_codeforpoznan_pl_v3"
  runtime             = "python3.8"
  handler             = "handlers.serverless_api"
  s3_bucket           = aws_s3_bucket.codeforpoznan_lambdas
  iam_user            = module.dev_codeforpoznan_pl_v3_user.user
  additional_policies = [aws_iam_policy.dev_codeforpoznan_pl_v3_ses_policy]

  subnets = [
    aws_subnet.private_a,
    aws_subnet.private_b,
    aws_subnet.private_c,
  ]

  security_groups = [
    aws_default_security_group.main
  ]

  envvars = {
    DB_USER          = module.dev_codeforpoznan_pl_v3_db.user.name
    DB_NAME          = module.dev_codeforpoznan_pl_v3_db.database.name
    DB_PASSWORD      = module.dev_codeforpoznan_pl_v3_db.password.result
    DB_HOST          = aws_db_instance.db.address
    BASE_URL         = "dev.codeforpoznan.pl"
    SECRET_KEY       = random_password.dev_codeforpoznan_pl_v3_secret_key.result
    STRIP_STAGE_PATH = "yes"
  }
}

module dev_codeforpoznan_pl_v3_cloudfront_distribution {
  source = "./cloudfront_distribution"

  name            = "dev_codeforpoznan_pl_v3"
  domain          = "dev.codeforpoznan.pl"
  s3_bucket       = aws_s3_bucket.codeforpoznan_public
  route53_zone    = aws_route53_zone.codeforpoznan_pl
  iam_user        = module.dev_codeforpoznan_pl_v3_user.user
  acm_certificate = module.dev_codeforpoznan_pl_v3_ssl_certificate.certificate

  origins = {
    static_assets = {
      default     = true
      domain_name = aws_s3_bucket.codeforpoznan_public.bucket_domain_name
      origin_path = "/dev_codeforpoznan_pl_v3"
    }
    api_gateway = {
      domain_name   = regex("https://(?P<hostname>[^/?#]*)(?P<path>[^?#]*)", module.dev_codeforpoznan_pl_v3_serverless_api.deployment.invoke_url).hostname
      origin_path   = regex("https://(?P<hostname>[^/?#]*)(?P<path>[^?#]*)", module.dev_codeforpoznan_pl_v3_serverless_api.deployment.invoke_url).path
      custom_origin = true
    }
  }

  additional_cache_behaviors = [
    {
      path_pattern     = "api/*"
      target_origin_id = "api_gateway"
      headers          = ["Authorization"]
    }
  ]

  custom_error_responses = [
    {
      error_code         = 404
      response_code      = 200
      response_page_path = "/index.html"
    }
  ]
}
