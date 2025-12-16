resource "aws_route53_record" "pah_fm" {
  zone_id = aws_route53_zone.codeforpoznan_pl.zone_id
  name    = "pahfm.codeforpoznan.pl."
  type    = "A"
  ttl     = "300"
  records = [
    "104.45.45.190",
  ]
}

resource "aws_route53_record" "wildcard_pah_fm" {
  zone_id = aws_route53_zone.codeforpoznan_pl.zone_id
  name    = "*.pahfm.codeforpoznan.pl."
  type    = "A"
  ttl     = "300"
  records = [
    "104.45.45.190",
  ]
}
