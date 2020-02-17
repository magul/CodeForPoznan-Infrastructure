resource "aws_iam_user" "alinka_website" {
  name = "alinka_website"
}

resource "aws_iam_access_key" "alinka_website" {
  user = aws_iam_user.alinka_website.name
}

resource "aws_route53_zone" "alinka_website" {
    name = "alinka.io"
}

module alinka_website_frontend_assets {
  source       = "./frontend_assets"

  name         = "alinka_website"
  domain       = "alinka.io"
  s3_bucket    = aws_s3_bucket.codeforpoznan_public
  route53_zone = aws_route53_zone.alinka_website
  iam_user     = aws_iam_user.alinka_website
}
