variable domain {
  type = string
}

variable route53_zone { }

provider "aws" {
  alias   = "north_virginia"
  region  = "us-east-1"
  profile = "codeforpoznan"
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

output "certificate" {
  value = aws_acm_certificate.certificate
}
