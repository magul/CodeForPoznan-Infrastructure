resource "aws_route53_zone" "alinka_website" {
  name = "alinka.io"
}

resource "aws_route53_record" "ns_alinka_website" {
  zone_id = aws_route53_zone.alinka_website.zone_id
  name    = aws_route53_zone.alinka_website.name
  type    = "NS"
  ttl     = "172800"
  records = [
    "${aws_route53_zone.alinka_website.name_servers.0}.",
    "${aws_route53_zone.alinka_website.name_servers.1}.",
    "${aws_route53_zone.alinka_website.name_servers.2}.",
    "${aws_route53_zone.alinka_website.name_servers.3}.",
  ]
}

resource "aws_route53_record" "soa_alinka_website" {
  zone_id = aws_route53_zone.alinka_website.zone_id
  name    = aws_route53_zone.alinka_website.name
  type    = "SOA"
  ttl     = "900"
  records = [
    "ns-1143.awsdns-14.org. awsdns-hostmaster.amazon.com. 1 7200 900 1209600 86400",
  ]
}
