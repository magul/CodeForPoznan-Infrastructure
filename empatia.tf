resource "aws_iam_user" "empatia" {
  name = "empatia"
}

resource "aws_iam_access_key" "empatia" {
  user = aws_iam_user.empatia.name
}

resource "aws_route53_zone" "empatia" {
  name = "bankempatii.pl"
}

resource "aws_route53_record" "ns_empatia" {
  zone_id = aws_route53_zone.empatia.zone_id
  name    = aws_route53_zone.empatia.name
  type    = "NS"
  ttl     = "172800"
  records = [
    "${aws_route53_zone.empatia.name_servers.0}.",
    "${aws_route53_zone.empatia.name_servers.1}.",
    "${aws_route53_zone.empatia.name_servers.2}.",
    "${aws_route53_zone.empatia.name_servers.3}.",
  ]
}

resource "aws_route53_record" "soa_empatia" {
  zone_id = aws_route53_zone.empatia.zone_id
  name    = aws_route53_zone.empatia.name
  type    = "SOA"
  ttl     = "900"
  records = [
    "ns-1596.awsdns-07.co.uk. awsdns-hostmaster.amazon.com. 1 7200 900 1209600 86400",
  ]
}

module empatia_ssl_certificate {
  source       = "./ssl_certificate"

  domain       = "bankempatii.pl"
  route53_zone = aws_route53_zone.empatia
}

module empatia_frontend_assets {
  source    = "./frontend_assets"

  name      = "empatia"
  s3_bucket = aws_s3_bucket.codeforpoznan_public
  iam_user  = aws_iam_user.empatia
}

module empatia_cloudfront_distribution {
  source          = "./cloudfront_distribution"

  name            = "empatia"
  domain          = "bankempatii.pl"
  s3_bucket       = aws_s3_bucket.codeforpoznan_public
  route53_zone    = aws_route53_zone.empatia
  iam_user        = aws_iam_user.empatia
  acm_certificate = module.empatia_ssl_certificate.certificate

  origins         = {
    static_assets = {
      default     = true
      domain_name = aws_s3_bucket.codeforpoznan_public.bucket_domain_name
      origin_path = "/empatia"
    }
  }
}
