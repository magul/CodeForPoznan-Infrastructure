module codeforpoznan_pl_v3_user {
  source = "./user"

  name = "codeforpoznan_pl_v3"
}

module codeforpoznan_pl_v3_ssl_certificate {
  source = "./ssl_certificate"

  domain       = "dev.codeforpoznan.pl"
  route53_zone = aws_route53_zone.codeforpoznan_pl
}

module codeforpoznan_pl_v3_frontend_assets {
  source = "./frontend_assets"

  name      = "codeforpoznan.pl_v3"
  s3_bucket = aws_s3_bucket.codeforpoznan_public
  iam_user  = module.codeforpoznan_pl_v3_user.user
}

module codeforpoznan_pl_v3_cloudfront_distribution {
  source = "./cloudfront_distribution"

  name            = "codeforpoznan.pl_v3"
  domain          = "dev.codeforpoznan.pl"
  s3_bucket       = aws_s3_bucket.codeforpoznan_public
  route53_zone    = aws_route53_zone.codeforpoznan_pl
  iam_user        = module.codeforpoznan_pl_v3_user.user
  acm_certificate = module.codeforpoznan_pl_v3_ssl_certificate.certificate

  origins = {
    static_assets = {
      default     = true
      domain_name = aws_s3_bucket.codeforpoznan_public.bucket_domain_name
      origin_path = "/codeforpoznan.pl_v3"
    }
  }
}
