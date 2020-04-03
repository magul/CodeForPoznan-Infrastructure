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

    # https://support.google.com/a/answer/60764
    # https://docs.aws.amazon.com/ses/latest/DeveloperGuide/send-email-authentication-spf.html
    "v=spf1 include:_spf.google.com include:amazonses.com ~all",
  ]
}

# https://support.google.com/a/answer/174126
resource "aws_route53_record" "dkim_google" {
  zone_id = aws_route53_zone.codeforpoznan_pl.zone_id
  name    = "google._domainkey.codeforpoznan.pl"
  type    = "TXT"
  ttl     = "300"
  records = [
    "v=DKIM1; k=rsa; p=MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAnscwqK6IZsq+HPxYzLD46THJ/LYD5Pocv67zg2QJYW040zgAkDVAyYaBgNtS6mNkifWgQtpcMn5x0DfjezBf8rzPUmbXP54TjVwgc8JEqa4d5RUDO6JCvE046KNWdHMmKpia/wm2sAS80cX\"\"9+jD8eVoOkQBT01Dt8TJsisrC5gvncNpFHk1Hl254fHc/njn7opWMTMIu1i9xSzjtttR37SnxCtI7xKecG7MtjFHpG5W98C8EefI71t5BKve+AmirGVSrNyedraVbX9JQ8S0tCwnM27+/KqFDpalV9smKkBY/m/Aewm1m7OJHnqxiwDW6/w8f3CjU1dbF/LLSYABnOQIDAQAB",
  ]
}

# https://support.google.com/a/answer/2466563
resource "aws_route53_record" "dmarc" {
  zone_id = aws_route53_zone.codeforpoznan_pl.zone_id
  name    = "_dmarc.codeforpoznan.pl"
  type    = "TXT"
  ttl     = "300"
  records = [
    "v=DMARC1; p=reject; rua=mailto:hello@codeforpoznan.pl; pct=100"
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
