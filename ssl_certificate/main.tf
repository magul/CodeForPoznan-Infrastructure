variable "domain" {
  type = string
}

variable "route53_zone" {}

resource "aws_acm_certificate" "certificate" {
  domain_name       = var.domain
  validation_method = "DNS"
}

resource "aws_route53_record" "certificate_validation_record" {
  for_each = {
    for dvo in aws_acm_certificate.certificate.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  name    = each.value.name
  type    = each.value.type
  zone_id = var.route53_zone.id
  records = [each.value.record]
  ttl     = 60

  depends_on = [
    aws_acm_certificate.certificate,
    var.route53_zone,
  ]
}

resource "aws_acm_certificate_validation" "certificate_validation" {
  certificate_arn = aws_acm_certificate.certificate.arn
  validation_record_fqdns = [
    for record in aws_route53_record.certificate_validation_record : record.fqdn
  ]

  depends_on = [
    aws_route53_record.certificate_validation_record
  ]
}

output "certificate" {
  value     = aws_acm_certificate.certificate
  sensitive = true
}
