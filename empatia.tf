module "empatia_user" {
  source = "./user"

  name = "empatia"
}

module "empatia_ssl_certificate" {
  source = "./ssl_certificate"

  domain       = "bankempatii.pl"
  route53_zone = aws_route53_zone.bankempatii_pl

  providers = {
    aws = aws.north_virginia
  }
}

module "empatia_frontend_assets" {
  source = "./frontend_assets"

  name      = "empatia"
  s3_bucket = aws_s3_bucket.codeforpoznan_public
  iam_user  = module.empatia_user.user
}

module "empatia_cloudfront_distribution" {
  source = "./cloudfront_distribution"

  name            = "empatia"
  domain          = "bankempatii.pl"
  s3_bucket       = aws_s3_bucket.codeforpoznan_public
  route53_zone    = aws_route53_zone.bankempatii_pl
  iam_user        = module.empatia_user.user
  acm_certificate = module.empatia_ssl_certificate.certificate

  origins = {
    static_assets = {
      default     = true
      domain_name = aws_s3_bucket.codeforpoznan_public.bucket_domain_name
      origin_path = "/empatia"
    }
  }
}
