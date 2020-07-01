module alinka_website_user {
  source = "./user"

  name = "alinka_website"
}

resource "aws_route53_zone" "alinka_website" {
  name = "alinka.io"
}

resource "aws_route53_record" "ns_alinka_website" {
  zone_id = aws_route53_zone.alinka_website.zone_id
  name    = aws_route53_zone.alinka_website.name
  type    = "NS"
  ttl     = "172800"
  records = [
    "${aws_route53_zone.alinka_website.name_servers.0}.",
    "${aws_route53_zone.alinka_website.name_servers.1}.",
    "${aws_route53_zone.alinka_website.name_servers.2}.",
    "${aws_route53_zone.alinka_website.name_servers.3}.",
  ]
}

resource "aws_route53_record" "soa_alinka_website" {
  zone_id = aws_route53_zone.alinka_website.zone_id
  name    = aws_route53_zone.alinka_website.name
  type    = "SOA"
  ttl     = "900"
  records = [
    "ns-1143.awsdns-14.org. awsdns-hostmaster.amazon.com. 1 7200 900 1209600 86400",
  ]
}

module alinka_website_ssl_certificate {
  source = "./ssl_certificate"

  domain       = "alinka.io"
  route53_zone = aws_route53_zone.alinka_website
}

module alinka_website_frontend_assets {
  source = "./frontend_assets"

  name      = "alinka_website"
  s3_bucket = aws_s3_bucket.codeforpoznan_public
  iam_user  = module.alinka_website_user.user
}

module alinka_website_cloudfront_distribution {
  source = "./cloudfront_distribution"

  name            = "alinka_website"
  domain          = "alinka.io"
  s3_bucket       = aws_s3_bucket.codeforpoznan_public
  route53_zone    = aws_route53_zone.alinka_website
  iam_user        = module.alinka_website_user.user
  acm_certificate = module.alinka_website_ssl_certificate.certificate

  origins = {
    static_assets = {
      default     = true
      domain_name = aws_s3_bucket.codeforpoznan_public.bucket_domain_name
      origin_path = "/alinka_website"
    }
    google_form = {
      domain_name   = "docs.google.com"
      origin_path   = ""
      custom_origin = true
    }
  }

  additional_cache_behaviors = [
    {
      path_pattern     = "forms/*"
      target_origin_id = "google_form"
    }
  ]
}
