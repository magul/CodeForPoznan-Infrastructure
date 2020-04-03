resource "aws_route53_record" "pah_fm" {
  zone_id = aws_route53_zone.codeforpoznan_pl.zone_id
  name    = "pahfm.codeforpoznan.pl."
  type    = "A"
  ttl     = "300"
  records = [
    "52.232.62.212",
  ]
}

resource "aws_route53_record" "wildcard_pah_fm" {
  zone_id = aws_route53_zone.codeforpoznan_pl.zone_id
  name    = "*.pahfm.codeforpoznan.pl."
  type    = "A"
  ttl     = "300"
  records = [
    "52.232.62.212",
  ]
}
