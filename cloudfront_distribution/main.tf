variable name {
  type = string
}
variable domain {
  type = string
}
variable origins {}
variable additional_cache_behaviors {
  type    = list
  default = []
}
variable custom_error_responses {
  type    = list
  default = []
}

variable s3_bucket {}
variable route53_zone {}
variable iam_user {}
variable acm_certificate {}


resource "aws_cloudfront_distribution" "distribution" {
  dynamic "origin" {
    for_each = var.origins

    content {
      origin_id   = origin.key
      domain_name = lookup(origin.value, "domain_name", null)
      origin_path = lookup(origin.value, "origin_path", null)

      dynamic "custom_origin_config" {
        for_each = lookup(origin.value, "custom_origin", false) ? [1] : []

        content {
          http_port              = lookup(origin.value, "http_port", 80)
          https_port             = lookup(origin.value, "https_port", 443)
          origin_protocol_policy = lookup(origin.value, "protocol_policy", "match-viewer")
          origin_ssl_protocols   = lookup(origin.value, "ssl_protocols", ["TLSv1.2"])
        }
      }

      dynamic "custom_header" {
        for_each = lookup(origin.value, "custom_headers", [])

        content {
          name  = custom_header.value.name
          value = custom_header.value.value
        }
      }

    }
  }

  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"
  aliases             = [var.domain]

  default_cache_behavior {
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = [for k, v in var.origins : k if lookup(v, "default", false)].0
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

  dynamic "ordered_cache_behavior" {
    for_each = var.additional_cache_behaviors

    content {
      allowed_methods        = lookup(ordered_cache_behavior.value, "allowed_methods", ["HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE", "GET"])
      cached_methods         = lookup(ordered_cache_behavior.value, "cached_methods", ["HEAD", "GET"])
      path_pattern           = ordered_cache_behavior.value.path_pattern
      viewer_protocol_policy = lookup(ordered_cache_behavior.value, "protocol_policy", "redirect-to-https")
      target_origin_id       = ordered_cache_behavior.value.target_origin_id
      forwarded_values {
        query_string = true
        headers      = lookup(ordered_cache_behavior.value, "headers", [])
        cookies {
          forward = "all"
        }
      }
    }
  }

  dynamic "custom_error_response" {
    for_each = var.custom_error_responses

    content {
      error_caching_min_ttl = lookup(custom_error_response.value, "error_caching_min_ttl", 300)
      error_code            = custom_error_response.value.error_code
      response_code         = lookup(custom_error_response.value, "response_code", 200)
      response_page_path    = lookup(custom_error_response.value, "response_page_path", "/index.html")
    }
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn = var.acm_certificate.arn
    ssl_support_method  = "sni-only"
  }

  depends_on = [
    var.s3_bucket,
    var.acm_certificate,
  ]
}

resource "aws_route53_record" "main_record" {
  name    = var.domain
  type    = "A"
  zone_id = var.route53_zone.id

  alias {
    name                   = aws_cloudfront_distribution.distribution.domain_name
    zone_id                = aws_cloudfront_distribution.distribution.hosted_zone_id
    evaluate_target_health = false
  }

  depends_on = [
    aws_cloudfront_distribution.distribution
  ]
}

data "aws_iam_policy_document" "policy" {
  version = "2012-10-17"

  statement {
    sid       = "${replace(title(replace(var.name, "/[\\._]/", " ")), " ", "")}CloudFront"
    effect    = "Allow"
    actions   = ["cloudfront:CreateInvalidation"]
    resources = [aws_cloudfront_distribution.distribution.arn]
  }
}

resource "aws_iam_policy" "policy" {
  name   = "${var.name}_cloudfront_distribution"
  policy = data.aws_iam_policy_document.policy.json

  depends_on = [
    aws_cloudfront_distribution.distribution,
  ]
}

resource "aws_iam_user_policy_attachment" "user_policy_attachment" {
  user       = var.iam_user.name
  policy_arn = aws_iam_policy.policy.arn

  depends_on = [
    aws_iam_policy.policy,
    var.iam_user,
  ]
}
