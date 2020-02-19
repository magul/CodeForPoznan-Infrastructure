resource "aws_iam_user" "alinka_website" {
  name = "alinka_website"
}

resource "aws_iam_access_key" "alinka_website" {
  user = aws_iam_user.alinka_website.name
}

resource "aws_route53_zone" "alinka_website" {
    name = "alinka.io"
}

module alinka_website_ssl_certificate {
  source       = "./ssl_certificate"

  domain       = "dev.alinka.io"
  route53_zone = aws_route53_zone.alinka_website
}

module alinka_website_frontend_assets {
  source    = "./frontend_assets"

  name      = "alinka_website"
  s3_bucket = aws_s3_bucket.codeforpoznan_public
  iam_user  = aws_iam_user.alinka_website
}

module alinka_website_cloudfront_distribution {
  source          = "./cloudfront_distribution"

  name            = "alinka_website"
  domain          = "dev.alinka.io"
  s3_bucket       = aws_s3_bucket.codeforpoznan_public
  route53_zone    = aws_route53_zone.alinka_website
  iam_user        = aws_iam_user.alinka_website
  acm_certificate = module.alinka_website_ssl_certificate.certificate

  origins         = {
    static_assets = {
      default     = true
      domain_name = aws_s3_bucket.codeforpoznan_public.bucket_domain_name
      origin_path = "/alinka_website"
    }
  }
}
