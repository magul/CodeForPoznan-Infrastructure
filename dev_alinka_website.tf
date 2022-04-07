module "dev_alinka_website_user" {
  source = "./user"

  name = "dev_alinka_website"
}

module "dev_alinka_website_ssl_certificate" {
  source = "./ssl_certificate"

  domain       = "dev.alinka.io"
  route53_zone = aws_route53_zone.alinka_website

  providers = {
    aws = aws.north_virginia
  }
}

module "dev_alinka_website_frontend_assets" {
  source = "./frontend_assets"

  name      = "dev_alinka_website"
  s3_bucket = aws_s3_bucket.codeforpoznan_public
  iam_user  = module.dev_alinka_website_user.user
}

module "dev_alinka_website_cloudfront_distribution" {
  source = "./cloudfront_distribution"

  name            = "dev_alinka_website"
  domain          = "dev.alinka.io"
  s3_bucket       = aws_s3_bucket.codeforpoznan_public
  route53_zone    = aws_route53_zone.alinka_website
  iam_user        = module.dev_alinka_website_user.user
  acm_certificate = module.dev_alinka_website_ssl_certificate.certificate

  origins = {
    static_assets = {
      default     = true
      domain_name = aws_s3_bucket.codeforpoznan_public.bucket_domain_name
      origin_path = "/dev_alinka_website"
    }
  }
}
