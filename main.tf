terraform {
  backend "s3" {
    bucket  = "codeforpoznan-tfstate"
    key     = "codeforpoznan.tfstate"
    profile = "codeforpoznan"
    region  = "eu-west-1"
  }
}

provider "aws" {
  region  = "eu-west-1"
  profile = "codeforpoznan"
}

provider "aws" {
  alias   = "north_virginia"
  region  = "us-east-1"
  profile = "codeforpoznan"
}

// admin users
resource "aws_iam_user" "tomasz_magulski" {
  name = "tomasz_magulski"
}

resource "aws_iam_access_key" "tomasz_magulski" {
  user = aws_iam_user.tomasz_magulski.name
}

resource "aws_iam_policy_attachment" "administrator_access" {
  name       = "AdministratorAccess"
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
  users      = [aws_iam_user.tomasz_magulski.name]
}

// shared public bucket (we will push here all static assets in separate directories)
resource "aws_s3_bucket" "codeforpoznan_public" {
  bucket = "codeforpoznan-public"

  cors_rule {
    allowed_methods = ["GET", "HEAD"]
    allowed_origins = ["*"]
  }

  policy = <<POLICY
{
  "Version":"2012-10-17",
  "Statement":[{
    "Sid":"PublicListBucket",
    "Effect":"Allow",
    "Principal": "*",
    "Action":["s3:ListBucket"],
    "Resource":["arn:aws:s3:::codeforpoznan-public"]
  }, {
    "Sid":"PublicGetObject",
    "Effect":"Allow",
    "Principal": "*",
    "Action":["s3:GetObject"],
    "Resource":["arn:aws:s3:::codeforpoznan-public/*"]
  }]
}
    POLICY
}

// DNS zone for codeforpoznan.pl
resource "aws_route53_zone" "codeforpoznan_pl" {
  name = "codeforpoznan.pl"
}

resource "aws_route53_record" "codeforpoznan_pl" {
  name    = "codeforpoznan.pl"
  type    = "A"
  zone_id = aws_route53_zone.codeforpoznan_pl.id

  alias {
    name                   = aws_cloudfront_distribution.codeforpoznan_pl_v2.domain_name
    zone_id                = aws_cloudfront_distribution.codeforpoznan_pl_v2.hosted_zone_id
    evaluate_target_health = false
  }
}

resource "aws_acm_certificate" "codeforpoznan_pl" {
  domain_name               = "codeforpoznan.pl"
  validation_method         = "DNS"
  provider                  = aws.north_virginia
}

resource "aws_route53_record" "codeforpoznan_pl_cert_validation" {
  name    = aws_acm_certificate.codeforpoznan_pl.domain_validation_options.0.resource_record_name
  type    = aws_acm_certificate.codeforpoznan_pl.domain_validation_options.0.resource_record_type
  zone_id = aws_route53_zone.codeforpoznan_pl.id
  records = [aws_acm_certificate.codeforpoznan_pl.domain_validation_options.0.resource_record_value]
  ttl     = 60
}

resource "aws_acm_certificate_validation" "codeforpoznan_pl" {
  certificate_arn         = aws_acm_certificate.codeforpoznan_pl.arn
  validation_record_fqdns = [aws_route53_record.codeforpoznan_pl_cert_validation.fqdn]
  provider                = aws.north_virginia
}
