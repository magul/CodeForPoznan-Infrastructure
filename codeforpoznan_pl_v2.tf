resource "aws_iam_user" "codeforpoznan_pl_v2" {
  name = "codeforpoznan_pl_v2"
}

resource "aws_iam_access_key" "codeforpoznan_pl_v2" {
  user = aws_iam_user.codeforpoznan_pl_v2.name
}

module codeforpoznan_pl_v2_frontend_assets {
  source       = "./frontend_assets"

  name         = "codeforpoznan.pl_v2"
  domain       = "codeforpoznan.pl"
  s3_bucket    = aws_s3_bucket.codeforpoznan_public
  route53_zone = aws_route53_zone.codeforpoznan_pl
  iam_user     = aws_iam_user.codeforpoznan_pl_v2
}
