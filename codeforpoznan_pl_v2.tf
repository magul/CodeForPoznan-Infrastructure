resource "aws_s3_bucket_object" "codeforpoznan_pl_v2" {
  bucket = aws_s3_bucket.codeforpoznan_public.id
  key    = "codeforpoznan.pl_v2/"
}

resource "aws_iam_policy" "codeforpoznan_pl_v2" {
  name   = "codeforpoznan.pl_v2"

  policy = <<POLICY
{
  "Version":"2012-10-17",
  "Statement":[{
    "Sid":"CodeForPoznanV2S3",
    "Effect":"Allow",
    "Action":["s3:DeleteObject", "s3:PutObject"],
    "Resource":["${aws_s3_bucket.codeforpoznan_public.arn}/${aws_s3_bucket_object.codeforpoznan_pl_v2.key}*"]
  }, {
    "Sid":"CodeForPoznanV2Distribution",
    "Effect":"Allow",
    "Action":["cloudfront:CreateInvalidation"],
    "Resource":["${aws_cloudfront_distribution.codeforpoznan_pl_v2.arn}"]
  }]
}
  POLICY

  depends_on = [
    aws_s3_bucket_object.codeforpoznan_pl_v2,
    aws_cloudfront_distribution.codeforpoznan_pl_v2,
  ]
}

resource "aws_iam_user" "codeforpoznan_pl_v2" {
  name = "codeforpoznan_pl_v2"
}

resource "aws_iam_access_key" "codeforpoznan_pl_v2" {
  user = aws_iam_user.codeforpoznan_pl_v2.name
}

resource "aws_iam_policy_attachment" "codeforpoznan_pl_v2" {
  name       = "codeforpoznan_pl_v2"
  policy_arn = aws_iam_policy.codeforpoznan_pl_v2.arn
  users      = [aws_iam_user.codeforpoznan_pl_v2.name]
}

resource "aws_cloudfront_distribution" "codeforpoznan_pl_v2" {
  origin {
    domain_name = "codeforpoznan-public.s3-eu-west-1.amazonaws.com"
    origin_path = "/codeforpoznan.pl_v2"
    origin_id   = "codeforpoznan_pl_v2"
  }

  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"
  aliases             = ["codeforpoznan.pl"]

  default_cache_behavior {
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = "codeforpoznan_pl_v2"
    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn = aws_acm_certificate.codeforpoznan_pl.arn
    ssl_support_method  = "sni-only"
  }

  depends_on = [
    aws_s3_bucket_object.codeforpoznan_pl_v2,
  ]
}
