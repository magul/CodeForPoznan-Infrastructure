variable domain {
  type = string
}

variable route53_zone { }

resource "aws_ses_domain_identity" "domain_identity" {
  domain = var.domain
}

resource "aws_route53_record" "identity_verification_record" {
  zone_id = var.route53_zone.id
  name    = "_amazonses.${aws_ses_domain_identity.domain_identity.domain}"
  type    = "TXT"
  ttl     = "600"
  records = [aws_ses_domain_identity.domain_identity.verification_token]

  depends_on = [
    aws_ses_domain_identity.domain_identity,
  ]
}

resource "aws_ses_domain_identity_verification" "domain_identity_verification" {
  domain = aws_ses_domain_identity.domain_identity.domain

  depends_on = [
    aws_route53_record.identity_verification_record,
  ]
}

output "domain_identity" {
  value = aws_ses_domain_identity.domain_identity
}
