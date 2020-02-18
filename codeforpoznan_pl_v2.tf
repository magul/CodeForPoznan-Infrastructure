resource "aws_iam_user" "codeforpoznan_pl_v2" {
  name = "codeforpoznan_pl_v2"
}

resource "aws_iam_access_key" "codeforpoznan_pl_v2" {
  user = aws_iam_user.codeforpoznan_pl_v2.name
}

module codeforpoznan_pl_v2_ssl_certificate {
  source       = "./ssl_certificate"

  domain       = "codeforpoznan.pl"
  route53_zone = aws_route53_zone.codeforpoznan_pl
}

module codeforpoznan_pl_v2_frontend_assets {
  source          = "./frontend_assets"

  name            = "codeforpoznan.pl_v2"
  domain          = "codeforpoznan.pl"
  s3_bucket       = aws_s3_bucket.codeforpoznan_public
  route53_zone    = aws_route53_zone.codeforpoznan_pl
  iam_user        = aws_iam_user.codeforpoznan_pl_v2
  acm_certificate = module.codeforpoznan_pl_v2_ssl_certificate.certificate
}

resource "aws_ses_domain_identity" "codeforpoznan_pl" {
  domain = "codeforpoznan.pl"
}

resource "aws_route53_record" "codeforpoznan_pl_ses_verification_record" {
  zone_id = aws_route53_zone.codeforpoznan_pl.id
  name    = "_amazonses.${aws_ses_domain_identity.codeforpoznan_pl.domain}"
  type    = "TXT"
  ttl     = "600"
  records = [aws_ses_domain_identity.codeforpoznan_pl.verification_token]

  depends_on = [
    aws_ses_domain_identity.codeforpoznan_pl,
  ]
}

resource "aws_ses_domain_identity_verification" "codeforpoznan_pl" {
  domain = aws_ses_domain_identity.codeforpoznan_pl.domain

  depends_on = [
    aws_route53_record.codeforpoznan_pl_ses_verification_record,
  ]
}

resource "aws_iam_policy" "codeforpoznan_pl_ses_policy" {
  name = "codeforpoznan_pl_v2_lambda_execution_policy"

  policy = <<POLICY
{
  "Version":"2012-10-17",
  "Statement":[{
    "Sid":"CodeforpoznanPlV2SES",
    "Effect":"Allow",
    "Action":["ses:SendEmail", "ses:SendRawEmail"],
    "Resource":["${aws_ses_domain_identity.codeforpoznan_pl.arn}"]
  }]
}
  POLICY
}

module codeforpoznan_pl_v2_serverless_api {
  source              = "./serverless_api"

  name                = "codeforpoznan.pl_v2"
  runtime             = "nodejs10.x"
  handler             = "contact_me.handler"
  s3_bucket           = aws_s3_bucket.codeforpoznan_lambdas
  iam_user            = aws_iam_user.codeforpoznan_pl_v2
  additional_policies = [aws_iam_policy.codeforpoznan_pl_ses_policy]
}
