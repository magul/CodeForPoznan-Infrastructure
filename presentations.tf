module presentations_user {
  source = "./user"

  name = "presentations"
}

module presentations_ssl_certificate {
  source = "./ssl_certificate"

  domain       = "slides.codeforpoznan.pl"
  route53_zone = aws_route53_zone.codeforpoznan_pl
}

module presentations_frontend_assets {
  source = "./frontend_assets"

  name      = "Presentations"
  s3_bucket = aws_s3_bucket.codeforpoznan_public
  iam_user  = module.presentations_user.user
}

module presentations_cloudfront_distribution {
  source = "./cloudfront_distribution"

  name            = "Presentations"
  domain          = "slides.codeforpoznan.pl"
  s3_bucket       = aws_s3_bucket.codeforpoznan_public
  route53_zone    = aws_route53_zone.codeforpoznan_pl
  iam_user        = module.presentations_user.user
  acm_certificate = module.presentations_ssl_certificate.certificate

  origins = {
    static_assets = {
      default     = true
      domain_name = aws_s3_bucket.codeforpoznan_public.bucket_domain_name
      origin_path = "/Presentations"
    }
  }
}
