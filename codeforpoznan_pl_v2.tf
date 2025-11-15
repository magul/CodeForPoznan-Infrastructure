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

module "codeforpoznan_pl_ssl_certificate" {
  source = "./ssl_certificate"

  domain       = "codeforpoznan.pl"
  route53_zone = aws_route53_zone.codeforpoznan_pl

  providers = {
    aws = aws.north_virginia
  }
}

module "codeforpoznan_pl_mailing_identity" {
  source = "./mailing_identity"

  domain       = "codeforpoznan.pl"
  route53_zone = aws_route53_zone.codeforpoznan_pl
}

// shared public bucket (we will push here all static assets in separate directories)
resource "aws_s3_bucket" "codeforpoznan_public" {
  bucket = "codeforpoznan-public"

  lifecycle {
    ignore_changes = [
      cors_rule,
    ]
  }
}

resource "aws_s3_bucket_cors_configuration" "codeforpoznan_public_cors" {
  bucket = aws_s3_bucket.codeforpoznan_public.bucket

  cors_rule {
    allowed_methods = ["GET", "HEAD"]
    allowed_origins = ["*"]
  }
}

data "aws_iam_policy_document" "codeforpoznan_public_policy" {
  version = "2012-10-17"

  statement {
    sid    = "PublicListBucket"
    effect = "Allow"
    principals {
      identifiers = ["*"]
      type        = "*"
    }
    actions   = ["s3:ListBucket"]
    resources = ["arn:aws:s3:::codeforpoznan-public"]
  }

  statement {
    sid    = "PublicGetObject"
    effect = "Allow"
    principals {
      identifiers = ["*"]
      type        = "*"
    }
    actions   = ["s3:GetObject"]
    resources = ["arn:aws:s3:::codeforpoznan-public/*"]
  }
}

resource "aws_s3_bucket_policy" "codeforpoznan_public_policy" {
  bucket = aws_s3_bucket.codeforpoznan_public.bucket
  policy = data.aws_iam_policy_document.codeforpoznan_public_policy.json
}

// shared private bucket for storing zipped projects and lambdas code
resource "aws_s3_bucket" "codeforpoznan_lambdas" {
  bucket = "codeforpoznan-lambdas"

  lifecycle {
    ignore_changes = [
      grant,
    ]
  }
}

resource "aws_s3_bucket_acl" "codeforpoznan_lambdas_acl" {
  bucket = aws_s3_bucket.codeforpoznan_lambdas.bucket
  acl    = "private"
}

// shared private bucket for storing terraform state in one place
resource "aws_s3_bucket" "codeforpoznan_tfstate" {
  bucket = "codeforpoznan-tfstate"

  lifecycle {
    ignore_changes = [
      grant,
    ]
  }
}

resource "aws_s3_bucket_acl" "codeforpoznan_tfstate_acl" {
  bucket = aws_s3_bucket.codeforpoznan_tfstate.id
  acl    = "private"
}
