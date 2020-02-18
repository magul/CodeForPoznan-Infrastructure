resource "aws_iam_user" "presentations" {
  name = "presentations"
}

resource "aws_iam_access_key" "presentations" {
  user = aws_iam_user.presentations.name
}

module presentations_ssl_certificate {
  source       = "./ssl_certificate"

  domain       = "slides.codeforpoznan.pl"
  route53_zone = aws_route53_zone.codeforpoznan_pl
}

module presentations_frontend_assets {
  source          = "./frontend_assets"

  name            = "Presentations"
  domain          = "slides.codeforpoznan.pl"
  s3_bucket       = aws_s3_bucket.codeforpoznan_public
  route53_zone    = aws_route53_zone.codeforpoznan_pl
  iam_user        = aws_iam_user.presentations
  acm_certificate = module.presentations_ssl_certificate.certificate
}
