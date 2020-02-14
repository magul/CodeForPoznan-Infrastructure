variable name {
  type = string
}
variable domain {
  type = string
}

variable s3_bucket { }
variable route53_zone { }
variable iam_user { }

provider "aws" {
  alias   = "north_virginia"
  region  = "us-east-1"
  profile = "codeforpoznan"
}

resource "aws_s3_bucket_object" "bucket_object" {
  bucket = var.s3_bucket.id
  key    = "${var.name}/"

  depends_on = [
    var.s3_bucket,
  ]
}

resource "aws_acm_certificate" "certificate" {
  domain_name       = var.domain
  validation_method = "DNS"
  provider          = aws.north_virginia
}

resource "aws_route53_record" "certificate_validation_record" {
  name    = aws_acm_certificate.certificate.domain_validation_options.0.resource_record_name
  type    = aws_acm_certificate.certificate.domain_validation_options.0.resource_record_type
  zone_id = var.route53_zone.id
  records = [aws_acm_certificate.certificate.domain_validation_options.0.resource_record_value]
  ttl     = 60

  depends_on = [
    aws_acm_certificate.certificate,
    var.route53_zone,
  ]
}

resource "aws_acm_certificate_validation" "certificate_validation" {
  certificate_arn         = aws_acm_certificate.certificate.arn
  validation_record_fqdns = [aws_route53_record.certificate_validation_record.fqdn]
  provider                = aws.north_virginia

  depends_on = [
    aws_route53_record.certificate_validation_record
  ]
}

resource "aws_cloudfront_distribution" "distribution" {
  origin {
    domain_name = var.s3_bucket.bucket_domain_name
    origin_path = "/${var.name}"
    origin_id   = var.name
  }

  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"
  aliases             = [var.domain]

  default_cache_behavior {
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = var.name
    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn = aws_acm_certificate.certificate.arn
    ssl_support_method  = "sni-only"
  }

  depends_on = [
    aws_s3_bucket_object.bucket_object,
    aws_acm_certificate_validation.certificate_validation,
  ]
}

resource "aws_route53_record" "main_record" {
  name    = var.domain
  type    = "A"
  zone_id = var.route53_zone.id

  alias {
    name                   = aws_cloudfront_distribution.distribution.domain_name
    zone_id                = aws_cloudfront_distribution.distribution.hosted_zone_id
    evaluate_target_health = false
  }

  depends_on = [
    aws_cloudfront_distribution.distribution
  ]
}

resource "aws_iam_policy" "policy" {
  name   = "${var.name}_frontend_assets"

  policy = <<POLICY
{
  "Version":"2012-10-17",
  "Statement":[{
    "Sid":"${replace(title(replace(var.name, "/[\\._]/", " ")), " ", "")}S3",
    "Effect":"Allow",
    "Action":["s3:DeleteObject", "s3:PutObject"],
    "Resource":["${var.s3_bucket.arn}/${aws_s3_bucket_object.bucket_object.key}*"]
  }, {
    "Sid":"${replace(title(replace(var.name, "/[\\._]/", " ")), " ", "")}CloudFront",
    "Effect":"Allow",
    "Action":["cloudfront:CreateInvalidation"],
    "Resource":["${aws_cloudfront_distribution.distribution.arn}"]
  }]
}
  POLICY

  depends_on = [
    aws_s3_bucket_object.bucket_object,
    aws_cloudfront_distribution.distribution,
  ]
}

resource "aws_iam_user_policy_attachment" "user_policy_attachment" {
  user       = var.iam_user.name
  policy_arn = aws_iam_policy.policy.arn

  depends_on = [
    aws_iam_policy.policy,
    var.iam_user,
  ]
}
