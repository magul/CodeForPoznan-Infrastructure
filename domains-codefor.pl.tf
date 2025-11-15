// Domain registered in OVH by magul
resource "aws_route53_zone" "codefor_pl" {
  name = "codefor.pl"
}

resource "aws_route53_record" "mx_codefor_pl" {
  zone_id = aws_route53_zone.codefor_pl.zone_id
  name    = aws_route53_zone.codefor_pl.name
  type    = "MX"
  ttl     = "300"
  records = [
    "1 aspmx.l.google.com.",
    "10 aspmx2.googlemail.com.",
    "10 aspmx3.googlemail.com.",
    "5 alt1.aspmx.l.google.com.",
    "5 alt2.aspmx.l.google.com.",
  ]
}


resource "aws_route53_record" "txt_codefor_pl" {
  zone_id = aws_route53_zone.codefor_pl.zone_id
  name    = aws_route53_zone.codefor_pl.name
  type    = "TXT"
  ttl     = "300"
  records = [
    # https://support.google.com/a/answer/6149686?hl=en&ref_topic=4487770
    "google-site-verification=M4OHmWlfMmlVgWYnR7Z7AzwvYkcrVEhRZLgsuURL9DI",
  ]
}
