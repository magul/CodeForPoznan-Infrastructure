// Domain registered in OVH by magul
resource "aws_route53_zone" "alinka_io" {
  name = "alinka.io"
}

moved {
  from = aws_route53_zone.alinka_website
  to   = aws_route53_zone.alinka_io
}

removed {
  from = aws_route53_record.ns_alinka_website

  lifecycle {
    destroy = false
  }
}

removed {
  from = aws_route53_record.soa_alinka_website

  lifecycle {
    destroy = false
  }
}
