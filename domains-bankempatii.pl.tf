// Domain registered in OVH by magul
resource "aws_route53_zone" "bankempatii_pl" {
  name = "bankempatii.pl"
}

moved {
  from = aws_route53_zone.empatia
  to   = aws_route53_zone.bankempatii_pl
}

removed {
  from = aws_route53_record.ns_empatia

  lifecycle {
    destroy = false
  }
}

removed {
  from = aws_route53_record.soa_empatia

  lifecycle {
    destroy = false
  }
}
