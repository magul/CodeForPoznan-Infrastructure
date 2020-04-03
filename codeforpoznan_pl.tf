resource "aws_route53_zone" "codeforpoznan_pl" {
  name = "codeforpoznan.pl"
}

resource "aws_route53_record" "ns_codeforpoznan_pl" {
  zone_id = aws_route53_zone.codeforpoznan_pl.zone_id
  name    = aws_route53_zone.codeforpoznan_pl.name
  type    = "NS"
  ttl     = "172800"
  records = [
    "${aws_route53_zone.codeforpoznan_pl.name_servers.0}.",
    "${aws_route53_zone.codeforpoznan_pl.name_servers.1}.",
    "${aws_route53_zone.codeforpoznan_pl.name_servers.2}.",
    "${aws_route53_zone.codeforpoznan_pl.name_servers.3}.",
  ]
}

resource "aws_route53_record" "soa_codeforpoznan_pl" {
  zone_id = aws_route53_zone.codeforpoznan_pl.zone_id
  name    = aws_route53_zone.codeforpoznan_pl.name
  type    = "SOA"
  ttl     = "900"
  records = [
    "ns-1211.awsdns-23.org. awsdns-hostmaster.amazon.com. 1 7200 900 1209600 86400",
  ]
}

resource "aws_route53_record" "mx_codeforpoznan_pl" {
  zone_id = aws_route53_zone.codeforpoznan_pl.zone_id
  name    = aws_route53_zone.codeforpoznan_pl.name
  type    = "MX"
  ttl     = "300"
  records = [
    "1 aspmx.l.google.com.",
    "10 alt3.aspmx.l.google.com.",
    "10 alt4.aspmx.l.google.com.",
    "5 alt1.aspmx.l.google.com.",
    "5 alt2.aspmx.l.google.com.",
  ]
}

resource "aws_route53_record" "txt_codeforpoznan_pl" {
  zone_id = aws_route53_zone.codeforpoznan_pl.zone_id
  name    = aws_route53_zone.codeforpoznan_pl.name
  type    = "TXT"
  ttl     = "300"
  records = [
    # https://support.google.com/a/answer/6149686?hl=en&ref_topic=4487770
    "google-site-verification=vEPDPgTFVgeXWQz0ty-fgtOEKowH44Ko8MtyDHTUHRc",

    # that will be a subject of change in CodeForPoznan/Infrastructure#4
    "v=spf1 a:codeforpoznan.pl mx:codeforpoznan.pl -all",
  ]
}

# That's not working properly right now, will be fixed in CodeForPoznan/Infrastructure#51
resource "aws_route53_record" "www_codeforpoznan_pl" {
  zone_id = aws_route53_zone.codeforpoznan_pl.zone_id
  name    = "www.codeforpoznan.pl."
  type    = "CNAME"
  ttl     = "300"
  records = [
    "codeforpoznan.pl.",
  ]
}

# all records below will be subjects of change in CodeForPoznan/Infrastructure#4
# meaning that they could be probably created/defined by more sophisticated process
# using https://www.terraform.io/docs/providers/aws/r/ses_domain_dkim.html
resource "aws_route53_record" "dolmrntuhbbqc5lz3n77zqwkf6sru4yz_dkim" {
  zone_id = aws_route53_zone.codeforpoznan_pl.zone_id
  name    = "dolmrntuhbbqc5lz3n77zqwkf6sru4yz._domainkey.codeforpoznan.pl."
  type    = "CNAME"
  ttl     = "300"
  records = [
    "dolmrntuhbbqc5lz3n77zqwkf6sru4yz.dkim.amazonses.com.",
  ]
}

resource "aws_route53_record" "fwbmtvvkzjecoehe2gi4bdwowllq3n7q_dkim" {
  zone_id = aws_route53_zone.codeforpoznan_pl.zone_id
  name    = "fwbmtvvkzjecoehe2gi4bdwowllq3n7q._domainkey.codeforpoznan.pl."
  type    = "CNAME"
  ttl     = "300"
  records = [
    "fwbmtvvkzjecoehe2gi4bdwowllq3n7q.dkim.amazonses.com.",
  ]
}

resource "aws_route53_record" "zp6muzfpymdcij4o7vdjcrm2bfpioouw_dkim" {
  zone_id = aws_route53_zone.codeforpoznan_pl.zone_id
  name    = "zp6muzfpymdcij4o7vdjcrm2bfpioouw._domainkey.codeforpoznan.pl."
  type    = "CNAME"
  ttl     = "300"
  records = [
    "zp6muzfpymdcij4o7vdjcrm2bfpioouw.dkim.amazonses.com.",
  ]
}
