module "dev_pah_fm_user" {
  source = "./user"

  name = "dev_pah_fm"
}

module "dev_pah_fm_db" {
  source = "./database"

  name        = "dev_pah_fm"
  db_instance = aws_db_instance.db
}

resource "random_password" "dev_pah_fm_secret_key" {
  length  = 50
  special = false
}

module "dev_pah_fm_migration" {
  source = "./lambda"

  name            = "dev_pah_fm_migration"
  runtime         = "python3.10"
  handler         = "handlers.migration"
  s3_bucket       = aws_s3_bucket.codeforpoznan_lambdas
  iam_user        = module.dev_pah_fm_user.user
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
    PAH_FM_DB_USER = module.dev_pah_fm_db.user.name
    PAH_FM_DB_NAME = module.dev_pah_fm_db.database.name
    PAH_FM_DB_PASS = module.dev_pah_fm_db.password.result
    PAH_FM_DB_HOST = aws_db_instance.db.address
    BASE_URL       = "dev.pahfm.codeforpoznan.pl"
    SECRET_KEY     = random_password.dev_pah_fm_secret_key.result
  }
}

module "dev_pah_fm_ssl_certificate" {
  source = "./ssl_certificate"

  domain       = "dev.pahfm.codeforpoznan.pl"
  route53_zone = aws_route53_zone.codeforpoznan_pl

  providers = {
    aws = aws.north_virginia
  }
}

module "dev_pah_fm_frontend_assets" {
  source = "./frontend_assets"

  name      = "dev_pah_fm"
  s3_bucket = aws_s3_bucket.codeforpoznan_public
  iam_user  = module.dev_pah_fm_user.user
}

import {
  to = module.dev_pah_fm_serverless_api.aws_api_gateway_stage.stage
  id = "8sbwf5qbi1/devel"
}

module "dev_pah_fm_serverless_api" {
  source = "./serverless_api"

  name      = "dev_pah_fm"
  runtime   = "python3.10"
  handler   = "handlers.api"
  s3_bucket = aws_s3_bucket.codeforpoznan_lambdas
  iam_user  = module.dev_pah_fm_user.user

  subnets = [
    aws_subnet.private_a,
    aws_subnet.private_b,
    aws_subnet.private_c,
  ]

  security_groups = [
    aws_default_security_group.main
  ]

  envvars = {
    PAH_FM_DB_USER   = module.dev_pah_fm_db.user.name
    PAH_FM_DB_NAME   = module.dev_pah_fm_db.database.name
    PAH_FM_DB_PASS   = module.dev_pah_fm_db.password.result
    PAH_FM_DB_HOST   = aws_db_instance.db.address
    BASE_URL         = "dev.pahfm.codeforpoznan.pl"
    SECRET_KEY       = random_password.dev_pah_fm_secret_key.result
    STRIP_STAGE_PATH = "yes"
  }
}

module "dev_pah_fm_cloudfront_distribution" {
  source = "./cloudfront_distribution"

  name            = "dev_pah_fm"
  domain          = "dev.pahfm.codeforpoznan.pl"
  s3_bucket       = aws_s3_bucket.codeforpoznan_public
  route53_zone    = aws_route53_zone.codeforpoznan_pl
  iam_user        = module.dev_pah_fm_user.user
  acm_certificate = module.dev_pah_fm_ssl_certificate.certificate

  origins = {
    static_assets = {
      default     = true
      domain_name = aws_s3_bucket.codeforpoznan_public.bucket_domain_name
      origin_path = "/dev_pah_fm"
    }
    api_gateway = {
      domain_name   = regex("https://(?P<hostname>[^/?#]*)(?P<path>[^?#]*)", module.dev_pah_fm_serverless_api.stage.invoke_url).hostname
      origin_path   = regex("https://(?P<hostname>[^/?#]*)(?P<path>[^?#]*)", module.dev_pah_fm_serverless_api.stage.invoke_url).path
      custom_origin = true
    }
  }

  additional_cache_behaviors = [
    {
      path_pattern     = "api/*"
      target_origin_id = "api_gateway"
      headers          = ["Authorization"]
      max_ttl          = 0
      default_ttl      = 0
    },
    {
      path_pattern     = "admin/*"
      target_origin_id = "api_gateway"
      headers          = ["Referer"]
      max_ttl          = 0
      default_ttl      = 0
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
